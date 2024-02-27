import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mines/provider/game_time_provider.dart';
import 'package:mines/provider/game_status_provider.dart';
import 'package:mines/provider/game_remaining_mines_provider.dart';

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
    return Consumer<MinesTimeProvider>(
      builder: (context, minesTimer, child) => Text(
        '${minesTimer}',
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}

class _StatusDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MinesGameStateProvider>(
      builder: (context, minesState, child) {
        String text = '';
        switch (minesState.state) {
          case MinesGameState.won:
            text = '😀😀';
          case MinesGameState.lost:
            text = '🙁🙁';
          case MinesGameState.solvable:
            text = '😀';
          case MinesGameState.solvableWithGuess:
            text = '😐';
          case MinesGameState.uninitialized:
            text = '';
        }
        return Center(
            child: Text(text, style: Theme.of(context).textTheme.displaySmall));
      },
    );
  }
}

class _RemainingMinesDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RemainingMinesProvider>(
        builder: (context, remainingMines, child) {
      var mines = ((remainingMines.remainingMines ~/ 10) == 0)
          ? '0${remainingMines.remainingMines}'
          : '${remainingMines.remainingMines}';
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
