import 'package:flutter/foundation.dart';
import 'package:mines/model/mines_definitions.dart';
import 'package:mines/model/mines_logic.dart';
import 'package:mines/model/mines_timer.dart';
import 'package:mines/pages/settings/settings_provider.dart';
import 'package:vibration/vibration.dart';

class MinesGame extends ChangeNotifier {
  int _w, _h;
  late MineField _mineField;
  late GameField _gameField;
  GameStat _state;
  final MinesTimer? _timer;
  final _undoStack = <GameField>[];
  SettingsProvider settings;

  MinesGame({MinesTimer? timer, required SettingsProvider this.settings})
      : _w = 0,
        _h = 0,
        _state = GameStat.unInitialized,
        _timer = timer {
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
    } while (!_gameField.isSolvableGame());

    if (kDebugMode) {
      print('Game solved:');
      _gameField.dump();
    }

    // now start the game
    _gameField.initFromMineField(_mineField, xs, ys);
    _gameStatus = GameStat.running;
    _pushToUndoStack(_gameField.clone());
    _checkForWin(); // It may happen, that we have won on start
    notifyListeners();
  }

  void uncoverField(int x, int y) {
    if (gameStatus == GameStat.layouted || gameStatus == GameStat.initialized) {
      startNewGame(x, y, settings.percentMines);
      return;
    }

    var last = _gameField.clone();
    switch (_gameField.uncoverField(x, y)) {
      case UncoverFieldSatus.none:
        return;
      case UncoverFieldSatus.done:
        ; // nothing extra to do
      case UncoverFieldSatus.gameTerminated:
        if (_gameField.state == GameFieldStatus.win) {
          _gameStatus = GameStat.win;
          Vibration.vibrate(duration: 300);
        } else {
          _gameStatus = GameStat.gameOver;
          Vibration.vibrate(duration: 300);
        }
    }
    _pushToUndoStack(last);
    notifyListeners();
  }

  void toggleMayBeMine(int x, int y) {
    if (gameStatus != GameStat.running) {
      return; // can't do anything
    }

    if (_gameField.remaingMines == 0) {
      return; // No more mayBeMines left
    }

    GameField last = _gameField.clone();
    if (_gameField.toggleMayBeMine(x, y)) {
      _pushToUndoStack(last);
      Vibration.vibrate(duration: 100);
      notifyListeners();
    }
  }

  void toggleHints() {
    _gameField.showHints();
    notifyListeners();
    ;
  }

  int get width => _w;
  int get height => _h;
  GameStat get gameStatus => _state;
  int get remainingMines => _gameField.remaingMines;
  FieldValue valueAt(int x, int y) => _gameField.getField(x, y);

  /// Change the size of the game
  void changeGameDimensions(int w, int h) {
    _w = w;
    _h = h;
    resetGame();
    _gameStatus = GameStat.initialized;
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
    _gameStatus = GameStat.running;
    notifyListeners();
  }

  void undo() {
    _popFromUndoStack();
    _gameStatus = GameStat.running;
    notifyListeners();
  }

  bool get canUndo => _undoStack.length > 1;

  void _generateNewGame(int xs, int ys, double percent) {
    resetGame();
    _mineField.intitMineField(xs, ys, percent);
    _gameField.initFromMineField(_mineField, xs, ys);
  }

  // void _gameOver() {
  //   _gameField.gameOver();
  //   _gameStatus = GameStat.gameOver;
  //   Vibration.vibrate(duration: 300);
  //   notifyListeners();
  // }

  // bool get showHints => _showHints;

  // void toggleHints() {
  //   _showHints = !_showHints;
  //   _processHints();
  //   notifyListeners();
  // }

  // void _processHints() {
  //   if (_showHints) {
  //     _gameField.calculateHints();
  //   } else {
  //     _gameField.resetHints();
  //   }
  // }

  void _checkForWin() {
    if (_gameField.state == GameFieldStatus.win) {
      _gameStatus = GameStat.win;
      Vibration.vibrate(duration: 300);
      notifyListeners();
    }
  }

  set _gameStatus(GameStat status) {
    switch (status) {
      case GameStat.layouted: // Do nothing
      case GameStat.unInitialized: // Do nothing
      case GameStat.initialized:
        _resetUndoStack();
        _timer?.resetTimer();
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

  void _pushToUndoStack(GameField last) {
    _undoStack.add(last);
  }

  void _popFromUndoStack() {
    if (_undoStack.isEmpty) return;
    _gameField = _undoStack.removeLast();
  }

  void _popAllButOneFromUndoStack() {
    while (canUndo) {
      _popFromUndoStack();
    }
  }
}
