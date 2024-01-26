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
      _gameField.dump();
    }

    // now start the game
    _gameField.initFromMineField(_mineField, xs, ys);
    _gameStatus = GameStat.initialized;
    _gameStatus = GameStat.running;
    notifyListeners();
  }

  void uncoverField(int x, int y) {
    if (gameStatus == GameStat.unInitialized) {
      startNewGame(x, y, 20);
      _gameField.markSolvableField();
      return;
    }

    _gameField.unMarkSolvableField();

    if (gameStatus == GameStat.initialized) {
      _gameStatus = GameStat.running;
    }

    if (gameStatus != GameStat.running) return;

    _pushToUndoStack(); // Prepare for undo

    assert(x >= 0 && x < _w);
    assert(y >= 0 && y < _h);
    final value = _gameField.getField(x, y);
    if (value >= empty && value < eight || value == maybeMine) {
      return;
    } else if (_mineField.getField(x, y) == mine) {
      _gameOver();
    } else if (value == maybeMine) {
      _gameField.setField(x, y, covered);
    } else if (value == covered) {
      _gameField.copyAndExpand(x, y, {});
      _checkForWin();
    }
    _gameField.markSolvableField();
    notifyListeners();
  }

  toggleMayBeMine(int x, int y) {
    _gameField.unMarkSolvableField();

    if (gameStatus != GameStat.running) {
      return;
    }

    var value = _gameField.getField(x, y);
    if (value != covered && value != maybeMine) return;

    if (value == covered) {
      _pushToUndoStack();
      _gameField.setField(x, y, maybeMine);
    } else if (value == maybeMine) {
      _pushToUndoStack();
      _gameField.setField(x, y, covered);
    }
    _gameField.markSolvableField();
    notifyListeners();
  }

  int get width => _w;
  int get height => _h;
  GameStat get gameStatus => _state;
  int get remainingMines => _remainingMines;
  int valueAt(int x, int y) => _gameField.getField(x, y);

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

    _gameField.fillWith(covered);
    _gameStatus = GameStat.initialized;
    notifyListeners();
  }

  void undo() {
    _popFromUndoStack();
    notifyListeners();
  }

  bool get canUndo => _undoStack.isNotEmpty;

  void _generateNewGame(int xs, int ys, double percent) {
    resetGame();
    _mineField.intitMineField(xs, ys, percent);
    _gameField.initFromMineField(_mineField, xs, ys);
  }

  void _gameOver() {
    for (int x = 0; x < _w; x++) {
      for (int y = 0; y < _h; y++) {
        if (_gameField.getField(x, y) == maybeMine &&
            _mineField.getField(x, y) != mine) {
          _gameField.setField(x, y, notMaybeMine);
        } else {
          _gameField.setField(x, y, _mineField.getField(x, y));
        }
      }
    }
    _gameStatus = GameStat.gameOver;
  }

  void _checkForWin() {
    for (int x = 0; x < _w; x++) {
      for (int y = 0; y < _h; y++) {
        if (_gameField.getField(x, y) == covered &&
            _mineField.getField(x, y) != mine) return;
      }
    }
    // Only covered mines remaining -> win
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
    notifyListeners();
  }

  void _popFromUndoStack() {
    if (_undoStack.isEmpty) return;
    _gameField = _undoStack.removeLast();
    _gameStatus = GameStat.running;
    notifyListeners();
  }
}
