import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:plane_messenger/core/security/crypto_service.dart';
import 'package:plane_messenger/data/models/battleship_state.dart';
import 'package:plane_messenger/data/models/color_memory_state.dart';
import 'package:plane_messenger/data/models/game_move_entity.dart';
import 'package:plane_messenger/data/models/game_session_entity.dart';
import 'package:plane_messenger/data/services/battleship_logic.dart';
import 'package:plane_messenger/data/services/color_memory_logic.dart';
import 'package:plane_messenger/data/services/packet_codec.dart';
import 'package:plane_messenger/data/services/tictactoe_logic.dart';
import 'package:plane_messenger/domain/repositories/game_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/domain/services/encryption_service.dart';
import 'package:plane_messenger/domain/services/p2p_connection_service.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';
import 'package:uuid/uuid.dart';

class PendingGameInvite {
  final String gameId;
  final String gameType;
  final String inviterKey;
  final String? inviterNickname;

  PendingGameInvite({
    required this.gameId,
    required this.gameType,
    required this.inviterKey,
    this.inviterNickname,
  });
}

class GameHandler {
  final GameRepository _gameRepository;
  final PeerRepository _peerRepository;
  final SigningService _signingService;
  final EncryptionService _encryptionService;
  final P2PConnectionService _connectionService;
  final PacketCodec _packetCodec;

  final _pendingInvites = StreamController<PendingGameInvite>.broadcast();
  final _acceptedInvites = StreamController<GameSessionEntity>.broadcast();

  final Map<String, Timer> _retransmitTimers = {};
  final Map<String, int> _retransmitCounts = {};

  static const _maxRetries = 3;
  static const _retransmitDelay = Duration(seconds: 3);

  GameHandler({
    required GameRepository gameRepository,
    required PeerRepository peerRepository,
    required SigningService signingService,
    required EncryptionService encryptionService,
    required P2PConnectionService connectionService,
    required PacketCodec packetCodec,
  })  : _gameRepository = gameRepository,
        _peerRepository = peerRepository,
        _signingService = signingService,
        _encryptionService = encryptionService,
        _connectionService = connectionService,
        _packetCodec = packetCodec;

  Stream<PendingGameInvite> get pendingInvites => _pendingInvites.stream;
  Stream<GameSessionEntity> get acceptedInvites => _acceptedInvites.stream;

