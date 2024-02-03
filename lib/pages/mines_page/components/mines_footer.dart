import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mines/model/mines.dart';

class MinesFooter extends StatelessWidget {
  const MinesFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MinesGame>(
      builder: (context, minesGame, child) => Row(
        children: [
          ElevatedButton(
            onPressed: () {
              minesGame.resetGame();
            },
            child: const Text("New Game"),
          ),
          ElevatedButton(
            onPressed: () {
              minesGame.replayGame();
            },
            child: const Text("Try again"),
          ),
          ElevatedButton(
            onPressed: () {
              minesGame.toggleHints();
            },
            child: minesGame.showHints
                ? const Text("Hide hints")
                : const Text("Show hints"),
          ),
          ElevatedButton(
            onPressed: minesGame.canUndo
                ? () {
                    minesGame.undo();
                  }
                : null,
            child: const Text("Undo"),
          ),
        ],
      ),
    );
  }
}
