import 'package:flutter/material.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/presentation/viewmodels/radar_viewmodel.dart';

class CreateGroupPage extends StatefulWidget {
  final RadarViewModel viewModel;

  const CreateGroupPage({super.key, required this.viewModel});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedKeys = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter a group name...',
              ),
              onChanged: (_) => setState(() {}),
              maxLength: 32,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select members:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PeerEntity>>(
              stream: widget.viewModel.watchPeers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final peers = snapshot.data!
                    .where((p) => p.publicKey.isNotEmpty)
                    .toList();

                if (peers.isEmpty) {
                  return const Center(
                    child: Text('No peers with completed handshake'),
                  );
                }

                return ListView.builder(
                  itemCount: peers.length,
                  itemBuilder: (context, index) {
                    final peer = peers[index];
                    final isSelected = _selectedKeys.contains(peer.publicKey);
                    final displayName = peer.nickname ?? peer.publicKey.substring(0, 8);

                    return CheckboxListTile(
                      title: Text(displayName),
                      subtitle: Text(
                        peer.isConnected ? 'Connected' : 'Offline',
                      ),
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedKeys.add(peer.publicKey);
                          } else {
                            _selectedKeys.remove(peer.publicKey);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canCreate ? _createGroup : null,
                child: const Text('Create Group'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canCreate =>
      _nameController.text.trim().isNotEmpty && _selectedKeys.isNotEmpty;

  void _createGroup() {
    final name = _nameController.text.trim();
    widget.viewModel.createGroup(name, _selectedKeys.toList());
    Navigator.pop(context);
  }
}
