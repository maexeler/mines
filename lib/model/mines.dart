import 'package:flutter/foundation.dart';
import 'package:mines/model/mines_definitions.dart';
import 'package:mines/model/mines_logic.dart';
import 'package:mines/model/mines_timer.dart';

class MinesGame extends ChangeNotifier {
  int _w, _h;
  MineField _mineField;
  GameField _gameField;
  GameStat _state;
  final MinesTimer? _timer;
  int _remainingMines = 0;
  final _undoStack = <GameField>[];

  MinesGame(this._w, this._h, {MinesTimer? timer})
      : _mineField = MineField(_w, _h),
        _gameField = GameField(_w, _h),
        _state = GameStat.unInitialized,
        _timer = timer {
    // I dont like late, so do initialisation twice
    resetGame();
  }

  /// Start a new game
  ///
  /// [xs] and [ys] are the location of the first field to uncover
  /// [percent] is the percentage of mines in the game
  void startNewGame(int xs, int ys, double percent) {
    assert(xs >= 0 && xs < _w);
    assert(ys >= 0 && ys < _h);
    // Generate and solve the game
    do {
      _generateNewGame(xs, ys, percent);
    } while (!_gameField.solveGame());

    if (kDebugMode) {
      print('Game solved:');
      _gameField.dump();
    }

    // now start the game
    _gameField.initFromMineField(_mineField, xs, ys);

    _gameStatus = GameStat.initialized;
    _gameStatus = GameStat.running;
    _remainingMines = _mineField.mines;
    _pushToUndoStack();
    _checkForWin(); // It may happen, that we have won on start
    notifyListeners();
  }

  void uncoverField(int x, int y) {
    if (gameStatus == GameStat.unInitialized) {
      startNewGame(x, y, 20);
      return;
    }

    if (gameStatus == GameStat.initialized) {
      _gameStatus = GameStat.running;
    }

    if (gameStatus != GameStat.running) return;

    _pushToUndoStack(); // Prepare for undo

    assert(x >= 0 && x < _w);
    assert(y >= 0 && y < _h);
    final value = _gameField.getField(x, y);
    if (value.isNumber || value.isMaybeMine) {
      return;
    } else if (_mineField.getField(x, y).isMine) {
      _gameOver();
    } else if (value.isMaybeMine) {
      _gameField.setField(x, y, FieldValue.covered);
      //_gameField.calculateHints();
    } else if (value.isCovered) {
      _gameField.copyAndExpand(x, y, {});
      _gameField.calculateHints();
      _checkForWin();
    }
    notifyListeners();
  }

  void toggleMayBeMine(int x, int y) {
    if (gameStatus != GameStat.running) {
      return;
    }

    var value = _gameField.getField(x, y);
    if (value.isCovered && value.isMaybeMine) return;

    if (value.isCovered) {
      // if (_remainingMines <= 0) { // TODO
      //   return;
      // }
      _pushToUndoStack();
      _gameField.setField(x, y, FieldValue.maybeMine);
      _remainingMines--;
    } else if (value.isMaybeMine) {
      _pushToUndoStack();
      _gameField.setField(x, y, FieldValue.covered);
      _remainingMines++;
    }
    notifyListeners();
  }

  int get width => _w;
  int get height => _h;
  GameStat get gameStatus => _state;
  int get remainingMines => _remainingMines;
  FieldValue valueAt(int x, int y) => _gameField.getField(x, y);

  /// Change the size of the game
  void changeGameDimensions(int w, int h) {
    _w = w;
    _h = h;
    resetGame();
    notifyListeners();
  }

  void resetGame() {
    _mineField = MineField(_w, _h);
    _gameField = GameField(_w, _h);
    _gameStatus = GameStat.unInitialized;
    notifyListeners();
  }

  void replayGame() {
    if (gameStatus == GameStat.unInitialized) return;
    _popAllButOneFromUndoStack();
    _remainingMines = _mineField.mines;
    _gameStatus = GameStat.running;
    notifyListeners();
  }

  void undo() {
    _popFromUndoStack();
    _gameStatus = GameStat.running;
    notifyListeners();
  }

  bool get canUndo => _undoStack.isNotEmpty;

  void _generateNewGame(int xs, int ys, double percent) {
    resetGame();
    _mineField.intitMineField(xs, ys, percent);
    _gameField.initFromMineField(_mineField, xs, ys);
  }

  void _gameOver() {
    _gameField.markGameOver();
    _gameStatus = GameStat.gameOver;
  }

  void _checkForWin() {
    for (int x = 0; x < _w; x++) {
      for (int y = 0; y < _h; y++) {
        if (_gameField.getField(x, y).isCovered &&
            _mineField.getField(x, y).isNotMine) return;
      }
    }
    // Only covered mines remaining, we have a win
    _gameStatus = GameStat.win;
    notifyListeners();
  }

  set _gameStatus(GameStat status) {
    switch (status) {
      case GameStat.unInitialized:
      // Do nothing
      case GameStat.initialized:
        _resetUndoStack();
        _timer?.resetTimer();
        _remainingMines = 0;
      case GameStat.running:
        _timer?.startTimer();
      case GameStat.win:
        _timer?.stopTimer();
      case GameStat.gameOver:
        _timer?.stopTimer();
    }
    _state = status;
  }

  void _resetUndoStack() {
    _undoStack.clear();
  }

  void _pushToUndoStack() {
    _undoStack.add(_gameField.clone());
  }

  void _popFromUndoStack() {
    if (_undoStack.isEmpty) return;
    _gameField = _undoStack.removeLast();
  }

  void _popAllButOneFromUndoStack() {
    while (_undoStack.length > 1) {
      _gameField = _undoStack.removeLast();
    }
  }
}
