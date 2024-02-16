import 'package:flutter/material.dart';
import 'package:mines/model/mines_definitions.dart';
import 'package:provider/provider.dart';

import 'package:mines/model/mines.dart';
import 'package:mines/model/mines_timer.dart';

class MinesHeader extends StatelessWidget {
  const MinesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return _HeaderBorder(
      child: Stack(
        children: [
          Row(
            children: [
              _TimerDisplay(),
              Expanded(child: Container()),
              _RemainingMinesDisplay()
            ],
          ),
          _StatusDisplay(),
        ],
      ),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MinesTimer>(
      builder: (context, minesTimer, child) => Text(
        '${minesTimer.time}',
        style: Theme.of(context).textTheme.displaySmall,
      ),
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
              : minesGame.gameStatus == GameStat.win
                  ? '😀😀'
                  : '😀',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
    );
  }
}

class _RemainingMinesDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MinesGame>(builder: (context, minesGame, child) {
      var mines = ((minesGame.remainingMines ~/ 10) == 0)
          ? '0${minesGame.remainingMines}'
          : '${minesGame.remainingMines}';
      return Text(
        mines,
        style: Theme.of(context).textTheme.displaySmall,
      );
    });
  }
}

class _HeaderBorder extends StatelessWidget {
  final Widget child;

  _HeaderBorder({required Widget child}) : child = child;

  @override
  Widget build(BuildContext context) {
    final double width = 3;
    return Container(
      // padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        // Set a border for each side of the box
        border: Border(
          top: BorderSide(width: width, color: Colors.grey.shade500),
          left: BorderSide(width: width, color: Colors.grey.shade500),
          right: BorderSide(width: width, color: Colors.white),
          bottom: BorderSide(width: width, color: Colors.white),
        ),
      ),
      child: child,
    );
  }
}