  Future<void> sendInvite(String opponentPubKey, String gameType) async {
    final myKey = await _signingService.publicKeyBase64;
    final gameId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final myPeer = await _peerRepository.getPeerByPublicKey(myKey);

    final session = _createPendingSession(
      gameId: gameId,
      gameType: gameType,
      playerXKey: myKey,
      playerOKey: opponentPubKey,
      playerXNickname: myPeer?.nickname,
      createdAt: now,
    );

    await _gameRepository.saveSession(session);

    final endpointId = await _resolveEndpoint(opponentPubKey);
    if (endpointId == null) {
      debugPrint('[GAME] Cannot send invite: peer not connected');
      return;
    }

    final packet = jsonEncode({
      'type': 'game_invite',
      'gameId': gameId,
      'gameType': gameType,
      'inviterKey': myKey,
      'nickname': myPeer?.nickname,
      'ts': now,
    });
    await _connectionService.sendPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(packet)),
    );
  }

  Future<void> acceptInvite(String gameId) async {
    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.pending) return;

    final myKey = await _signingService.publicKeyBase64;
    final myPeer = await _peerRepository.getPeerByPublicKey(myKey);

    session.playerOKey = myKey;
    session.playerONickname = myPeer?.nickname;
    session.gameStatus = GameStatus.active;
    await _gameRepository.saveSession(session);

    final endpointId = await _resolveEndpoint(session.playerXKey);
    if (endpointId == null) return;

    final packet = jsonEncode({
      'type': 'game_accept',
      'gameId': gameId,
      'acceptorKey': myKey,
      'nickname': myPeer?.nickname,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    await _connectionService.sendPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(packet)),
    );
  }

  Future<void> declineInvite(String gameId) async {
    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.pending) return;

    session.gameStatus = GameStatus.declined;
    await _gameRepository.saveSession(session);

    final opponentKey = await _getOpponentKey(session);
    final endpointId = await _resolveEndpoint(opponentKey);
    if (endpointId == null) return;

    final packet = jsonEncode({
      'type': 'game_decline',
      'gameId': gameId,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    await _connectionService.sendPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(packet)),
    );
  }

  Future<void> sendMove(String gameId, int position) async {
    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.active) return;

    final myKey = await _signingService.publicKeyBase64;
    if (session.currentTurnKey != myKey) {
      debugPrint('[GAME] Not my turn');
      return;
    }

    final moveNumber = session.moveCount + 1;
    final mark = TicTacToeLogic.markForMoveNumber(moveNumber);

    if (!TicTacToeLogic.isValidMove(session.board, position, mark)) {
      debugPrint('[GAME] Invalid move: position=$position');
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final newBoard = TicTacToeLogic.applyMove(session.board, position, mark);
    session.board = newBoard;
    session.moveCount = moveNumber;
    session.lastMoveAt = now;

    final winner = TicTacToeLogic.checkWinner(newBoard);
    if (winner != 0) {
      session.winnerKey = myKey;
      session.result = 'win';
      session.gameStatus = GameStatus.completed;
    } else if (TicTacToeLogic.isBoardFull(newBoard)) {
      session.result = 'draw';
      session.gameStatus = GameStatus.completed;
    } else {
      final opponentKey = await _getOpponentKey(session);
      session.currentTurnKey = opponentKey;
    }

    await _gameRepository.saveSession(session);

    final opponentKey = await _getOpponentKey(session);
    await _sendEncryptedGamePayload(
      gameId: gameId,
      opponentKey: opponentKey,
      payload: {
        'gameId': gameId,
        'position': position,
        'moveNumber': moveNumber,
        'sender': myKey,
        'ts': now,
      },
      position: position,
      moveNumber: moveNumber,
    );
  }

  Future<void> sendRoundStart(
      String gameId, int targetColor, int round) async {
    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.active) return;

    final myKey = await _signingService.publicKeyBase64;
    final now = DateTime.now().millisecondsSinceEpoch;

    var state = ColorMemoryState.deserialize(session.colorGameData) ??
        ColorMemoryLogic.initialState();
    final rounds = _setRoundColor(state.rounds, round, targetColor);
    state = state.copyWith(rounds: rounds, currentRound: round);
    session.colorGameData = state.serialize();
    session.lastMoveAt = now;
    await _gameRepository.saveSession(session);

    final opponentKey = await _getOpponentKey(session);
    await _sendEncryptedGamePayload(
      gameId: gameId,
      opponentKey: opponentKey,
      payload: {
        'gameId': gameId,
        'moveType': 'round_start',
        'round': round,
        'color': targetColor,
        'sender': myKey,
        'ts': now,
      },
      position: 0,
      moveNumber: round * 100, // namespace to avoid collision with TTT
    );
  }

  Future<void> sendColorGuess(
      String gameId, int guessColor, int round) async {
    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.active) return;

    final myKey = await _signingService.publicKeyBase64;
    final now = DateTime.now().millisecondsSinceEpoch;

    var state = ColorMemoryState.deserialize(session.colorGameData) ??
        ColorMemoryLogic.initialState();
    if (round <= state.rounds.length) {
      final rounds = List<ColorMemoryRound>.from(state.rounds);
      final isPlayerX = session.playerXKey == myKey;
      final currentRound = rounds[round - 1];
      rounds[round - 1] = isPlayerX
          ? currentRound.copyWith(xGuess: guessColor)
          : currentRound.copyWith(oGuess: guessColor);
      state = state.copyWith(rounds: rounds);

      final updatedRound = rounds[round - 1];
      if (updatedRound.isComplete) {
        final xDist = ColorMemoryLogic.colorDistance(
            updatedRound.targetColor, updatedRound.xGuess!);
        final oDist = ColorMemoryLogic.colorDistance(
            updatedRound.targetColor, updatedRound.oGuess!);

        rounds[round - 1] = updatedRound.copyWith(
          xDistance: xDist,
          oDistance: oDist,
        );

        final winner = ColorMemoryLogic.roundWinner(xDist, oDist);
        var xWon = state.xRoundsWon;
        var oWon = state.oRoundsWon;
        if (winner == 'x') xWon++;
        if (winner == 'o') oWon++;

        state = state.copyWith(
          rounds: rounds,
          xRoundsWon: xWon,
          oRoundsWon: oWon,
        );

        if (xWon >= 2 || oWon >= 2) {
          session.gameStatus = GameStatus.completed;
          session.result = 'win';
          session.winnerKey =
              xWon >= 2 ? session.playerXKey : session.playerOKey;
        }
      }

      session.colorGameData = state.serialize();
    }
    session.lastMoveAt = now;
    await _gameRepository.saveSession(session);

    final opponentKey = await _getOpponentKey(session);
    await _sendEncryptedGamePayload(
      gameId: gameId,
      opponentKey: opponentKey,
      payload: {
        'gameId': gameId,
        'moveType': 'color_guess',
        'round': round,
        'color': guessColor,
        'sender': myKey,
        'ts': now,
      },
      position: 0,
      moveNumber: round * 100 + 1,
    );
  }

  Future<void> sendRoundReady(String gameId, int round) async {
    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.active) return;

    final myKey = await _signingService.publicKeyBase64;
    final now = DateTime.now().millisecondsSinceEpoch;

    var state = ColorMemoryState.deserialize(session.colorGameData) ??
        ColorMemoryLogic.initialState();

    if (round > state.rounds.length) return;

    final rounds = List<ColorMemoryRound>.from(state.rounds);
    final isPlayerX = session.playerXKey == myKey;
    rounds[round - 1] = isPlayerX
        ? rounds[round - 1].copyWith(xReady: true)
        : rounds[round - 1].copyWith(oReady: true);

    state = state.copyWith(rounds: rounds);

    final updatedRound = rounds[round - 1];
    if (updatedRound.xReady && updatedRound.oReady && !state.isMatchOver) {
      state = state.copyWith(currentRound: round + 1);
    }

    session.colorGameData = state.serialize();
    session.lastMoveAt = now;
    await _gameRepository.saveSession(session);

    final opponentKey = await _getOpponentKey(session);
    await _sendEncryptedGamePayload(
      gameId: gameId,
      opponentKey: opponentKey,
      payload: {
        'gameId': gameId,
        'moveType': 'round_ready',
        'round': round,
        'sender': myKey,
        'ts': now,
      },
      position: 0,
      moveNumber:
          round * 100 + 2, // namespace: round_start=*100, guess=*100+1, ready=*100+2
    );
  }

  Future<void> sendShipPlacement(
      String gameId, List<ShipPlacement> ships) async {
    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.active) return;

    if (!BattleshipLogic.validatePlacement(ships)) {
      debugPrint('[GAME] Invalid ship placement');
      return;
    }

    final myKey = await _signingService.publicKeyBase64;
    final now = DateTime.now().millisecondsSinceEpoch;
    final isPlayerX = session.playerXKey == myKey;

    var state = BattleshipState.deserialize(session.colorGameData) ??
        BattleshipLogic.initialState();

    state = isPlayerX
        ? state.copyWith(xShips: ships, xReady: true)
        : state.copyWith(oShips: ships, oReady: true);

    if (state.xReady && state.oReady) {
      state = state.copyWith(phase: 'gameplay');
      session.currentTurnKey = session.playerXKey;
    }

    session.colorGameData = state.serialize();
    session.lastMoveAt = now;
    await _gameRepository.saveSession(session);

    final opponentKey = await _getOpponentKey(session);
    await _sendEncryptedGamePayload(
      gameId: gameId,
      opponentKey: opponentKey,
      payload: {
        'gameId': gameId,
        'moveType': 'ship_placement',
        'ships': ships.map((s) => s.toJson()).toList(),
        'sender': myKey,
        'ts': now,
      },
      position: 0,
      moveNumber: 1000, // namespace for battleship placement
    );
  }

  Future<void> sendBattleshipShot(String gameId, int cellIndex) async {
    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.active) return;

    final myKey = await _signingService.publicKeyBase64;
    if (session.currentTurnKey != myKey) {
      debugPrint('[GAME] Not my turn');
      return;
    }

    final isPlayerX = session.playerXKey == myKey;
    var state = BattleshipState.deserialize(session.colorGameData) ??
        BattleshipLogic.initialState();

    if (state.phase != 'gameplay') {
      debugPrint('[GAME] Not in gameplay phase');
      return;
    }

    final myShots = isPlayerX ? state.xShots : state.oShots;
    if (!BattleshipLogic.isValidShot(myShots, cellIndex)) {
      debugPrint('[GAME] Invalid shot: cellIndex=$cellIndex');
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedShots = List<int>.from(myShots)..add(cellIndex);

    final opponentShips = isPlayerX ? state.oShips : state.xShips;

    state = isPlayerX
        ? state.copyWith(xShots: updatedShots)
        : state.copyWith(oShots: updatedShots);

    if (BattleshipLogic.allShipsSunk(opponentShips, updatedShots)) {
      state = state.copyWith(phase: 'completed');
      session.gameStatus = GameStatus.completed;
      session.result = 'win';
      session.winnerKey = myKey;
    } else {
      final opponentKey = await _getOpponentKey(session);
      session.currentTurnKey = opponentKey;
    }

    session.colorGameData = state.serialize();
    session.moveCount = session.moveCount + 1;
    session.lastMoveAt = now;
    await _gameRepository.saveSession(session);

    final opponentKey = await _getOpponentKey(session);
    await _sendEncryptedGamePayload(
      gameId: gameId,
      opponentKey: opponentKey,
      payload: {
        'gameId': gameId,
        'moveType': 'shot',
        'cellIndex': cellIndex,
        'sender': myKey,
        'ts': now,
      },
      position: cellIndex,
      moveNumber: 2000 + session.moveCount, // namespace for battleship shots
    );
  }

  Future<void> abandonGame(String gameId) async {
    final session = await _gameRepository.getSession(gameId);
    if (session == null) return;
    if (session.gameStatus != GameStatus.active &&
        session.gameStatus != GameStatus.pending) {
      return;
    }

    final myKey = await _signingService.publicKeyBase64;
    session.gameStatus = GameStatus.abandoned;
    session.result = 'abandoned';
    await _gameRepository.saveSession(session);

    _cancelRetransmitTimer(gameId);

    final opponentKey = await _getOpponentKey(session);
    final endpointId = await _resolveEndpoint(opponentKey);
    if (endpointId == null) return;

    final packet = jsonEncode({
      'type': 'game_abandon',
      'gameId': gameId,
      'senderKey': myKey,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    await _connectionService.sendPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(packet)),
    );
  }

  Future<void> resendPendingMoves(String peerPubKey) async {
    final sessions =
        await _gameRepository.getActiveSessionsForPeer(peerPubKey);
    for (final session in sessions) {
      if (session.gameStatus != GameStatus.active) continue;

      final unacked = await _gameRepository.getUnackedMove(session.gameId);
      if (unacked == null) continue;

      final myKey = await _signingService.publicKeyBase64;
      if (unacked.playerKey != myKey) continue;

      final opponentKey = await _getOpponentKey(session);
      await _sendEncryptedGamePayload(
        gameId: session.gameId,
        opponentKey: opponentKey,
        payload: {
          'gameId': session.gameId,
          'position': unacked.position,
          'moveNumber': unacked.moveNumber,
          'sender': myKey,
          'ts': unacked.timestamp,
        },
        position: unacked.position,
        moveNumber: unacked.moveNumber,
        existingMoveId: unacked.moveId,
      );
    }
  }

  Future<void> handleGamePacket(
    Map<String, dynamic> packet,
    String endpointId,
  ) async {
    final type = packet['type'] as String;

    switch (type) {
      case 'game_invite':
        await _handleInvite(packet, endpointId);
      case 'game_accept':
        await _handleAccept(packet);
      case 'game_decline':
        await _handleDecline(packet);
      case 'game_move_ack':
        await _handleMoveAck(packet);
      case 'game_abandon':
        await _handleAbandon(packet);
    }
  }

  Future<void> handleGameMovePacket(
    Map<String, dynamic> packet,
    String endpointId,
  ) async {
    final data = packet['d'] as Map<String, dynamic>;
    final signature = packet['s'] as String;
    final senderKey = data['sender'] as String?;

    if (senderKey == null) {
      debugPrint('[GAME] Move packet missing sender');
      return;
    }

    if (!await _packetCodec.verifySignature(data, signature, senderKey)) {
      debugPrint('[GAME] Move packet has invalid signature');
      return;
    }

    if (!_encryptionService.hasSharedSecret(senderKey)) {
      await _ensureSharedSecret(senderKey);
    }

    final nonceB64 = data['nonce'] as String?;
    final macB64 = data['mac'] as String?;
    final payloadB64 = data['payload'] as String?;

    if (nonceB64 == null || macB64 == null || payloadB64 == null) {
      debugPrint('[GAME] Move packet missing encryption fields');
      return;
    }

    String plaintext;
    try {
      final encrypted = EncryptedPayload(
        ciphertextBase64: payloadB64,
        nonceBase64: nonceB64,
        macBase64: macB64,
      );
      plaintext = await _encryptionService.decryptFromPeer(senderKey, encrypted);
    } catch (e) {
      debugPrint('[GAME] Failed to decrypt move: $e');
      return;
    }

    final moveData = jsonDecode(plaintext) as Map<String, dynamic>;
    final gameId = moveData['gameId'] as String;
    final moveId = moveData['moveId'] as String;

    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.active) {
      debugPrint('[GAME] Move for unknown/inactive game $gameId');
      await _sendMoveAck(gameId, moveId, endpointId);
      return;
    }

    if (session.gameType == 'color_memory') {
      await _handleColorMemoryPayload(
          moveData, session, endpointId, senderKey, signature);
    } else if (session.gameType == 'battleship') {
      await _handleBattleshipPayload(
          moveData, session, endpointId, senderKey, signature);
    } else {
      await _handleTicTacToePayload(
          moveData, session, endpointId, senderKey, signature);
    }
  }

  Future<void> _handleTicTacToePayload(
    Map<String, dynamic> moveData,
    GameSessionEntity session,
    String endpointId,
    String senderKey,
    String signature,
  ) async {
    final gameId = moveData['gameId'] as String;
    final moveId = moveData['moveId'] as String;
    final position = moveData['position'] as int;
    final moveNumber = moveData['moveNumber'] as int;
    final ts = moveData['ts'] as int;

    final mark = TicTacToeLogic.markForMoveNumber(moveNumber);
    if (!TicTacToeLogic.isValidMove(session.board, position, mark)) {
      debugPrint('[GAME] Invalid move from $senderKey: pos=$position');
      await _sendMoveAck(gameId, moveId, endpointId);
      return;
    }

    if (moveNumber != session.moveCount + 1) {
      debugPrint('[GAME] Move number mismatch: expected ${session.moveCount + 1}, got $moveNumber');
      await _sendMoveAck(gameId, moveId, endpointId);
      return;
    }

    final myKey = await _signingService.publicKeyBase64;
    final newBoard = TicTacToeLogic.applyMove(session.board, position, mark);
    session.board = newBoard;
    session.moveCount = moveNumber;
    session.lastMoveAt = ts;

    final winner = TicTacToeLogic.checkWinner(newBoard);
    if (winner != 0) {
      session.winnerKey = senderKey;
      session.result = 'win';
      session.gameStatus = GameStatus.completed;
    } else if (TicTacToeLogic.isBoardFull(newBoard)) {
      session.result = 'draw';
      session.gameStatus = GameStatus.completed;
    } else {
      session.currentTurnKey = myKey;
    }

    await _gameRepository.saveSession(session);

    final moveEntity = GameMoveEntity()
      ..gameId = gameId
      ..moveId = moveId
      ..playerKey = senderKey
      ..moveNumber = moveNumber
      ..position = position
      ..timestamp = ts
      ..signature = signature
      ..acked = true;

    await _gameRepository.saveMove(moveEntity);
    await _sendMoveAck(gameId, moveId, endpointId);
  }

  Future<void> _handleColorMemoryPayload(
    Map<String, dynamic> moveData,
    GameSessionEntity session,
    String endpointId,
    String senderKey,
    String signature,
  ) async {
    final gameId = moveData['gameId'] as String;
    final moveId = moveData['moveId'] as String;
    final moveType = moveData['moveType'] as String;
    final round = moveData['round'] as int;
    final color = moveData['color'] as int?;
    final ts = moveData['ts'] as int;

    var state = ColorMemoryState.deserialize(session.colorGameData) ??
        ColorMemoryLogic.initialState();

    if (moveType == 'round_start') {
      final rounds = _setRoundColor(state.rounds, round, color!);
      state = state.copyWith(rounds: rounds, currentRound: round);
      session.colorGameData = state.serialize();
      session.lastMoveAt = ts;
      await _gameRepository.saveSession(session);
    } else if (moveType == 'color_guess') {
      if (round > state.rounds.length) {
        debugPrint('[GAME] Color guess for non-existent round $round');
        await _sendMoveAck(gameId, moveId, endpointId);
        return;
      }

      final rounds = List<ColorMemoryRound>.from(state.rounds);
      final currentRound = rounds[round - 1];
      final isXSender = session.playerXKey == senderKey;

      rounds[round - 1] = isXSender
          ? currentRound.copyWith(xGuess: color!)
          : currentRound.copyWith(oGuess: color!);

      state = state.copyWith(rounds: rounds);

      final updatedRound = rounds[round - 1];
      if (updatedRound.isComplete) {
        final xDist = ColorMemoryLogic.colorDistance(
            updatedRound.targetColor, updatedRound.xGuess!);
        final oDist = ColorMemoryLogic.colorDistance(
            updatedRound.targetColor, updatedRound.oGuess!);

        rounds[round - 1] = updatedRound.copyWith(
          xDistance: xDist,
          oDistance: oDist,
        );

        final winner = ColorMemoryLogic.roundWinner(xDist, oDist);
        var xWon = state.xRoundsWon;
        var oWon = state.oRoundsWon;
        if (winner == 'x') xWon++;
        if (winner == 'o') oWon++;

        state = state.copyWith(
          rounds: rounds,
          xRoundsWon: xWon,
          oRoundsWon: oWon,
        );

        if (xWon >= 2 || oWon >= 2) {
          session.gameStatus = GameStatus.completed;
          session.result = 'win';
          session.winnerKey =
              xWon >= 2 ? session.playerXKey : session.playerOKey;
        }
      }

      session.colorGameData = state.serialize();
      session.lastMoveAt = ts;
      await _gameRepository.saveSession(session);
    } else if (moveType == 'round_ready') {
      if (round > state.rounds.length) {
        debugPrint('[GAME] round_ready for non-existent round $round');
        await _sendMoveAck(gameId, moveId, endpointId);
        return;
      }

      final rounds = List<ColorMemoryRound>.from(state.rounds);
      final currentRound = rounds[round - 1];
      final isXSender = session.playerXKey == senderKey;

      rounds[round - 1] = isXSender
          ? currentRound.copyWith(xReady: true)
          : currentRound.copyWith(oReady: true);

      state = state.copyWith(rounds: rounds);

      final updatedRound = rounds[round - 1];
      if (updatedRound.xReady && updatedRound.oReady && !state.isMatchOver) {
        state = state.copyWith(currentRound: round + 1);
      }

      session.colorGameData = state.serialize();
      session.lastMoveAt = ts;
      await _gameRepository.saveSession(session);
    }

    final moveEntity = GameMoveEntity()
      ..gameId = gameId
      ..moveId = moveId
      ..playerKey = senderKey
      ..moveNumber = round
      ..position = color ?? 0
      ..timestamp = ts
      ..signature = signature
      ..acked = true;
    await _gameRepository.saveMove(moveEntity);

    await _sendMoveAck(gameId, moveId, endpointId);
  }

  Future<void> _handleBattleshipPayload(
    Map<String, dynamic> moveData,
    GameSessionEntity session,
    String endpointId,
    String senderKey,
    String signature,
  ) async {
    final gameId = moveData['gameId'] as String;
    final moveId = moveData['moveId'] as String;
    final moveType = moveData['moveType'] as String;
    final ts = moveData['ts'] as int;

    final myKey = await _signingService.publicKeyBase64;

    var state = BattleshipState.deserialize(session.colorGameData) ??
        BattleshipLogic.initialState();

    if (moveType == 'ship_placement') {
      final shipsJson = moveData['ships'] as List;
      final ships = shipsJson
          .map((s) => ShipPlacement.fromJson(s as Map<String, dynamic>))
          .toList();

      if (!BattleshipLogic.validatePlacement(ships)) {
        debugPrint('[GAME] Invalid ship placement from $senderKey');
        await _sendMoveAck(gameId, moveId, endpointId);
        return;
      }

      final isXSender = session.playerXKey == senderKey;
      state = isXSender
          ? state.copyWith(xShips: ships, xReady: true)
          : state.copyWith(oShips: ships, oReady: true);

      if (state.xReady && state.oReady) {
        state = state.copyWith(phase: 'gameplay');
        session.currentTurnKey = session.playerXKey;
      }

      session.colorGameData = state.serialize();
      session.lastMoveAt = ts;
      await _gameRepository.saveSession(session);
    } else if (moveType == 'shot') {
      final cellIndex = moveData['cellIndex'] as int;
      final isXSender = session.playerXKey == senderKey;

      final senderShots = isXSender ? state.xShots : state.oShots;
      if (!BattleshipLogic.isValidShot(senderShots, cellIndex)) {
        debugPrint('[GAME] Invalid shot from $senderKey: $cellIndex');
        await _sendMoveAck(gameId, moveId, endpointId);
        return;
      }

      final updatedShots = List<int>.from(senderShots)..add(cellIndex);
      final targetShips = isXSender ? state.oShips : state.xShips;

      state = isXSender
          ? state.copyWith(xShots: updatedShots)
          : state.copyWith(oShots: updatedShots);

      if (BattleshipLogic.allShipsSunk(targetShips, updatedShots)) {
        state = state.copyWith(phase: 'completed');
        session.gameStatus = GameStatus.completed;
        session.result = 'win';
        session.winnerKey = senderKey;
      } else {
        session.currentTurnKey = myKey;
      }

      session.colorGameData = state.serialize();
      session.moveCount = session.moveCount + 1;
      session.lastMoveAt = ts;
      await _gameRepository.saveSession(session);
    }

    final moveEntity = GameMoveEntity()
      ..gameId = gameId
      ..moveId = moveId
      ..playerKey = senderKey
      ..moveNumber = session.moveCount
      ..position = moveType == 'shot' ? (moveData['cellIndex'] as int) : 0
      ..timestamp = ts
      ..signature = signature
      ..acked = true;
    await _gameRepository.saveMove(moveEntity);

    await _sendMoveAck(gameId, moveId, endpointId);
  }

  void onPeerDisconnected(String peerPubKey) {
    for (final entry in _retransmitTimers.entries.toList()) {
      entry.value.cancel();
    }
    _retransmitTimers.clear();
    _retransmitCounts.clear();
  }

  Future<void> _sendEncryptedGamePayload({
    required String gameId,
    required String opponentKey,
    required Map<String, dynamic> payload,
    required int position,
    required int moveNumber,
    String? existingMoveId,
  }) async {
    final myKey = await _signingService.publicKeyBase64;
    final moveId = existingMoveId ?? const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final fullPayload = {...payload, 'moveId': moveId};

    await _ensureSharedSecret(opponentKey);

    final encrypted = await _encryptionService.encryptForPeer(
      opponentKey,
      jsonEncode(fullPayload),
    );

    final dataMap = {
      'gameId': gameId,
      'payload': encrypted.ciphertextBase64,
      'nonce': encrypted.nonceBase64,
      'mac': encrypted.macBase64,
      'sender': myKey,
    };

    final packetBytes = await _packetCodec.signAndEncode(
      dataMap,
      transport: {'ttl': 0, 'target': opponentKey},
    );

    if (existingMoveId == null) {
      final moveEntity = GameMoveEntity()
        ..gameId = gameId
        ..moveId = moveId
        ..playerKey = myKey
        ..moveNumber = moveNumber
        ..position = position
        ..timestamp = now
        ..signature = '';
      await _gameRepository.saveMove(moveEntity);
    }

    final endpointId = await _resolveEndpoint(opponentKey);
    if (endpointId != null) {
      await _connectionService.sendPayload(endpointId, packetBytes);
      _startRetransmitTimer(gameId, endpointId, packetBytes);
    }
  }

  Future<void> _handleInvite(
    Map<String, dynamic> packet,
    String endpointId,
  ) async {
    final gameId = packet['gameId'] as String;
    final gameType = packet['gameType'] as String;
    final inviterKey = packet['inviterKey'] as String;
    final nickname = packet['nickname'] as String?;
    final ts = packet['ts'] as int;

    final myKey = await _signingService.publicKeyBase64;

    final session = _createPendingSession(
      gameId: gameId,
      gameType: gameType,
      playerXKey: inviterKey,
      playerOKey: myKey,
      playerXNickname: nickname,
      createdAt: ts,
    );

    await _gameRepository.saveSession(session);

    _pendingInvites.add(PendingGameInvite(
      gameId: gameId,
      gameType: gameType,
      inviterKey: inviterKey,
      inviterNickname: nickname,
    ));
  }

  Future<void> _handleAccept(Map<String, dynamic> packet) async {
    final gameId = packet['gameId'] as String;
    final acceptorKey = packet['acceptorKey'] as String;
    final nickname = packet['nickname'] as String?;

    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.pending) return;

    session.playerOKey = acceptorKey;
    session.playerONickname = nickname;
    session.gameStatus = GameStatus.active;
    await _gameRepository.saveSession(session);

    _acceptedInvites.add(session);
  }

  Future<void> _handleDecline(Map<String, dynamic> packet) async {
    final gameId = packet['gameId'] as String;

    final session = await _gameRepository.getSession(gameId);
    if (session == null || session.gameStatus != GameStatus.pending) return;

    session.gameStatus = GameStatus.declined;
    await _gameRepository.saveSession(session);
  }

  Future<void> _handleMoveAck(Map<String, dynamic> packet) async {
    final gameId = packet['gameId'] as String;
    final moveId = packet['moveId'] as String;

    _cancelRetransmitTimer(gameId);
    await _gameRepository.markMoveAcked(moveId);
  }

  Future<void> _handleAbandon(Map<String, dynamic> packet) async {
    final gameId = packet['gameId'] as String;

    final session = await _gameRepository.getSession(gameId);
    if (session == null) return;
    if (session.gameStatus != GameStatus.active &&
        session.gameStatus != GameStatus.pending) {
      return;
    }

    session.gameStatus = GameStatus.abandoned;
    session.result = 'abandoned';
    await _gameRepository.saveSession(session);

    _cancelRetransmitTimer(gameId);
  }

  Future<void> _sendMoveAck(
    String gameId,
    String moveId,
    String endpointId,
  ) async {
    final packet = jsonEncode({
      'type': 'game_move_ack',
      'gameId': gameId,
      'moveId': moveId,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    try {
      await _connectionService.sendPayload(
        endpointId,
        Uint8List.fromList(utf8.encode(packet)),
      );
    } catch (e) {
      debugPrint('[GAME] Failed to send move ACK: $e');
    }
  }

  void _startRetransmitTimer(
    String gameId,
    String endpointId,
    Uint8List packetBytes,
  ) {
    _cancelRetransmitTimer(gameId);
    _retransmitCounts[gameId] = 0;

    _retransmitTimers[gameId] = Timer.periodic(_retransmitDelay, (timer) async {
      final count = (_retransmitCounts[gameId] ?? 0) + 1;
      _retransmitCounts[gameId] = count;

      if (count > _maxRetries) {
        timer.cancel();
        _retransmitTimers.remove(gameId);
        _retransmitCounts.remove(gameId);
        debugPrint('[GAME] Max retransmits reached for game $gameId');
        return;
      }

      debugPrint('[GAME] Retransmit #$count for game $gameId');
      try {
        await _connectionService.sendPayload(endpointId, packetBytes);
      } catch (e) {
        debugPrint('[GAME] Retransmit failed: $e');
        timer.cancel();
        _retransmitTimers.remove(gameId);
        _retransmitCounts.remove(gameId);
      }
    });
  }

  void _cancelRetransmitTimer(String gameId) {
    _retransmitTimers[gameId]?.cancel();
    _retransmitTimers.remove(gameId);
    _retransmitCounts.remove(gameId);
  }

  GameSessionEntity _createPendingSession({
    required String gameId,
    required String gameType,
    required String playerXKey,
    required String playerOKey,
    required int createdAt,
    String? playerXNickname,
  }) {
    return GameSessionEntity()
      ..gameId = gameId
      ..gameType = gameType
      ..playerXKey = playerXKey
      ..playerOKey = playerOKey
      ..playerXNickname = playerXNickname
      ..status = GameStatus.pending.index
      ..currentTurnKey = playerXKey
      ..board = gameType == 'tictactoe' ? TicTacToeLogic.emptyBoard() : [0]
      ..colorGameData = gameType == 'color_memory'
          ? ColorMemoryLogic.initialState().serialize()
          : gameType == 'battleship'
              ? BattleshipLogic.initialState().serialize()
              : ''
      ..createdAt = createdAt;
  }

  static List<ColorMemoryRound> _setRoundColor(
    List<ColorMemoryRound> existing,
    int round,
    int color,
  ) {
    final rounds = List<ColorMemoryRound>.from(existing);
    while (rounds.length < round) {
      rounds.add(ColorMemoryRound(targetColor: color));
    }
    rounds[round - 1] = ColorMemoryRound(targetColor: color);
    return rounds;
  }

  Future<String?> _resolveEndpoint(String pubKey) async {
    final peer = await _peerRepository.getPeerByPublicKey(pubKey);
    if (peer == null || !peer.isConnected) return null;
    return peer.deviceId;
  }

  Future<String> _getOpponentKey(GameSessionEntity session) async {
    final myKey = await _signingService.publicKeyBase64;
    return session.playerXKey == myKey ? session.playerOKey : session.playerXKey;
  }

  Future<void> _ensureSharedSecret(String peerKey) async {
    if (_encryptionService.hasSharedSecret(peerKey)) return;
    final peer = await _peerRepository.getPeerByPublicKey(peerKey);
    if (peer != null && peer.x25519PublicKey.isNotEmpty) {
      await _encryptionService.establishSharedSecret(
        peerKey,
        peer.x25519PublicKey,
      );
    }
  }
}
