import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class ImageProvider {
  ui.Image? image;

  Future<ui.Image> loadImage(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    return await decodeImageFromList(bytes);
  }
}
