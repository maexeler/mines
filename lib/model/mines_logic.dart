import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:Minesweeper/model/mines_definitions.dart';

/// A MineField holds the true state of the game
///
class MineField extends _Grid {
  final rnd = math.Random();
  int _mines = 0;

  MineField(int w, int h) : super(w, h, FieldValue.empty);

  int get totalMines => _mines;

  /// Create an actual mine field by placing [percent] mines on the field
  /// and calculating the values of all it's neigbours.
  ///
  /// [percent] is in 0..100%
  void intitMineField(int xstart, int ystart, double percent) {
    _mines = (w * h * percent / 100).round();
    int mines = _mines;
    // Start empty
    fillWith(FieldValue.empty);

    // Fill in mines
    while (mines > 0) {
      // No bomb at start position and only one bomb at each location
      int x = rnd.nextInt(w);
      int y = rnd.nextInt(h);
      if (x == xstart && y == ystart || getField(x, y).isMine) {
        continue;
      }
      _fields[x][y].value = FieldValue.mine;
      mines--;
    }
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        if (getField(x, y).isNotMine) {
          Set<_FieldIndex> neighbors = getNeighbors(x, y, (value) {
            return value.isMine;
          });
          setField(x, y, neighbors.length);
        }
      }
    }
  }
}

enum GameFieldStatus {
  unInitialized,
  initialized,
  solvable,
  solvableWithGuess,
  win,
  loose
}

enum UncoverFieldSatus { none, done, gameTerminated }

/// A GameField represents the users view of the game.
///
/// It allows the user to uncover fields or mark them as 'dangerous'.
///
/// You may not use GameField until you initialized it with a MineField
class GameField extends _Grid {
  int _remainingMines = 0;
  late MineField mineField;
  GameFieldStatus state = GameFieldStatus.unInitialized;

  GameField(int w, int h) : super(w, h, FieldValue.covered);

  /// Given a start position, initialize the GameField from the MineField.
  ///
  void initFromMineField(MineField mineField, int xstart, int ystart) {
    this.mineField = mineField;
    this._remainingMines = mineField.totalMines;
    fillWith(FieldValue.covered);
    if (mineField.getField(xstart, ystart).isEmpty) {
      _copyAndExpand(xstart, ystart, {});
    } else {
      // Transfer the start value ..
      setField(xstart, ystart, mineField.getField(xstart, ystart).value);
      // and all save neighbours
      Set<_FieldIndex> neighbors =
          mineField.getNeighbors(xstart, ystart, (value) => value.isNumber);
      for (var element in neighbors) {
        setField(element.$1, element.$2,
            mineField.getField(element.$1, element.$2).value);
      }
    }
    state = GameFieldStatus.initialized;
  }

  /// return true if this game is solvable
  bool isGameSolvable() {
    while (_solveFields()) {}
    if (_isGameSolved()) {
      state = GameFieldStatus.solvable;
      return true;
    } else {
      state = GameFieldStatus.solvableWithGuess;
      return false;
    }
  }

  /// Return what has happened to the Field
  /// or gameTerminated if the game ended.
  UncoverFieldSatus uncoverField(int x, int y) {
    _resetHints();

    // Shouldn't do anyting if game is over
    if (state == GameFieldStatus.win || state == GameFieldStatus.loose) {
      return UncoverFieldSatus.none;
    }

    final value = getField(x, y);
    // If it's already uncovered or marked do nothing
    if (value.isNumber || value.isEmpty || value.isMaybeMine)
      return UncoverFieldSatus.none;

    // If we uncover a mine, it's game over
    if (mineField.getField(x, y).isMine) {
      _transferToGameOverView(x, y);
      state = GameFieldStatus.loose;
      return UncoverFieldSatus.gameTerminated;
    }
    // otherwise reveal it
    _copyAndExpand(x, y, {});

    // and check for a win
    if (_isGameSolved()) {
      state = GameFieldStatus.win;
      return UncoverFieldSatus.gameTerminated;
    } else {
      return UncoverFieldSatus.done;
    }
  }

