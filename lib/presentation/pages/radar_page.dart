
import 'package:flutter/material.dart';
import 'package:plane_messenger/core/user_prefs.dart';
import 'package:plane_messenger/data/datasources/local/isar_service.dart';
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

class _RadarPageState extends State<RadarPage> {
  String? _myNickname;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final nickname = await UserPrefs.getNickname();
    if (mounted) setState(() => _myNickname = nickname);
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
        : 'Tap ✏ to set your name';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SkyMesh Radar'),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
      body: StreamBuilder<List<PeerEntity>>(
        stream: isarService.watchPeers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Scanning for peers...'));
          }

          final peers = snapshot.data!;
          return GridView.builder(
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
              final displayName = peer.nickname ??
                  (peer.deviceId.length > 5
                      ? peer.deviceId.substring(0, 5)
                      : peer.deviceId);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(peer: peer),
                    ),
                  );
                },
                child: Card(
                  color: peer.isConnected
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
              );
            },
          );
        },
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
