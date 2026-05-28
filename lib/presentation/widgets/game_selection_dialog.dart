import 'package:flutter/material.dart';

class GameSelectionDialog extends StatelessWidget {
  const GameSelectionDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const GameSelectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose a Game'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.grid_on),
            title: const Text('Tic Tac Toe'),
            onTap: () => Navigator.pop(context, 'tictactoe'),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Color Memory'),
            onTap: () => Navigator.pop(context, 'color_memory'),
          ),
          ListTile(
            leading: const Icon(Icons.directions_boat),
            title: const Text('Battleship'),
            onTap: () => Navigator.pop(context, 'battleship'),
          ),
        ],
      ),
    );
  }
}
