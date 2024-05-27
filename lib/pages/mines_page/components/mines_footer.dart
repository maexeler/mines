import 'package:flutter/material.dart';
import 'package:Minesweeper/pages/info/info_page.dart';
import 'package:Minesweeper/pages/settings/settings_page.dart';
import 'package:Minesweeper/provider/game_provider.dart';
import 'package:provider/provider.dart';

class MinesFooter extends StatelessWidget {
  const MinesFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, minesGame, child) => Container(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  IconButton(
                    onPressed: minesGame.isSolving
                        ? null
                        : () {
                            minesGame.resetGame();
                          },
                    icon: Icon(Icons.play_circle),
                  ),
                  IconButton(
                    onPressed: minesGame.canReplayGame
                        ? () {
                            minesGame.replayGame();
                          }
                        : null,
                    icon: Icon(Icons.replay_circle_filled),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PopupMenuButton(
                          icon: Icon(Icons.settings),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text('About'),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => InfoPage(),
                                  ),
                                );
                              },
                            ),
                            PopupMenuItem(
                              child: Text('Layout'),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LayoutSettingsPage(),
                                  ),
                                );
                              },
                            ),
                            PopupMenuItem(
                              child: Text('Difficulty'),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DifficultySettingsPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
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
      ),
    );
  }
}
