import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plane_messenger/data/models/group_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/data/services/group_management_handler.dart';
import 'package:plane_messenger/main.dart';
import 'package:plane_messenger/presentation/notification_navigator.dart';
import 'package:plane_messenger/presentation/pages/chat_page.dart';
import 'package:plane_messenger/presentation/pages/create_group_page.dart';
import 'package:plane_messenger/presentation/pages/group_chat_page.dart';
import 'package:plane_messenger/presentation/viewmodels/chat_viewmodel.dart';
import 'package:plane_messenger/presentation/viewmodels/group_chat_viewmodel.dart';
import 'package:plane_messenger/presentation/viewmodels/radar_viewmodel.dart';

// Icon pool for peer cards. Selection is deterministic based on the peer's
// deviceId hash so the same peer always shows the same icon.
const _kPeerIcons = <IconData>[
  Icons.airplanemode_active,
  Icons.rocket_launch,
  Icons.paragliding,
  Icons.directions_boat,
  Icons.train,
  Icons.directions_car,
  Icons.directions_bike,
  Icons.electric_scooter,
  Icons.satellite_alt,
  Icons.cell_tower,
  Icons.radio,
  Icons.headphones,
];

IconData _iconForPeer(String deviceId) {
  final hash = deviceId.hashCode.abs();
  return _kPeerIcons[hash % _kPeerIcons.length];
}

class RadarPage extends StatefulWidget {
  const RadarPage({super.key});

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final RadarViewModel _viewModel;
  String? _selectedPeerId;

  late final AnimationController _wiggleController;
  late final Animation<double> _wiggleAnimation;

