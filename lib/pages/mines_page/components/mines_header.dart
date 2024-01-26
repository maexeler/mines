import 'package:flutter/material.dart';
import 'package:mines/model/mines_definitions.dart';
import 'package:provider/provider.dart';

import 'package:mines/model/mines.dart';
import 'package:mines/model/mines_timer.dart';

class MinesHeader extends StatelessWidget {
  const MinesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TimerDisplay(),
        Expanded(child: _StatusDisplay()),
        _RemainingMinesDisplay()
      ],
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MinesTimer>(
      builder: (context, minesTimer, child) => Text(minesTimer.time),
    );
  }
}

class _StatusDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MinesGame>(
      builder: (context, minesGame, child) => Center(
          child: Text(
        minesGame.gameStatus == GameStat.gameOver
            ? '🙁'
            : '${minesGame.gameStatus}',
      )),
    );
  }
}

class _RemainingMinesDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MinesGame>(
      builder: (context, minesGame, child) => const Text('000'),
    );
  }
}