  int get remainingMines => _remainingMines;

  bool toggleMayBeMine(int x, int y) {
    _resetHints();

    // Shouldn't do anyting if game is over
    if (state == GameFieldStatus.win || state == GameFieldStatus.loose) {
      return false;
    }

    if (_remainingMines > 0 && getField(x, y).isCovered) {
      setField(x, y, FieldValue.maybeMine);
      _remainingMines--;
      return true;
    }
    if (getField(x, y).isMaybeMine) {
      setField(x, y, FieldValue.covered);
      _remainingMines++;
      return true;
    }
    return false;
  }

  /// Show all cells with a possible action
  void showHints() {
    _resetHints();
    _markSolvableField();
  }

  /// if a field is not empty, copy it
  /// otherwise copy and expand it recursivly
  void _copyAndExpand(int x, int y, Set<(int, int)> allreadyProcessed) {
    if (x < 0 || x >= w || y < 0 || y >= h) return;

    // terminate recursion
    if (allreadyProcessed.contains((x, y))) return;

    var field = mineField.getField(x, y);
    // Do not uncover falsely marked fields
    if (!getField(x, y).isMaybeMine) {
      setField(x, y, field.value);
    }
    allreadyProcessed.add((x, y));

    if (field.isNotEmpty) return;

    // we are on an empty field, copy and expand recursivly
    Set<_FieldIndex> neighbors = mineField.getNeighbors(x, y, (value) => true);
    for (var element in neighbors) {
      _copyAndExpand(element.$1, element.$2, allreadyProcessed);
    }
  }

  bool _isGameSolved() {
    int revealedFields = 0;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        if (getField(x, y).isNumber || getField(x, y).isEmpty) {
          revealedFields++;
        }
      }
    }
    return revealedFields + mineField.totalMines == w * h;
  }

  void _transferToGameOverView(int xlast, ylast) {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        if (getField(x, y).isMaybeMine) {
          if (mineField.getField(x, y).isNotMine) {
            getField(x, y).value = FieldValue.notAMaybeMine;
          }
        } else {
          getField(x, y).value = mineField.getField(x, y).value;
        }
      }
    }
    getField(xlast, ylast).markExploded();
  }

  /// return true as long as some progress is made
  bool _solveFields() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        // We are only interrested in number fields
        if (_fields[x][y].isNotNumber) {
          continue;
        }
        final fieldInfo = _fillInFieldInfo(x, y);
        // Check if all covered fields are mines
        if (fieldInfo.coveredFields.isNotEmpty &&
            (fieldInfo.fieldValue - fieldInfo.mayBeMines ==
                fieldInfo.coveredFields.length)) {
          for (var (xl, yl) in fieldInfo.coveredFields) {
            // Mark them as mayBeMines
            _fields[xl][yl].value = FieldValue.maybeMine;
          }
          return true;
        }
        // Check if remaining field may savely be uncovered
        if (fieldInfo.coveredFields.isNotEmpty &&
            (fieldInfo.mayBeMines == fieldInfo.fieldValue)) {
          for (var (xl, yl) in fieldInfo.coveredFields) {
            _copyAndExpand(xl, yl, {});
          }
          return true;
        }
      }
    }
    return false;
  }

  bool _markSolvableField() {
    var progress = false;

    // Loop over logical coordinates
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        final fieldInfo = _fillInFieldInfo(x, y);
        // Ignore covered fields
        if (fieldInfo.field.isMaybeMine || fieldInfo.field.isCovered) {
          continue;
        }
        // Ignore allready solved fields
        if (fieldInfo.coveredFields.isEmpty) {
          continue;
        }
        // Check if all covered fields are mines
        if (fieldInfo.fieldValue - fieldInfo.mayBeMines ==
            fieldInfo.coveredFields.length) {
          _fields[x][y].setHint();
          progress = true;
          continue;
        }
        // Check if remaining field may savely be uncovered
        if (fieldInfo.mayBeMines == fieldInfo.fieldValue) {
          _fields[x][y].setHint();
          progress = true;
          continue;
        }
      }
    }

    return progress;
  }

  _FieldInfo _fillInFieldInfo(int x, int y) {
    var res = _FieldInfo(_fields[x][y]);
    res.uncovered =
        getNeighbors(x, y, (neighbor) => neighbor.isUncovered).length;
    res.mayBeMines =
        getNeighbors(x, y, (neighbor) => neighbor.isMaybeMine).length;
    res.coveredFields = getNeighbors(x, y, (neighbor) => neighbor.isCovered);
    return res;
  }

  void _resetHints() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        _fields[x][y].resetHint();
      }
    }
  }

  /// Needed for undo/redo
  GameField clone() {
    var clone = GameField(w, h);
    for (int x = 0; x < mineField.w; x++) {
      for (int y = 0; y < mineField.h; y++) {
        clone._fields[x][y] = FieldValue()..value = _fields[x][y].value;
      }
    }
    clone.mineField = mineField;
    clone.state = state;
    clone._remainingMines = _remainingMines;
    return clone;
  }

  /// For debug output only
  void dump() {
    String res = '\n';
    for (int y = 0; y < mineField.h; y++) {
      String resGame = '';
      for (int x = 0; x < mineField.w; x++) {
        res += mineField._dumpField(x, y);
        resGame += _dumpField(x, y);
      }
      res += '\t$resGame\n';
    }
    if (kDebugMode) {
      print(res);
    }
  }
}

