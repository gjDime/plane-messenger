import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plane_messenger/core/security/key_manager.dart';
import 'package:plane_messenger/core/user_prefs.dart';
import 'package:plane_messenger/data/datasources/local/isar_service.dart';
import 'package:plane_messenger/data/datasources/p2p/connection_manager.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/data/repositories/mesh_repository_impl.dart';
import 'package:plane_messenger/presentation/pages/chat_page.dart';
import 'package:plane_messenger/main.dart';

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
    with SingleTickerProviderStateMixin {
  static const _serviceEvents = EventChannel('com.plane.messenger/service_events');
  static const _systemChannel = MethodChannel('com.plane.messenger/system');

  String? _myNickname;
  String? _myPublicKey;
  String? _selectedPeerId;

  late final AnimationController _wiggleController;
  late final Animation<double> _wiggleAnimation;

  StreamSubscription<dynamic>? _serviceSubscription;
  bool _isServiceAlertShowing = false;

  @override
  void initState() {
    super.initState();
    _loadNickname();
    _loadMyPublicKey();
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _wiggleAnimation = Tween<double>(begin: -0.035, end: 0.035).animate(
      CurvedAnimation(parent: _wiggleController, curve: Curves.easeInOut),
    );
    _subscribeToServiceEvents();
  }

  @override
  void dispose() {
    _serviceSubscription?.cancel();
    _wiggleController.dispose();
    super.dispose();
  }

  void _subscribeToServiceEvents() {
    _serviceSubscription = _serviceEvents.receiveBroadcastStream().listen(
      (event) {
        if (mounted) _showServiceDisabledAlert(event as String);
      },
    );
  }

  Future<void> _showServiceDisabledAlert(String event) async {
    if (_isServiceAlertShowing || !mounted) return;

    final String name;
    final String reason;
    final String settingsMethod;

    switch (event) {
      case 'bluetooth_off':
        name = 'Bluetooth';
        reason = 'Bluetooth is essential for SkyMesh to discover and connect with nearby devices.';
        settingsMethod = 'openBluetoothSettings';
      case 'wifi_off':
        name = 'Wi-Fi';
        reason = 'Wi-Fi is essential for high-speed mesh communication in SkyMesh.';
        settingsMethod = 'openWifiSettings';
      case 'location_off':
        name = 'Location';
        reason = 'Location services are essential for peer discovery in SkyMesh.';
        settingsMethod = 'openLocationSettings';
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
                _systemChannel.invokeMethod(settingsMethod);
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

  Future<void> _loadNickname() async {
    final nickname = await UserPrefs.getNickname();
    if (mounted) setState(() => _myNickname = nickname);
  }

  Future<void> _loadMyPublicKey() async {
    final key = await getIt<KeyManager>().publicKeyBase64;
    if (mounted) setState(() => _myPublicKey = key);
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

    final isarService = getIt<IsarService>();

    // Disconnect if currently connected.
    if (peer.isConnected) {
      await getIt<ConnectionManager>().disconnectFromEndpoint(peer.deviceId);
    }

    // Delete messages exchanged with this peer.
    if (peer.publicKey.isNotEmpty) {
      final myPublicKey = await getIt<KeyManager>().publicKeyBase64;
      await isarService.deleteMessagesForPeer(peer.publicKey, myPublicKey);
    }

    // Delete the peer record.
    await isarService.deletePeer(peer.deviceId);
  }

  Future<void> _showEditNicknameDialog() async {
    // _NicknameDialog is a StatefulWidget that owns its TextEditingController.
    // The framework calls its dispose() at the right point during the pop
    // animation, avoiding the _dependents.isEmpty assertion that occurs when
    // a controller is disposed externally while the TextField is still rendering.
    final saved = await showDialog<String>(
      context: context,
      builder: (_) => _NicknameDialog(initialValue: _myNickname ?? ''),
    );

    if (saved != null && saved.isNotEmpty) {
      await UserPrefs.saveNickname(saved);
      getIt<MeshRepositoryImpl>().broadcastNicknameUpdate(saved);
      if (mounted) setState(() => _myNickname = saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isarService = getIt<IsarService>();
    final subtitle = _myNickname != null && _myNickname!.isNotEmpty
        ? 'You: $_myNickname'
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
      body: RefreshIndicator(
        onRefresh: () => getIt<MeshRepositoryImpl>().restartDiscovery(),
        child: StreamBuilder<List<PeerEntity>>(
          stream: isarService.watchPeers(),
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

            final peers = snapshot.data!;
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
                itemCount: peers.length,
                itemBuilder: (context, index) {
                  final peer = peers[index];
                  final isSelected = _selectedPeerId == peer.deviceId;
                  final displayName =
                      peer.nickname ??
                      (peer.deviceId.length > 5
                          ? peer.deviceId.substring(0, 5)
                          : peer.deviceId);

                  final hasKey =
                      peer.publicKey.isNotEmpty && _myPublicKey != null;

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
                                  stream:
                                      isarService.watchUnreadCountForPeer(
                                        peer.publicKey,
                                        _myPublicKey!,
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
                          builder: (context) => ChatPage(peer: peer),
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
                },
              ),
            );
          },
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
