import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:mines/model/mines_definitions.dart';

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

class MineField extends _Grid {
  final rnd = math.Random();
  int _mines = 0;

  MineField(int w, int h) : super(w, h, FieldValue.empty);

  get mines => _mines;

  void intitMineField(int xs, int ys, double percent) {
    var mines = _mines = (w * h * percent / 100).round();
    // Start empty
    fillWith(FieldValue.empty);

    // Fill in mines
    while (mines > 0) {
      // No bomb at start position and only one bomb at each location
      int x = rnd.nextInt(w);
      int y = rnd.nextInt(h);
      if (x == xs && y == ys || getField(x, y).isMine) {
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

class GameField extends _Grid {
  MineField mineField;

  GameField(int w, int h)
      : mineField = MineField(w, h), // will be replaced later
        super(w, h, FieldValue.covered);

  void initFromMineField(MineField mineField, int xs, int ys) {
    this.mineField = mineField;
    fillWith(FieldValue.covered);
    // Transfer the start value
    setField(xs, ys, mineField.getField(xs, ys).value);
    Set<_FieldIndex> neighbors = mineField.getNeighbors(xs, ys, (value) {
      return xs >= 0 && xs < w && ys >= 0 && ys < h && value.isNumber;
    });
    for (var element in neighbors) {
      setField(element.$1, element.$2,
          mineField.getField(element.$1, element.$2).value);
    }
  }

  /// if a field is not empty, copy it
  /// otherwise copy and expand it recursivly
  void copyAndExpand(int x, int y, Set<(int, int)> allreadyProcessed) {
    if (x < 0 || x >= w || y < 0 || y >= h) return;

    // terminate recursion
    if (allreadyProcessed.contains((x, y))) return;

    var field = mineField.getField(x, y);
    setField(x, y, field.value);
    allreadyProcessed.add((x, y));

    if (field.isNotEmpty) return;

    // we are on an empty field, copy and expand recursivly
    Set<_FieldIndex> neighbors = mineField.getNeighbors(x, y, (value) {
      return x >= 0 && x < w && y >= 0 && y < h;
    });
    for (var element in neighbors) {
      copyAndExpand(element.$1, element.$2, allreadyProcessed);
    }
  }

  void markGameOver() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        if (getField(x, y).isMaybeMine && mineField.getField(x, y).isNotMine) {
          getField(x, y).value = FieldValue.notMaybeMine;
        } else if (getField(x, y).isCovered) {
          getField(x, y).value = mineField.getField(x, y).value;
        }
      }
    }
    resetHints();
  }

  bool solveGame() {
    while (_solveField()) {}
    return _gameSolved();
  }

  bool _solveField() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        final fieldInfo = _fillInFieldInfo(x, y);
        // We are only interrested in number fields
        if (fieldInfo.field.isNotNumber) {
          continue;
        }
        if (fieldInfo.fieldValue == 8) {
          continue;
        }
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
            copyAndExpand(xl, yl, {});
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
          _fields[x][y].mark();
          progress = true;
          continue;
        }
        // Check if remaining field may savely be uncovered
        if (fieldInfo.mayBeMines == fieldInfo.fieldValue) {
          _fields[x][y].mark();
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

  bool _gameSolved() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        if (_fields[x][y].isCovered) {
          return false;
        }
      }
    }
    return true;
  }

  GameField clone() {
    var clone = GameField(w, h);
    for (int x = 0; x < mineField.w; x++) {
      for (int y = 0; y < mineField.h; y++) {
        clone._fields[x][y] = FieldValue()..value = _fields[x][y].value;
      }
    }
    clone.mineField = mineField;
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

  void resetHints() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        _fields[x][y].unMark();
      }
    }
  }

  void calculateHints() {
    resetHints();
    _markSolvableField();
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
