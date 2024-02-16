import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mines/components/covered_button.dart';
import 'package:mines/model/mines_definitions.dart';
import 'package:mines/pages/settings/settings_provider.dart';
import 'package:provider/provider.dart';

import 'package:mines/model/mines.dart';

class MinesFieldWidget extends StatelessWidget {
  const MinesFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MinesGame>(
      builder: (context, minesGame, child) {
        return MinesFieldLayout(minesGame);
      },
    );
  }
}

class MinesFieldLayout extends StatelessWidget {
  const MinesFieldLayout(this.minesGame, {super.key});
  final MinesGame minesGame;

  @override
  Widget build(BuildContext context) {
    int w = minesGame.width, h = minesGame.height;
    if (minesGame.gameStatus == GameStat.unInitialized) {
      var settings = Provider.of<SettingsProvider>(context);
      print('settings.percentCellSize ${settings.percentCellSize}');
      return CustomMultiChildLayout(
        delegate: _MinesFieldLayoutCalculatorDelegate(minesGame, settings),
        children: [
          LayoutId(
            id: 'body',
            child: Container(),
          ),
        ],
      );
    }

    Map<({int x, int y}), MineButton> fields = {};
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        fields[(x: x, y: y)] = MineButton(x, y, minesGame);
      }
    }

    return CustomMultiChildLayout(
      delegate: _MinesFieldLayoutDelegate(w, h),
      children: <Widget>[
        for (final MapEntry<({int x, int y}), MineButton> entry
            in fields.entries)
          LayoutId(
            id: entry.key,
            child: entry.value,
          ),
      ],
    );
  }
}

class _MinesFieldLayoutCalculatorDelegate extends MultiChildLayoutDelegate {
  _MinesFieldLayoutCalculatorDelegate(this.minesGame, this.settings);
  final MinesGame minesGame;
  final SettingsProvider settings;

  @override
  void performLayout(Size size) {
    var shortSide = size.shortestSide;
    var longestSide = size.longestSide;
    var cellSize = settings.calcCellSize(shortSide);
    int w = (shortSide / cellSize).floor();
    int h = (longestSide / cellSize).floor();
    print('_MinesFieldLayoutCalculatorDelegate ${w}, ${h}');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      minesGame.changeGameDimensions(w, h);
    });

    layoutChild(
      'body',
      BoxConstraints(maxHeight: size.height, maxWidth: size.width),
    );
    positionChild('body', Offset(0, 0));
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

class _MinesFieldLayoutDelegate extends MultiChildLayoutDelegate {
  _MinesFieldLayoutDelegate(this.w, this.h);
  final int w, h;

  @override
  void performLayout(Size size) {
    var fieldSize = min(size.width / w, size.height / h);
    double dx = (size.shortestSide - (fieldSize * w)) / 2;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        // layoutChild must be called exactly once for each child.
        layoutChild(
          (x: x, y: y),
          BoxConstraints(maxHeight: fieldSize, maxWidth: fieldSize),
        );
        // assert(currentSize == Size(fieldSize, fieldSize));
        // positionChild must be called to change the position of a child from
        // what it was in the previous layout. Each child starts at (0, 0) for
        // the first layout.
        // print('$x, $y $currentSize');
        positionChild(
            (x: x, y: y), Offset(dx + (x * fieldSize), y * fieldSize));
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
