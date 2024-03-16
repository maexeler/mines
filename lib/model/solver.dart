import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mines/model/mines_logic.dart';

Future<GameField> getNewGameField(
    int w, int h, int xs, int ys, double percent, int timeOut) async {
  return await compute((_) {
    DateTime later = DateTime.now().add(Duration(seconds: timeOut));

    GameField gameField;
    MineField mineField;
    // Generate a game and try to solve it
    do {
      // Generate new game field
      mineField = MineField(w, h);
      mineField.intitMineField(xs, ys, percent);
      gameField = GameField(w, h);
      gameField.initFromMineField(mineField, xs, ys);
    } while (!gameField.isGameSolvable() && later.isAfter(DateTime.now()));
/*
  if (kDebugMode) {
    print('Game solved: ${later.isAfter(DateTime.now())}');
    gameField.dump();
  }
*/
    // now reset the game field but retain its solvable state
    var solvable = gameField.state;
    gameField.initFromMineField(mineField, xs, ys);
    gameField.state = solvable;
    return gameField;
  }, null);
}
