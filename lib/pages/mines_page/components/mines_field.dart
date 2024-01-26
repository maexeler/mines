import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mines/components/covered_button.dart';
import 'package:provider/provider.dart';

import 'package:mines/model/mines.dart';

class MinesField extends StatelessWidget {
  const MinesField({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MinesGame>(
      builder: (context, minesGame, child) {
        int w = minesGame.width;
        int h = minesGame.height;
        return MinesFieldLayout(w, h, minesGame);
      },
    );
  }
}

class MinesFieldLayout extends StatelessWidget {
  const MinesFieldLayout(this.w, this.h, this.minesGame, {super.key});
  final int w, h;
  final MinesGame minesGame;

  @override
  Widget build(BuildContext context) {
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

class _MinesFieldLayoutDelegate extends MultiChildLayoutDelegate {
  _MinesFieldLayoutDelegate(this.w, this.h);
  final int w, h;

  @override
  void performLayout(Size size) {
    var fieldSize = min(size.width / w, size.height / h);
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
        positionChild((x: x, y: y), Offset(x * fieldSize, y * fieldSize));
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