  StreamSubscription<String>? _serviceSubscription;
  StreamSubscription<PendingGroupInvite>? _groupInviteSub;
  bool _isServiceAlertShowing = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<RadarViewModel>();
    _viewModel.init().then((_) {
      if (mounted) setState(() {});
    });
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _wiggleAnimation = Tween<double>(begin: -0.035, end: 0.035).animate(
      CurvedAnimation(parent: _wiggleController, curve: Curves.easeInOut),
    );
    _subscribeToServiceEvents();
    _subscribeToGroupInvites();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigator.handlePendingNavigation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceSubscription?.cancel();
    _groupInviteSub?.cancel();
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.refreshDiscovery();
      NotificationNavigator.handlePendingNavigation();
    }
  }

  void _subscribeToServiceEvents() {
    _serviceSubscription = _viewModel.serviceEventStream.listen(
      (event) {
        if (mounted) _showServiceDisabledAlert(event);
      },
    );
  }

  void _subscribeToGroupInvites() {
    _groupInviteSub = _viewModel.pendingGroupInvites.listen((invite) {
      if (mounted) _showGroupInviteDialog(invite);
    });
  }

  Future<void> _showGroupInviteDialog(PendingGroupInvite invite) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Group Invite'),
        content: Text(
          '${invite.inviterNickname ?? 'Someone'} invited you to '
          '"${invite.groupName}"',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _viewModel.declineGroupInvite(invite);
            },
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _viewModel.acceptGroupInvite(invite);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  Future<void> _showServiceDisabledAlert(String event) async {
    if (_isServiceAlertShowing || !mounted) return;

    final String name;
    final String reason;
    final Future<void> Function() openSettings;

    switch (event) {
      case 'bluetooth_off':
        name = 'Bluetooth';
        reason = 'Bluetooth is essential for SkyMesh to discover and connect with nearby devices.';
        openSettings = _viewModel.openBluetoothSettings;
      case 'wifi_off':
        name = 'Wi-Fi';
        reason = 'Wi-Fi is essential for high-speed mesh communication in SkyMesh.';
        openSettings = _viewModel.openWifiSettings;
      case 'location_off':
        name = 'Location';
        reason = 'Location services are essential for peer discovery in SkyMesh.';
        openSettings = _viewModel.openLocationSettings;
      default:
        return;
    }

    _isServiceAlertShowing = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          title: Text('$name Disabled'),
          content: Text(reason),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Dismiss'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                openSettings();
              },
              child: Text('Turn On $name'),
            ),
          ],
        ),
      );
    } finally {
      _isServiceAlertShowing = false;
    }
  }

  void _selectPeer(String deviceId) {
    setState(() => _selectedPeerId = deviceId);
    _wiggleController.repeat(reverse: true);
  }

  void _deselectPeer() {
    if (_selectedPeerId == null) return;
    _wiggleController.stop();
    _wiggleController.reset();
    setState(() => _selectedPeerId = null);
  }

  Future<void> _deletePeer(PeerEntity peer) async {
    final displayName =
        peer.nickname ??
        (peer.deviceId.length > 5
            ? peer.deviceId.substring(0, 5)
            : peer.deviceId);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Peer'),
        content: Text(
          'Delete "$displayName" and all message history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    _deselectPeer();
    await _viewModel.deletePeer(peer);
  }

  Future<void> _deleteGroup(GroupEntity group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
          'Delete "${group.name}" and all messages? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    _deselectPeer();
    await _viewModel.deleteGroup(group);
  }

  Future<void> _showEditNicknameDialog() async {
    final saved = await showDialog<String>(
      context: context,
      builder: (_) => _NicknameDialog(initialValue: _viewModel.myNickname ?? ''),
    );

    if (saved != null && saved.isNotEmpty) {
      await _viewModel.changeNickname(saved);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final nickname = _viewModel.myNickname;
    final subtitle = nickname != null && nickname.isNotEmpty
        ? 'You: $nickname'
        : 'Tap \u270f to set your name';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SkyMesh Radar'),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit your display name',
            onPressed: _showEditNicknameDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateGroupPage(viewModel: _viewModel),
            ),
          );
        },
        child: const Icon(Icons.group_add),
      ),
      body: RefreshIndicator(
        onRefresh: _viewModel.refreshDiscovery,
        child: StreamBuilder<List<RadarItem>>(
          stream: _viewModel.watchRadarItems(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  ),
                ],
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Text(
                        'Scanning for peers...\nPull down to refresh',
                      ),
                    ),
                  ),
                ],
              );
            }

            final items = snapshot.data!;
            return NotificationListener<ScrollStartNotification>(
              onNotification: (_) {
                _deselectPeer();
                return false;
              },
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return switch (item) {
                    PeerRadarItem(:final peer) => _buildPeerCard(peer),
                    GroupRadarItem(:final group) => _buildGroupCard(group),
                  };
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPeerCard(PeerEntity peer) {
    final isSelected = _selectedPeerId == peer.deviceId;
    final displayName =
        peer.nickname ??
        (peer.deviceId.length > 5
            ? peer.deviceId.substring(0, 5)
            : peer.deviceId);

    final hasKey =
        peer.publicKey.isNotEmpty && _viewModel.myPublicKey != null;

    Widget card = Card(
      color: peer.isConnected
          ? Colors.green.shade100
          : Colors.grey.shade200,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasKey)
                  StreamBuilder<int>(
                    stream: _viewModel.watchUnreadCount(
                      peer.publicKey,
                      peer.lastReadTimestamp,
                    ),
                    builder: (context, snap) {
                      final count = snap.data ?? 0;
                      return Badge(
                        isLabelVisible: count > 0,
                        label: Text('$count'),
                        child: Icon(
                          _iconForPeer(peer.deviceId),
                          size: 40,
                        ),
                      );
                    },
                  )
                else
                  Icon(_iconForPeer(peer.deviceId), size: 40),
                const SizedBox(height: 8),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  peer.isConnected ? 'Connected' : 'Seen',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _deletePeer(peer),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    if (isSelected) {
      card = AnimatedBuilder(
        animation: _wiggleAnimation,
        builder: (context, child) => Transform.rotate(
          angle: _wiggleAnimation.value,
          child: child,
        ),
        child: card,
      );
    }

    return GestureDetector(
      onTap: () {
        if (_selectedPeerId != null) {
          _deselectPeer();
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              viewModel: getIt<ChatViewModel>(),
              peer: peer,
            ),
          ),
        );
      },
      onLongPress: () {
        if (isSelected) {
          _deselectPeer();
        } else {
          _selectPeer(peer.deviceId);
        }
      },
      child: card,
    );
  }

  Widget _buildGroupCard(GroupEntity group) {
    return GestureDetector(
      onTap: () {
        if (_selectedPeerId != null) {
          _deselectPeer();
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupChatPage(
              viewModel: getIt<GroupChatViewModel>(),
              group: group,
            ),
          ),
        );
      },
      onLongPress: () => _deleteGroup(group),
      child: Card(
        color: Colors.indigo.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<int>(
                stream: _viewModel.watchGroupUnreadCount(
                  group.groupId,
                  group.lastReadTimestamp,
                ),
                builder: (context, snap) {
                  final count = snap.data ?? 0;
                  return Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: const Icon(Icons.group, size: 40),
                  );
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                '${group.memberPublicKeys.length} members',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NicknameDialog extends StatefulWidget {
  const _NicknameDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<_NicknameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Your Display Name'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Nickname',
          hintText: 'Enter a name others will see...',
        ),
        maxLength: 32,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (value) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty) Navigator.pop(context, trimmed);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
