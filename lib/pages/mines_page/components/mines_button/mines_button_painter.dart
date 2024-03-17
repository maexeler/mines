import 'dart:ui';
import 'package:vector_math/vector_math.dart';

void minePainter(Canvas canvas, Size size, double offset, bool exploded) {
  Paint paint = Paint()..color = Color(0xff000000);
  Rect rect = Rect.fromLTWH(offset, offset, size.width - 2 * offset + 1,
      size.height - 2 * offset + 1);
  if (exploded) {
    paint.color = Color(0xffff0000);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width - 1, size.height - 1), paint);
  }
  Offset center = Offset(size.width / 2, size.height / 2);

  paint.color = Color(0xff000000);
  canvas.drawCircle(center, 0.75 * (rect.height / 2), paint);

  paint.strokeWidth = 4;
  double spikeX = size.width / 2 - (1.5 * offset);
  double spikey = size.height / 2 - (1.5 * offset);
  canvas.drawLine(Offset(center.dx - spikeX, center.dy),
      Offset(center.dx + spikeX, center.dy), paint);
  canvas.drawLine(Offset(center.dx, center.dy - spikey),
      Offset(center.dx, center.dy + spikey), paint);
  const sqrt2 = 0.707;
  spikeX -= offset / 2;
  spikey -= offset / 2;
  paint.strokeWidth = 3;
  canvas.drawLine(
      Offset(center.dx - sqrt2 * spikeX, center.dy - sqrt2 * spikey),
      Offset(center.dx + sqrt2 * spikeX, center.dy + sqrt2 * spikey),
      paint);
  canvas.drawLine(
      Offset(center.dx - sqrt2 * spikeX, center.dy + sqrt2 * spikey),
      Offset(center.dx + sqrt2 * spikeX, center.dy - sqrt2 * spikey),
      paint);
  paint.color = Color(0xffffffff);
  canvas.drawCircle(
      Offset((rect.left + rect.right) / 2.5, (rect.top + rect.bottom) / 2.8),
      0.25 * (rect.height / 2),
      paint);
}

void flagPainter(Canvas canvas, Size size, double offset,
    {bool isNotMayBeMine = false}) {
  double scale = size.width - (2 * offset);

  Matrix4 mtranslate = Matrix4.identity();
  mtranslate.translate(offset, offset, 0);

  Matrix4 mscale = Matrix4.identity();
  mscale.scale(scale);

  // Create flag path

  List<Vector3> flagVects = [
    Vector3(0.175, 0.25, 0),
    Vector3(0.575, 0.5, 0),
    Vector3(0.575, 0.0, 0)
  ];

  var trFlagVects = flagVects
      .map((vect) => mscale.transform3(vect))
      .map((vect) => mtranslate.transform3(vect))
      .map((trVec) => (trVec[0], trVec[1]))
      .toList();

  Path flag = Path()
    ..moveTo(trFlagVects[0].$1, trFlagVects[0].$2)
    ..lineTo(trFlagVects[1].$1, trFlagVects[1].$2)
    ..lineTo(trFlagVects[2].$1, trFlagVects[2].$2)
    ..close();

  // Create post path

  var postVects = [
    Vector3(0.125, 1.0, 0),
    Vector3(0.875, 1.0, 0),
    Vector3(0.875, 0.85, 0),
    Vector3(0.725, 0.85, 0),
    Vector3(0.725, 0.75, 0),
    Vector3(0.525, 0.75, 0),
    Vector3(0.525, 0.35, 0),
    Vector3(0.425, 0.35, 0),
    Vector3(0.425, 0.75, 0),
    Vector3(0.275, 0.75, 0),
    Vector3(0.275, 0.85, 0),
    Vector3(0.125, 0.85, 0),
  ];

  var trPostVects = postVects
      .map((vect) => mscale.transform3(vect))
      .map((vect) => mtranslate.transform3(vect))
      .map((trVec) => (trVec[0], trVec[1]))
      .toList();

  Path post = Path()..moveTo(trPostVects[0].$1, trPostVects[0].$2);
  for (var elem in trPostVects.skip(1)) {
    post.lineTo(elem.$1, elem.$2);
  }
  post.close();

  Paint paint = Paint();
  paint.color = Color(0xff000000);
  canvas.drawPath(post, paint);

  paint.color = Color(0xffff0000);
  canvas.drawPath(flag, paint);

  if (isNotMayBeMine) {
    paint.color = Color(0xff000000);
    paint.strokeWidth = 1;
    canvas.drawLine(Offset(offset, offset),
        Offset(size.width - offset, size.height - offset), paint);
    canvas.drawLine(Offset(size.width - offset, offset),
        Offset(offset, size.height - offset), paint);
  }
}
