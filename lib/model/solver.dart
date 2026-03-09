import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:Minesweeper/model/mines_logic.dart';

Future<GameField> createSolvableGameField(
  int w,
  int h,
  int xs,
  int ys,
  double percent,
  bool is8FieldGame,
  int timeout,
) async {
  return await _createSolvableGameField(
    w,
    h,
    xs,
    ys,
    percent,
    is8FieldGame,
  ).timeout(
    Duration(seconds: timeout),
    onTimeout: () => createGameField(w, h, xs, ys, percent, is8FieldGame),
  );
}

Future<GameField> _createSolvableGameField(
  int w,
  int h,
  int xs,
  int ys,
  double percent,
  bool is8FieldGame,
) async {
  return await compute((_) {
    GameField gameField;

    // Generate a game and try to solve it
    do {
      gameField = createGameField(w, h, xs, ys, percent, is8FieldGame);
    } while (!gameField.isGameSolvable(for8Game: is8FieldGame));

    /*
    if (kDebugMode) {
      print('Game solved: ${later.isAfter(DateTime.now())}');
      gameField.dump();
    }
    */

    // now reset the game field but retain its solvable state
    var solvable = gameField.state;
    gameField.initFromMineField(gameField.mineField, xs, ys);
    gameField.state = solvable;
    return gameField;
  }, null);
}

GameField createGameField(
  int w,
  int h,
  int xs,
  int ys,
  double percent,
  bool is8FieldGame,
) {
  GameField gameField;
  MineField mineField;

  // Generate new game field
  mineField = MineField(w, h);
  mineField.intitMineField(xs, ys, percent, is8FieldGame);
  gameField = GameField(w, h);
  gameField.initFromMineField(mineField, xs, ys);
  return gameField;
}
