
import 'package:flutter/material.dart';
import 'package:plane_messenger/data/datasources/local/isar_service.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/presentation/pages/chat_page.dart';
import 'package:plane_messenger/main.dart';

class RadarPage extends StatelessWidget {
  const RadarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isarService = getIt<IsarService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SkyMesh Radar'),
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
                      const Icon(Icons.airplanemode_active, size: 40),
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
