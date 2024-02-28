import 'dart:async';
import 'package:format/format.dart';
import 'package:flutter/foundation.dart';

/// The mines timer provides functionality for the mines game
/// the timer display and the life cycle methods.
class MinesTimeProvider extends ChangeNotifier {
  Timer? _timer;
  int _secondsSinceStart = 0;

  int get secondsSinceStart => _secondsSinceStart;

  /// To be called from the game
  void resetAndStartTimer() {
    resetTimerValue();
    _startTimer();
  }

  /// To be calld from the game
  void stopTimer() {
    _timer?.cancel();
  }

  /// To be called from the life cycle methods only
  void resumeTimer() {
    _startTimer();
  }

  /// To be called from the game
  void resetTimerValue() {
    _secondsSinceStart = 0;
    notifyListeners();
  }

  /// To be called from the game
  void _startTimer() {
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(milliseconds: 1000), _incrementSeconds);
  }

  void _incrementSeconds(Timer timer) {
    _secondsSinceStart++;
    notifyListeners();
  }

  @override
  String toString() {
    return format(
        '{:02d}:{:02d}', _secondsSinceStart ~/ 60, _secondsSinceStart % 60);
  }
}
