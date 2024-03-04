import 'package:flutter/material.dart';
import 'package:mines/pages/info/info_page.dart';
import 'package:mines/pages/settings/mobile_settings_page.dart';
import 'package:mines/provider/game_provider.dart';
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
                    onPressed: () {
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
                        IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MobileSettingsPage(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.info),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => InfoPage(),
                              ),
                            );
                          },
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
