import 'dart:async';
import 'package:format/format.dart';
import 'package:flutter/material.dart';

class MinesTimer extends ChangeNotifier {
  bool _running = false;
  int _secondsSinceStart = 0;

  MinesTimer() {
    Timer.periodic(const Duration(milliseconds: 1000), _incrementSeconds);
  }

  void resetTimer() {
    stopTimer();
    _secondsSinceStart = 0;
    notifyListeners();
  }

  void stopTimer() {
    _running = false;
  }

  void startTimer() {
    _running = true;
  }

  String get time {
    return format(
        '{:02d}:{:02d}', _secondsSinceStart ~/ 60, _secondsSinceStart % 60);
  }

  void _incrementSeconds(Timer timer) {
    if (_running) {
      _secondsSinceStart++;
      notifyListeners();
    }
  }
}
