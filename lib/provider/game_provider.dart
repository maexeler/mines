import 'package:flutter/foundation.dart';
import 'package:Minesweeper/model/mines_game.dart';
import 'package:Minesweeper/model/mines_definitions.dart';

/// This class serves as a clean abstraction of what a mines game is.
///
/// Never use [MinesGame] directly
class GameProvider extends ChangeNotifier {
  late MinesGame _game;

  void initialize(MinesGame game) {
    _game = game;
  }

  // -------------
  // Game commands
  // -------------

  void resetGame() => _game.resetGame();

  void changeGameDimensions(int w, int h) => _game.changeGameDimensions(w, h);

  void uncoverField(int x, int y) => _game.uncoverField(x, y);

  void toggleMayBeMine(int x, int y) => _game.toggleMayBeMine(x, y);

  void toggleHints() => _game.toggleHints();

  bool get canReplayGame => _game.canReplayGame;

  void replayGame() => _game.replayGame();

  get canUndo => _game.canUndo;

  void undo() => _game.undo();

  // ------------------------
  // Access to the game field
  // ------------------------

  int get width => _game.width;

  int get height => _game.height;

  FieldValue fieldValueAt(int x, int y) => _game.valueAt(x, y);

  // ---------
  // Rendering
  // ---------

  bool get isSolving => _game.gameStatus == GameStat.calculating;

  bool get isRunning => _game.gameStatus == GameStat.running;

  bool get needsRecalculationOfGameDimensions =>
      _game.gameStatus == GameStat.unInitialized;

  // --------
  // Notifyer
  // --------

  /// To be called whenever the game field changes
  void notifyListeners() {
    super.notifyListeners();
  }

  // ------
  // Bugfix
  // ------
  //
  // Redraw the game after startup a second time so the layout
  // scales appropriately.
  //
  // It might be that I don't understand how to use
  // MultiChildLayoutDelegate.performLayout(size)
  // God knows why but the size argument is too small on the first run.
  // --------
  bool _needsRedraw = true;

  void maybeRedrawGame() async {
    if (!_needsRedraw) return;

    _needsRedraw = false;
    await Future.delayed(const Duration(milliseconds: 50));
    resetGame();
  }
}