typedef _FieldIndex = (int, int);

class _FieldInfo {
  final FieldValue _field;
  int uncovered = 0;
  int mayBeMines = 0;
  Set<_FieldIndex> coveredFields = {};

  _FieldInfo(this._field);

  FieldValue get field => _field;

  int get fieldValue => _field.value;
}

class _Grid {
  int w, h;
  final List<List<FieldValue>> _fields;
  _Grid(this.w, this.h, int initialValue)
      : _fields = List.generate(w,
            (i) => List.generate(h, (j) => FieldValue()..value = initialValue));

  FieldValue getField(int x, int y) {
    if (x < 0 || x >= w || y < 0 || y >= h) {
      return FieldValue()..value = FieldValue.empty;
    }
    return _fields[x][y];
  }

  void setField(int x, int y, int value) {
    if (x < 0 || x >= w || y < 0 || y >= h) {
      return;
    }
    _fields[x][y].value = value;
  }

  Set<_FieldIndex> getNeighbors(
      int x, int y, bool Function(FieldValue val) predicate) {
    if (x < 0 || x >= w || y < 0 || y >= h) {
      return <_FieldIndex>{}; // edge elements have no neighbors
    }
    var neighbors = [
      (x - 1, y - 1),
      (x - 1, y),
      (x - 1, y + 1),
      (x, y - 1),
      (x, y + 1),
      (x + 1, y - 1),
      (x + 1, y),
      (x + 1, y + 1)
    ];
    var res = <_FieldIndex>{};
    for (var elem in neighbors) {
      if (predicate(getField(elem.$1, elem.$2))) {
        res.add((elem.$1, elem.$2));
      }
    }
    return res;
  }

  void fillWith(int value) {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        _fields[x][y].value = value;
      }
    }
  }

  /// For debug output only
  String _dumpField(int x, int y) {
    if (getField(x, y).isEmpty) {
      return '_';
    }
    if (getField(x, y).isNumber) {
      return getField(x, y).value.toString();
    }
    if (getField(x, y).isMine) {
      return 'x';
    }
    if (getField(x, y).isMaybeMine) {
      return 'm';
    }
    if (getField(x, y).isCovered) {
      return 'c';
    }
    return '?';
  }
}
