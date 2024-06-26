import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:Minesweeper/pages/mines_page/components/mines_button/mines_button.dart';
import 'package:Minesweeper/provider/game_provider.dart';
import 'package:Minesweeper/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class MinesFieldWidget extends StatelessWidget {
  const MinesFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MinesFieldLayout();
  }
}

class MinesFieldLayout extends StatelessWidget {
  const MinesFieldLayout({super.key});

  @override
  Widget build(BuildContext context) {
    GameProvider game = Provider.of<GameProvider>(context);
    // We are not ready to show the game contents
    if (game.isStarting) {
      return Container();
    } else
    // Calculate the game size for the given display space
    if (game.needsRecalculationOfGameDimensions) {
      var settings = Provider.of<SettingsProvider>(context);
      return CustomMultiChildLayout(
        delegate: _MinesFieldLayoutCalculatorDelegate(game, settings),
        children: [
          LayoutId(
            id: 'body',
            child: Container(),
          ),
        ],
      );
    } else if (game.isSolving) {
      return Stack(
        children: [
          gameContent(game),
          Center(
            child: const CircularProgressIndicator(),
          )
        ],
      );
    } else {
      return gameContent(game);
    }
  }
}

Widget gameContent(GameProvider game) {
  // Render the game content
  int w = game.width, h = game.height;
  Map<({int x, int y}), MineButton> fields = {};
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      fields[(x: x, y: y)] = MineButton(x, y, game);
    }
  }
  return CustomMultiChildLayout(
    delegate: _MinesFieldLayoutDelegate(w, h),
    children: <Widget>[
      for (final MapEntry<({int x, int y}), MineButton> entry in fields.entries)
        LayoutId(
          id: entry.key,
          child: entry.value,
        ),
    ],
  );
}

class _MinesFieldLayoutCalculatorDelegate extends MultiChildLayoutDelegate {
  _MinesFieldLayoutCalculatorDelegate(this.game, this.settings);
  final GameProvider game;
  final SettingsProvider settings;

  @override
  void performLayout(Size size) {
    int w, h;
    var shortSide = size.shortestSide;
    var longestSide = size.longestSide;
    if (size.width < size.height) {
      // Portrait mode
      var cellSize =
          SettingsProvider.calcCellSize(shortSide, settings.percentCellSize);
      w = (shortSide / cellSize).floor();
      h = (longestSide / cellSize).floor();
    } else {
      // Landscape mode
      var cellSize = SettingsProvider.calcCellSize(
          shortSide, settings.percentCellSize * size.aspectRatio);
      h = (shortSide / cellSize).floor();
      w = (longestSide / cellSize).floor();
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      game.changeGameDimensions(w, h);
      // print('GameDimensions($w,$h)');
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
    // print('layout dimensions($w,$h)');
    double fieldSize = min(size.width / w, size.height / h);

    // In case it doesn't fit, center it
    double dx;
    if (size.width < size.height) {
      // Portrait mode
      dx = (size.shortestSide - (fieldSize * w)) / 2;
    } else {
      // landscape mode
      dx = (size.longestSide - (fieldSize * w)) / 2;
    }

    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        // layoutChild must be called exactly once for each child.
        layoutChild(
          (x: x, y: y),
          BoxConstraints(maxHeight: fieldSize, maxWidth: fieldSize),
        );
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
