import 'package:flutter/foundation.dart';

class RemainingMinesProvider extends ChangeNotifier {
  int _remainingMines = 0;

  void reset() {
    remainingMines = 0;
  }

  int get remainingMines => _remainingMines;

  void set remainingMines(int remainingMines) {
    _remainingMines = remainingMines;
    notifyListeners();
  }
}
