import 'package:flutter/foundation.dart';

enum MinesGameState { uninitialized, solvable, solvableWithGuess, won, lost }

class MinesGameStateProvider extends ChangeNotifier {
  MinesGameState _state = MinesGameState.uninitialized;

  MinesGameState get state => _state;

  void set state(MinesGameState newState) {
    _state = newState;
    notifyListeners();
  }
}
