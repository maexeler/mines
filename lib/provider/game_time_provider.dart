import 'dart:async';
import 'package:format/format.dart';
import 'package:flutter/foundation.dart';

/// The mines timer provides functionality for the mines game
/// the timer display and the life cycle methods.
class MinesTimeProvider extends ChangeNotifier {
  Timer? _timer;
  int _secondsSinceStart = 0;

  /// To be called from the game
  void resetTimer() {
    stopTimer();
    _secondsSinceStart = 0;
    notifyListeners();
  }

  /// To be called from the game
  void startTimer() {
    resetTimer();
    _timer =
        Timer.periodic(const Duration(milliseconds: 1000), _incrementSeconds);
  }

  /// To be calld from the game
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// To be called from the life cycle methods only
  void suspendTimer() {
    _timer?.cancel();
  }

  /// To be called from the life cycle methods only
  void resumeTimer() {
    // If there was a timer running previously, restart it.
    if (_timer != null) {
      stopTimer();
      startTimer();
    }
  }

  @override
  String toString() {
    return format(
        '{:02d}:{:02d}', _secondsSinceStart ~/ 60, _secondsSinceStart % 60);
  }

  int get secondsSinceStart => _secondsSinceStart;

  void _incrementSeconds(Timer timer) {
    _secondsSinceStart++;
    notifyListeners();
  }
}
