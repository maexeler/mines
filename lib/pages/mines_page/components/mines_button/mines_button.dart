import 'dart:math';
import 'package:flutter/material.dart';

import 'package:Minesweeper/model/mines_definitions.dart';
import 'package:Minesweeper/pages/mines_page/components/mines_button/mines_button_painter.dart';
import 'package:Minesweeper/provider/game_provider.dart';

class MineButton extends StatelessWidget {
  final int x, y;
  final GameProvider game;

  const MineButton(this.x, this.y, this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {game.uncoverField(x, y)},
      onLongPress: () => {game.toggleMayBeMine(x, y)},
      child: SizedBox(
        width: 500,
        height: 500,
        child: CustomPaint(
          painter: _MineButtonPainter(
            game.fieldValueAt(x, y),
            y == 0,
          ),
        ),
      ),
    );
  }
}

class MineButtonDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 500,
        height: 500,
        child: CustomPaint(
          painter: _MineButtonPainter(
              FieldValue()..value = FieldValue.covered, false),
        ));
  }
}

class _MineButtonPainter extends CustomPainter {
  _MineButtonPainter(this.fieldValue, this.isTopRow);
  final FieldValue fieldValue;
  final bool isTopRow;

  static Color greyLite = Colors.white;
  static Color greyButton = Colors.grey.shade300;
  static Color greyDark = Colors.grey.shade500;
  static List<Color> valueColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.blue.shade900,
    Colors.brown.shade700,
    Colors.red.shade300,
    Colors.pink.shade800,
    Colors.green.shade200,
  ];

  Color _getValuColor(int value) {
    if (value < 1 || value > 8) {
      return Colors.black;
    }
    return valueColors[value - 1];
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintEmpty(canvas, size);

    if (fieldValue.isHint) {
      var ox = 0.1 * size.width, oy = 0.1 * size.height;

      var paint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill;
      var rect =
          Rect.fromLTWH(ox, oy, size.width - 2 * ox, size.height - 2 * oy);
      canvas.drawRect(rect, paint);
    }

    if (fieldValue.isCovered) {
      paintCovered(canvas, size);
    } else if (fieldValue.isMine) {
      paintMine(canvas, size, fieldValue.isExploded);
    } else if (fieldValue.isMaybeMine) {
      paintMayBeMine(canvas, size, false);
    } else if (fieldValue.isNumber) {
      paintField(canvas, size, fieldValue.value);
    } else if (fieldValue.isNotAMaybeMine) {
      paintMayBeMine(canvas, size, true);
    }
  }

  void paintMine(Canvas canvas, Size size, bool exploded) {
    minePainter(canvas, size, 0.05 * size.width, exploded);
  }

  void paintMayBeMine(Canvas canvas, Size size, bool isNotMayBeMine) {
    paintCovered(canvas, size);
    flagPainter(canvas, size, 0.15 * size.width,
        isNotMayBeMine: isNotMayBeMine);
  }

  void paintField(Canvas canvas, Size size, int value, {String? anyChar}) {
    var ox = 0.1 * size.width, oy = 0.1 * size.height;

    var textStyle = TextStyle(
      color: _getValuColor(value),
      fontSize: min(size.width - 2 * ox, size.height - 2 * oy),
    );
    final textSpan = TextSpan(
      text: anyChar ?? '$value',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    var textSize = textPainter.size;
    final offset = Offset(
        (size.width - textSize.width) / 2, (size.height - textSize.height) / 2);
    textPainter.paint(canvas, offset);
  }

  void paintEmpty(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = greyButton
      ..style = PaintingStyle.fill;
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);

    paint.color = greyDark;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  void paintCovered(Canvas canvas, Size size) {
    double w = size.width, h = size.height;
    // 10 % for elevation drawing
    double dx = 0.1 * w, dy = 0.1 * h;

    var paint = Paint()
      ..color = greyButton
      ..style = PaintingStyle.fill;
    var rect = Rect.fromLTWH(dx, dy, w - 2 * dx, h - 2 * dy);
    canvas.drawRect(rect, paint);

    Path path;
    paint.color = greyDark;
    path = Path()
      ..moveTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w, 0)
      ..lineTo(w - dx, dy)
      ..lineTo(w - dx, h - dy)
      ..lineTo(dx, h - dy)
      ..lineTo(0, h);
    canvas.drawPath(path, paint);

    paint.color = greyLite;
    path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - dx, dy)
      ..lineTo(dx, dy)
      ..lineTo(dx, h - dy)
      ..lineTo(0, h);
    canvas.drawPath(path, paint);

    if (isTopRow) {
      paint.color = greyDark;
      paint.strokeWidth = 1;
      canvas.drawLine(Offset(0, 1), Offset(w, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
