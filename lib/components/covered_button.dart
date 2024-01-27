import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mines/model/mines.dart';
import 'package:mines/model/mines_definitions.dart';

class MineButton extends StatefulWidget {
  final int x, y;
  final MinesGame game;

  const MineButton(this.x, this.y, this.game, {super.key});
  @override
  State<MineButton> createState() => _MineButttonState();
}

class _MineButttonState extends State<MineButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {
              if (isModifierPressed)
                {widget.game.toggleMayBeMine(widget.x, widget.y)}
              else
                {widget.game.uncoverField(widget.x, widget.y)}
            },
        onDoubleTap: () => {widget.game.toggleMayBeMine(widget.x, widget.y)},
        child: SizedBox(
            width: 500,
            height: 500,
            child: CustomPaint(
              painter:
                  _MineButtonPainter(widget.game.valueAt(widget.x, widget.y)),
            )));
  }

  bool isModifierPressed = false;

  void _handleKeyDown(RawKeyEvent event) {
    isModifierPressed =
        event.isShiftPressed || event.isControlPressed || event.isAltPressed;
  }

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKeyDown);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyDown);
    super.dispose();
  }
}

class _MineButtonPainter extends CustomPainter {
  _MineButtonPainter(this.fieldValue);
  int fieldValue;

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

    if (fieldValue > 100) {
      var ox = 0.1 * size.width, oy = 0.1 * size.height;

      var paint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill;
      var rect =
          Rect.fromLTWH(ox, oy, size.width - 2 * ox, size.height - 2 * oy);
      canvas.drawRect(rect, paint);
      fieldValue = fieldValue % 150;
    }

    if (fieldValue == covered) {
      paintCovered(canvas, size);
    } else if (fieldValue == mine) {
      paintMine(canvas, size);
    } else if (fieldValue == maybeMine) {
      paintMayBeMine(canvas, size);
    } else if (fieldValue >= one && fieldValue <= eight) {
      paintField(canvas, size, fieldValue);
    } else if (fieldValue == notMaybeMine) {
      paintNotMayBeMine(canvas, size);
    }
  }

  void paintMine(Canvas canvas, Size size) {
    paintField(canvas, size, mine, anyChar: 'm');
  }

  void paintMayBeMine(Canvas canvas, Size size) {
    paintField(canvas, size, mine, anyChar: 'f');
  }

  void paintNotMayBeMine(Canvas canvas, Size size) {
    paintField(canvas, size, mine, anyChar: 'nf');
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
    paint.strokeWidth = 2;
    canvas.drawRect(Rect.fromLTRB(1, 1, size.width, size.height), paint);
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
