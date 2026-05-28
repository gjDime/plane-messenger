import 'package:plane_messenger/data/models/battleship_state.dart';
import 'package:plane_messenger/data/models/game_session_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/data/services/game_handler.dart';
import 'package:plane_messenger/domain/repositories/game_repository.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';

class GameViewModel {
  final GameHandler _gameHandler;
  final GameRepository _gameRepository;
  final SigningService _signingService;

  String? _myPublicKey;

  GameViewModel({
    required GameHandler gameHandler,
    required GameRepository gameRepository,
    required SigningService signingService,
  })  : _gameHandler = gameHandler,
        _gameRepository = gameRepository,
        _signingService = signingService;

  String? get myPublicKey => _myPublicKey;

  Future<void> init() async {
    _myPublicKey = await _signingService.publicKeyBase64;
  }

  Future<void> sendInvite(PeerEntity peer, String gameType) =>
      _gameHandler.sendInvite(peer.publicKey, gameType);

  Stream<PendingGameInvite> get pendingInvites => _gameHandler.pendingInvites;

  Stream<GameSessionEntity> get acceptedInvites => _gameHandler.acceptedInvites;

  Future<void> acceptInvite(String gameId) => _gameHandler.acceptInvite(gameId);

  Future<void> declineInvite(String gameId) =>
      _gameHandler.declineInvite(gameId);

  Stream<GameSessionEntity?> watchGame(String gameId) =>
      _gameRepository.watchSession(gameId);

  Future<void> makeMove(String gameId, int position) =>
      _gameHandler.sendMove(gameId, position);

  Future<void> sendRoundStart(String gameId, int targetColor, int round) =>
      _gameHandler.sendRoundStart(gameId, targetColor, round);

  Future<void> sendColorGuess(String gameId, int guessColor, int round) =>
      _gameHandler.sendColorGuess(gameId, guessColor, round);

  Future<void> sendRoundReady(String gameId, int round) =>
      _gameHandler.sendRoundReady(gameId, round);

  Future<void> sendShipPlacement(String gameId, List<ShipPlacement> ships) =>
      _gameHandler.sendShipPlacement(gameId, ships);

  Future<void> sendBattleshipShot(String gameId, int cellIndex) =>
      _gameHandler.sendBattleshipShot(gameId, cellIndex);

  Future<void> abandonGame(String gameId) => _gameHandler.abandonGame(gameId);

  Future<GameSessionEntity?> getActiveGameForPeer(String peerPubKey) async {
    final sessions =
        await _gameRepository.getActiveSessionsForPeer(peerPubKey);
    for (final s in sessions) {
      if (s.gameStatus == GameStatus.active) return s;
    }
    return null;
  }

  Stream<GameSessionEntity?> watchActiveGameForPeer(String peerPubKey) {
    return _gameRepository.watchActiveSessions().map((sessions) {
      for (final s in sessions) {
        if ((s.playerXKey == peerPubKey || s.playerOKey == peerPubKey) &&
            s.gameStatus == GameStatus.active) {
          return s;
        }
      }
      return null;
    });
  }

  Future<GameSessionEntity?> getSession(String gameId) =>
      _gameRepository.getSession(gameId);

  bool isMyTurn(GameSessionEntity game) => game.currentTurnKey == _myPublicKey;

  bool amIPlayerX(GameSessionEntity game) => game.playerXKey == _myPublicKey;
}
