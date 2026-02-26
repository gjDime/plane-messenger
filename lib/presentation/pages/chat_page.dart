import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plane_messenger/core/security/key_manager.dart';
import 'package:plane_messenger/data/datasources/local/isar_service.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/data/repositories/mesh_repository_impl.dart';
import 'package:plane_messenger/main.dart';

class ChatPage extends StatefulWidget {
  final PeerEntity peer;
  const ChatPage({super.key, required this.peer});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final IsarService _isarService = getIt<IsarService>();
  final MeshRepositoryImpl _meshRepo = getIt<MeshRepositoryImpl>();

  String? _myPublicKey;

  @override
  void initState() {
    super.initState();
    _loadMyPublicKey();
    _isarService.markPeerAsRead(widget.peer.deviceId);
  }

  Future<void> _loadMyPublicKey() async {
    final key = await getIt<KeyManager>().publicKeyBase64;
    if (mounted) setState(() => _myPublicKey = key);
  }

  @override
  void dispose() {
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
          Expanded(child: _buildMessageList()),
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_myPublicKey == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final peerPubKey = widget.peer.publicKey;
    final hasPeerKey = peerPubKey.isNotEmpty;

    return StreamBuilder<List<MessageEntity>>(
      stream: hasPeerKey
          ? _isarService.watchMessagesForPeer(peerPubKey, _myPublicKey!)
          : _isarService.watchMessages(),
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
    final isEncrypted = msg.targetId != 'BROADCAST';

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
            if (kDebugMode)
              Text(
                'TTL: ${msg.ttl} | ${isMe ? 'Me' : 'Peer'}'
                '${isEncrypted ? ' | E2EE' : ''}',
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            if (isMe) _buildDeliveryStatusRow(msg),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryStatusRow(MessageEntity msg) {
    final status = msg.status;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        if (status == DeliveryStatus.sending)
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        if (status == DeliveryStatus.sent)
          const Icon(Icons.check, size: 14, color: Colors.grey),
        if (status == DeliveryStatus.failed) ...[
          const Icon(Icons.error_outline, size: 14, color: Colors.red),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _meshRepo.resendFailedMessage(msg),
            child: const Icon(Icons.refresh, size: 14, color: Colors.red),
          ),
        ],
      ],
    );
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

    final peerPubKey = widget.peer.publicKey;
    if (peerPubKey.isNotEmpty) {
      _meshRepo.sendDirectMessage(peerPubKey, text);
    } else {
      _meshRepo.broadcastMessage(text);
    }
    _controller.clear();
  }
}
