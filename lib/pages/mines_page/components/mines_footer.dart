import 'package:flutter/material.dart';
import 'package:mines/pages/settings/mobile_settings_page.dart';
import 'package:provider/provider.dart';

import 'package:mines/model/mines.dart';

class MinesFooter extends StatelessWidget {
  const MinesFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MinesGame>(
      builder: (context, minesGame, child) => Row(
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    minesGame.resetGame();
                  },
                  icon: Icon(Icons.play_circle),
                ),
                IconButton(
                  onPressed: () {
                    minesGame.replayGame();
                  },
                  icon: Icon(Icons.replay_circle_filled),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MobileSettingsPage(),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    minesGame.toggleHints();
                  },
                  icon: Icon(Icons.help),
                ),
                IconButton(
                  onPressed: minesGame.canUndo
                      ? () {
                          minesGame.undo();
                        }
                      : null,
                  icon: Icon(Icons.undo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
