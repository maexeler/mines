import 'package:mines/model/mines_definitions.dart';
import 'package:mines/model/mines_logic.dart';
import 'package:mines/model/solver.dart';
import 'package:mines/provider/game_provider.dart';
import 'package:mines/provider/game_remaining_mines_provider.dart';
import 'package:mines/provider/game_status_provider.dart';
import 'package:mines/provider/game_time_provider.dart';
import 'package:mines/provider/settings_provider.dart';
import 'package:vibration/vibration.dart';

class MinesGame {
  final MinesTimeProvider _timer;
  final SettingsProvider _settingsProvider;
  final GameProvider _gameInterfaceProvider;
  final MinesGameStateProvider _minesStateProvider;
  final RemainingMinesProvider _remainingMinesProvider;

  int _w, _h;
  // late MineField _mineField;
  late GameField _gameField;
  GameStat _state;
  final _undoStack = <GameField>[];
  bool _gameIsSovable = true;

  MinesGame(
      {required MinesTimeProvider timer,
      required SettingsProvider settings,
      required GameProvider gameInterfaceProvider,
      required MinesGameStateProvider minesState,
      required RemainingMinesProvider remainingMinesProvider})
      : _timer = timer,
        _settingsProvider = settings,
        _minesStateProvider = minesState,
        _gameInterfaceProvider = gameInterfaceProvider,
        _remainingMinesProvider = remainingMinesProvider,
        _w = 0,
        _h = 0,
        _state = GameStat.startingUp {
    _gameInterfaceProvider.initialize(this);
    _settingsProvider.addListener(_waitForSettings);
    resetGame();
    _state = GameStat.startingUp;
  }

  /// Start a new game
  ///
  /// [xs] and [ys] are the location of the first field to uncover
  /// [percent] is the percentage of mines in the game
  void startNewGame(int xs, int ys, double percent) {
    assert(xs >= 0 && xs < _w);
    assert(ys >= 0 && ys < _h);

    _gameStatus = GameStat.calculating;
    _gameInterfaceProvider.notifyListeners();

    getNewGameField(_w, _h, xs, ys, percent, _settingsProvider.timeOut)
        .then((value) {
      _gameField = value;
      _gameStatus = GameStat.running;
      _minesStateProvider.state = _gameField.state == GameFieldStatus.solvable
          ? MinesGameState.solvable
          : MinesGameState.solvableWithGuess;

      _pushToUndoStack(_gameField.clone());
      _checkForWin(); // It may happen, that we have won on start
      _remainingMinesProvider.remainingMines = value.remainingMines;
      _gameInterfaceProvider.notifyListeners();
    });
    _gameStatus = GameStat.calculating;
    _gameInterfaceProvider.notifyListeners();
  }

  void uncoverField(int x, int y) {
    if (gameStatus == GameStat.initialized) {
      startNewGame(x, y, _settingsProvider.percentMines);
      return;
    }

    _pushToUndoStack(_gameField.clone());
    switch (_gameField.uncoverField(x, y)) {
      case UncoverFieldSatus.none:
        _popFromUndoStack();
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

    _gameInterfaceProvider.notifyListeners();
  }

  void toggleMayBeMine(int x, int y) {
    if (gameStatus != GameStat.running) {
      return; // can't do anything
    }

    GameField last = _gameField.clone();
    if (_gameField.toggleMayBeMine(x, y)) {
      _pushToUndoStack(last);
      Vibration.vibrate(duration: 100);
      _remainingMinesProvider.remainingMines = _gameField.remainingMines;
      _gameInterfaceProvider.notifyListeners();
    }
  }

  void toggleHints() {
    _gameField.showHints();
    _gameInterfaceProvider.notifyListeners();
    ;
  }

  int get width => _w;
  int get height => _h;
  GameStat get gameStatus => _state;
  FieldValue valueAt(int x, int y) => _gameField.getField(x, y);

  /// Change the size of the game
  void changeGameDimensions(int w, int h) {
    _w = w;
    _h = h;
    resetGame();
    _gameStatus = GameStat.initialized;
    _gameInterfaceProvider.notifyListeners();
  }

  void resetGame() {
    // _mineField = MineField(_w, _h);
    _gameField = GameField(_w, _h);
    _gameStatus = GameStat.unInitialized;
    _gameInterfaceProvider.notifyListeners();
    _minesStateProvider.state = MinesGameState.uninitialized;
  }

  bool get canReplayGame =>
      _state == GameStat.running ||
      _state == GameStat.win ||
      _state == GameStat.gameOver;

  void replayGame() {
    if (!canReplayGame) return;
    _popAllButOneFromUndoStack();
    _gameStatus = GameStat.running;
    _gameInterfaceProvider.notifyListeners();
    _remainingMinesProvider.remainingMines = _gameField.remainingMines;
    _minesStateProvider.state = _isGameSolvable;
  }

  MinesGameState get _isGameSolvable => _gameIsSovable
      ? MinesGameState.solvable
      : MinesGameState.solvableWithGuess;

  void undo() {
    if (!canUndo) return;

    _popFromUndoStack();
    _state = GameStat.running;
    _timer.resumeTimer();
    _minesStateProvider.state = _isGameSolvable;
    _remainingMinesProvider.remainingMines = _gameField.remainingMines;
    _gameInterfaceProvider.notifyListeners();
  }

  bool get canUndo => _undoStack.length > 1;

  void _checkForWin() {
    if (_gameField.state == GameFieldStatus.win) {
      _gameStatus = GameStat.win;
      Vibration.vibrate(duration: 300);
      _gameInterfaceProvider.notifyListeners();
    }
  }

  set _gameStatus(GameStat status) {
    switch (status) {
      case GameStat.startingUp:
        _timer.resetTimerValue();
      case GameStat.unInitialized:
        _timer.stopTimer();
        _timer.resetTimerValue();
        _remainingMinesProvider.remainingMines = 0;
        _gameInterfaceProvider.notifyListeners();
      case GameStat.calculating:
        ; // Do nothing
      case GameStat.initialized:
        _resetUndoStack();
        _timer.resetTimerValue();
      case GameStat.running:
        _timer.resetAndStartTimer();
      case GameStat.win:
        _timer.stopTimer();
        _minesStateProvider.state = MinesGameState.won;
      case GameStat.gameOver:
        _timer.stopTimer();
        _minesStateProvider.state = MinesGameState.lost;
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

  void _waitForSettings() {
    if (_settingsProvider.isInitialized) {
      _settingsProvider.removeListener(_waitForSettings);
      _gameStatus = GameStat.unInitialized;
    }
  }
}
