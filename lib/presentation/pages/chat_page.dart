import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:plane_messenger/core/active_screen_tracker.dart';
import 'package:plane_messenger/data/models/game_session_entity.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/data/services/game_handler.dart';
import 'package:plane_messenger/domain/services/notification_service.dart';
import 'package:plane_messenger/presentation/pages/battleship_page.dart';
import 'package:plane_messenger/presentation/pages/color_memory_page.dart';
import 'package:plane_messenger/presentation/pages/game_page.dart';
import 'package:plane_messenger/presentation/viewmodels/chat_viewmodel.dart';
import 'package:plane_messenger/presentation/viewmodels/game_viewmodel.dart';
import 'package:plane_messenger/presentation/widgets/game_selection_dialog.dart';

class ChatPage extends StatefulWidget {
  final ChatViewModel viewModel;
  final PeerEntity peer;
  final String? pendingGameId;

  const ChatPage({
    super.key,
    required this.viewModel,
    required this.peer,
    this.pendingGameId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final GameViewModel _gameViewModel;
  StreamSubscription<PendingGameInvite>? _inviteSub;
  StreamSubscription<GameSessionEntity>? _acceptedSub;
  StreamSubscription<GameSessionEntity?>? _activeGameSub;
  GameSessionEntity? _activeGame;

  ChatViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    GetIt.instance<ActiveScreenTracker>().enterDirectChat(widget.peer.publicKey);
    GetIt.instance<NotificationService>().cancelDirectChatNotifications(widget.peer.publicKey);
    _gameViewModel = GetIt.instance<GameViewModel>();

    _viewModel.init(widget.peer).then((_) {
      if (mounted) setState(() {});
    });

    _gameViewModel.init().then((_) {
      if (mounted) {
        _watchActiveGame();
        _listenForInvites();
        _listenForAcceptedInvites();
        _checkPendingGameInvite();
      }
    });
  }

  void _listenForInvites() {
    _inviteSub = _gameViewModel.pendingInvites.listen((invite) {
      if (!mounted) return;
      if (invite.inviterKey == widget.peer.publicKey) {
        _showInviteDialog(invite);
      }
    });
  }

  void _listenForAcceptedInvites() {
    _acceptedSub = _gameViewModel.acceptedInvites.listen((session) {
      if (!mounted) return;
      if (session.playerOKey == widget.peer.publicKey) {
        _navigateToGame(session);
      }
    });
  }

  Future<void> _checkPendingGameInvite() async {
    final gameId = widget.pendingGameId;
    if (gameId == null) return;
    final session = await _gameViewModel.getSession(gameId);
    if (!mounted || session == null) return;
    if (session.gameStatus != GameStatus.pending) return;

    _showInviteDialog(PendingGameInvite(
      gameId: session.gameId,
      gameType: session.gameType,
      inviterKey: session.playerXKey,
      inviterNickname: session.playerXNickname,
    ));
  }

  void _watchActiveGame() {
    if (widget.peer.publicKey.isEmpty) return;
    _activeGameSub = _gameViewModel
        .watchActiveGameForPeer(widget.peer.publicKey)
        .listen((game) {
      if (mounted) {
        setState(() => _activeGame = game);
      }
    });
  }

  @override
  void dispose() {
    GetIt.instance<ActiveScreenTracker>().exitChat();
    _inviteSub?.cancel();
    _acceptedSub?.cancel();
    _activeGameSub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isEncryptedChat => widget.peer.x25519PublicKey.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peer.nickname ?? 'Peer'),
        actions: [
          if (_isEncryptedChat)
            IconButton(
              icon: const Icon(Icons.sports_esports),
              tooltip: 'Start a game',
              onPressed: _showGameSelection,
            ),
          if (_isEncryptedChat)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Tooltip(
                message: 'End-to-end encrypted',
                child: Icon(Icons.lock, size: 18),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_activeGame != null) _buildActiveGameBanner(),
          Expanded(child: _buildMessageList()),
          _buildInputRow(),
        ],
      ),
    );
  }

  static String _gameLabel(String gameType) => switch (gameType) {
        'color_memory' => 'Color Memory',
        'battleship' => 'Battleship',
        _ => 'Tic Tac Toe',
      };

  static IconData _gameIcon(String gameType) => switch (gameType) {
        'color_memory' => Icons.palette,
        'battleship' => Icons.directions_boat,
        _ => Icons.sports_esports,
      };

  Widget _buildActiveGameBanner() {
    final gameLabel = _gameLabel(_activeGame!.gameType);
    return GestureDetector(
      onTap: () => _navigateToGame(_activeGame!),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Row(
          children: [
            Icon(
              _gameIcon(_activeGame!.gameType),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$gameLabel in progress - tap to continue',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_viewModel.myPublicKey == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<MessageEntity>>(
      stream: _viewModel.watchMessages(widget.peer),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading messages: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!;
        if (messages.isEmpty) {
          return const Center(child: Text('No messages yet. Say hello!'));
        }

        // List is sorted by timestamp descending; reverse:true places
        // the newest message (index 0) at the bottom of the viewport.
        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageEntity msg) {
    final isMe = msg.isMine;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg.payload, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTimestamp(msg.timestamp),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildDeliveryIcon(msg),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryIcon(MessageEntity msg) {
    final status = msg.status;
    if (status == DeliveryStatus.sending) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      );
    }
    if (status == DeliveryStatus.sent) {
      return const Icon(Icons.check, size: 14, color: Colors.grey);
    }
    if (status == DeliveryStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 14, color: Colors.red),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _viewModel.resendMessage(msg),
            child: const Icon(Icons.refresh, size: 14, color: Colors.red),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  String _formatTimestamp(int millisSinceEpoch) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millisSinceEpoch);
    final now = DateTime.now();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');

    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '$hh:$mm';
    }
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    if (dt.year == now.year) {
      return '$day/$month $hh:$mm';
    }
    return '$day/$month/${dt.year} $hh:$mm';
  }

  Widget _buildInputRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Type a message...'),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _viewModel.sendMessage(widget.peer, text);
    _controller.clear();
  }

  void _showGameSelection() async {
    final gameType = await GameSelectionDialog.show(context);
    if (gameType == null || !mounted) return;
    _gameViewModel.sendInvite(widget.peer, gameType);
    if (!mounted) return;
    final label = _gameLabel(gameType);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label invite sent to ${widget.peer.nickname ?? 'peer'}',
        ),
      ),
    );
  }

  void _showInviteDialog(PendingGameInvite invite) {
    final gameLabel = _gameLabel(invite.gameType);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Game Invite'),
        content: Text(
          '${invite.inviterNickname ?? 'A peer'} wants to play $gameLabel!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _gameViewModel.declineInvite(invite.gameId);
            },
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _gameViewModel.acceptInvite(invite.gameId).then((_) {
                _navigateToGameById(invite.gameId);
              });
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  Widget _gamePageForType(String? gameType, String gameId, String opponentName) {
    return switch (gameType) {
      'color_memory' => ColorMemoryPage(
          viewModel: _gameViewModel,
          gameId: gameId,
          opponentName: opponentName,
        ),
      'battleship' => BattleshipPage(
          viewModel: _gameViewModel,
          gameId: gameId,
          opponentName: opponentName,
        ),
      _ => GamePage(
          viewModel: _gameViewModel,
          gameId: gameId,
          opponentName: opponentName,
        ),
    };
  }

  void _navigateToGame(GameSessionEntity game) {
    final opponentName = widget.peer.nickname ?? 'Opponent';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _gamePageForType(game.gameType, game.gameId, opponentName),
      ),
    );
  }

  void _navigateToGameById(String gameId) async {
    final opponentName = widget.peer.nickname ?? 'Opponent';
    final session = await _gameViewModel.getSession(gameId);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _gamePageForType(session?.gameType, gameId, opponentName),
      ),
    );
  }
}
