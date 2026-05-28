import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:plane_messenger/core/active_screen_tracker.dart';
import 'package:plane_messenger/data/models/group_entity.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/domain/services/notification_service.dart';
import 'package:plane_messenger/presentation/viewmodels/group_chat_viewmodel.dart';
import 'package:plane_messenger/presentation/viewmodels/radar_viewmodel.dart';

class GroupChatPage extends StatefulWidget {
  final GroupChatViewModel viewModel;
  final GroupEntity group;

  const GroupChatPage({
    super.key,
    required this.viewModel,
    required this.group,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Nickname cache: pubKey -> nickname
  final Map<String, String?> _nicknameCache = {};

  GroupChatViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    GetIt.instance<ActiveScreenTracker>().enterGroupChat(widget.group.groupId);
    GetIt.instance<NotificationService>().cancelGroupChatNotifications(widget.group.groupId);
    _viewModel.init(widget.group).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    GetIt.instance<ActiveScreenTracker>().exitChat();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _resolveNickname(String pubKey) async {
    if (_nicknameCache.containsKey(pubKey)) {
      return _nicknameCache[pubKey] ?? pubKey.substring(0, 8);
    }
    final nickname = await _viewModel.getNicknameForKey(pubKey);
    _nicknameCache[pubKey] = nickname;
    return nickname ?? pubKey.substring(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GroupEntity?>(
      stream: _viewModel.watchGroup(widget.group.groupId),
      builder: (context, groupSnapshot) {
        final group = groupSnapshot.data ?? widget.group;

        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.people),
                tooltip: 'Members',
                onPressed: () => _showMembersSheet(context, group),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: _buildMessageList(group)),
              if (group.isMember) _buildInputRow(group),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList(GroupEntity group) {
    if (_viewModel.myPublicKey == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<MessageEntity>>(
      stream: _viewModel.watchMessages(group),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!;
        if (messages.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) =>
              _buildMessageBubble(messages[index]),
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
            if (!isMe)
              FutureBuilder<String>(
                future: _resolveNickname(msg.senderId),
                builder: (context, snap) {
                  return Text(
                    snap.data ?? '...',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            Text(msg.payload, style: const TextStyle(fontSize: 16)),
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
        if (status == DeliveryStatus.failed)
          const Icon(Icons.error_outline, size: 14, color: Colors.red),
      ],
    );
  }

  Widget _buildInputRow(GroupEntity group) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Type a message...'),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(group),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(group),
          ),
        ],
      ),
    );
  }

  void _sendMessage(GroupEntity group) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _viewModel.sendMessage(group, text);
    _controller.clear();
  }

  void _showMembersSheet(BuildContext context, GroupEntity group) {
    final isCreator = group.isCreator;
    final myKey = _viewModel.myPublicKey;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Members (${group.memberPublicKeys.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...group.memberPublicKeys.map((key) {
                final isMe = key == myKey;
                final isGroupCreator = key == group.creatorPublicKey;

                return FutureBuilder<String>(
                  future: _resolveNickname(key),
                  builder: (context, snap) {
                    final name = snap.data ?? key.substring(0, 8);
                    return ListTile(
                      leading: Icon(
                        isGroupCreator ? Icons.star : Icons.person,
                        color: isGroupCreator ? Colors.amber : null,
                      ),
                      title: Text(isMe ? '$name (You)' : name),
                      trailing: (isCreator && !isMe)
                          ? IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _viewModel.kickMember(group, key);
                              },
                            )
                          : null,
                    );
                  },
                );
              }),
              const Divider(),
              if (isCreator)
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Invite Member'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showInvitePeerDialog(group);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text('Leave Group'),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmLeave(group);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInvitePeerDialog(GroupEntity group) {
    final radarVm = GetIt.instance<RadarViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => StreamBuilder<List<PeerEntity>>(
        stream: radarVm.watchPeers(),
        builder: (context, snapshot) {
          final peers = (snapshot.data ?? [])
              .where((p) =>
                  p.publicKey.isNotEmpty &&
                  !group.memberPublicKeys.contains(p.publicKey))
              .toList();

          return AlertDialog(
            title: const Text('Invite Peer'),
            content: SizedBox(
              width: double.maxFinite,
              child: peers.isEmpty
                  ? const Text('No available peers to invite')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: peers.length,
                      itemBuilder: (context, index) {
                        final peer = peers[index];
                        return ListTile(
                          title: Text(
                            peer.nickname ?? peer.publicKey.substring(0, 8),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            _viewModel.inviteMember(group, peer.publicKey);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Invited ${peer.nickname ?? 'peer'} to ${group.name}',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmLeave(GroupEntity group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Group?'),
        content: Text('Are you sure you want to leave "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _viewModel.leaveGroup(group);
              Navigator.pop(context); // Back to radar
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
