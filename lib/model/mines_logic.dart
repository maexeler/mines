import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:mines/model/mines_definitions.dart';

class _Grid {
  int w, h;
  final List<List<int>> _fields;
  _Grid(this.w, this.h, int initialValue)
      : _fields = List.generate(w, (i) => List.filled(h, initialValue));

  int getField(int x, int y) {
    if (x < 0 || x >= w || y < 0 || y >= h) {
      return empty;
    }
    return _fields[x][y];
  }

  void setField(int x, int y, int value) {
    if (x < 0 || x >= w || y < 0 || y >= h) {
      return;
    }
    _fields[x][y] = value;
  }

  Set<(int, int)> getNeighbors(int x, int y, bool Function(int val) predicate) {
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
    var res = <(int, int)>{};
    for (var elem in neighbors) {
      if (x < 0 || x >= w || y < 0 || y >= h) {
        continue;
      }
      if (predicate(getField(elem.$1, elem.$2))) {
        res.add(elem);
      }
    }
    return res;
  }

  void fillWith(int value) {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        _fields[x][y] = value;
      }
    }
  }

  String _dumpField(int x, int y) {
    if (getField(x, y) == mine) {
      return 'x';
    } else if (getField(x, y) == empty) {
      return '_';
    } else if (getField(x, y) == covered) {
      return 'c';
    } else if (getField(x, y) == uncovered) {
      return 'u';
    } else if (getField(x, y) == maybeMine) {
      return 'm';
    } else {
      return getField(x, y).toString();
    }
  }
}

class MineField extends _Grid {
  final rnd = math.Random();
  int _mines = 0;

  MineField(int w, int h) : super(w, h, empty);

  get mines => _mines;

  void intitMineField(int xs, int ys, double percent) {
    var mines = _mines = (w * h * percent / 100).round();
    // Start empty
    fillWith(empty);
    // Fill in mines
    while (mines > 0) {
      // No bomb at start position and only one bomb at each location
      int x = rnd.nextInt(w);
      int y = rnd.nextInt(h);
      if (x == xs && y == ys || getField(x, y) == mine) {
        continue;
      }
      _fields[x][y] = mine;
      mines--;
    }
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        if (getField(x, y) != mine) {
          Set<(int, int)> neighbors = getNeighbors(x, y, (value) {
            return value == mine;
          });
          setField(x, y, neighbors.length);
        }
      }
    }
  }

  // _MineField clone() {
  //   var res = _MineField(w, h);
  //   res._mines = _mines;
  //   for (int x = 0; x < w; x++) {
  //     for (int y = 0; y < h; y++) {
  //       res._fields[x][y] = _fields[x][y];
  //     }
  //   }
  //   return res;
  // }
}

class GameField extends _Grid {
  MineField mineField;
  bool showHelp = false;

  GameField(int w, int h)
      : mineField = MineField(w, h), // will be replaced later
        super(w, h, covered);

  void initFromMineField(MineField mineField, int xs, int ys) {
    this.mineField = mineField;
    fillWith(covered);
    // Transfer the start value
    copyAndExpand(xs, ys, <(int, int)>{});
  }

  void toggleHelp() {
    showHelp = !showHelp;
  }

  void copyAndExpand(int x, int y, Set<(int, int)> allreadyProcessed) {
    setField(x, y, mineField.getField(x, y));
    allreadyProcessed.add((x, y));
    Set<(int, int)> neighbors = mineField.getNeighbors(x, y, (value) {
      return value >= one && value <= eight;
    });
    neighbors = neighbors.difference(allreadyProcessed);
    for (var element in neighbors) {
      setField(
          element.$1, element.$2, mineField.getField(element.$1, element.$2));
    }
    allreadyProcessed.addAll(neighbors);
    neighbors = mineField.getNeighbors(x, y, (value) {
      return value == empty;
    });
    neighbors = neighbors.difference(allreadyProcessed);
    for (var element in neighbors) {
      copyAndExpand(element.$1, element.$2, allreadyProcessed);
    }
  }

  bool solveGame() {
    while (_solveField()) {
      if (_gameSolved()) {
        return true;
      }
    }
    return false;
  }

  bool _solveField() {
    var progress = false;
    // Loop over logical coordinates
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        final fieldInfo = _fillInFieldInfo(x, y);
        // Ignore covered fields
        if (fieldInfo.value == maybeMine || fieldInfo.value == covered) {
          continue;
        }
        // Ignore allready solved fields
        if (fieldInfo.coveredFields.isEmpty) {
          continue;
        }
        // Check if all covered fields are mines
        if (fieldInfo.value - fieldInfo.mayBeMines ==
            fieldInfo.coveredFields.length) {
          for (var (x, y) in fieldInfo.coveredFields) {
            // Mark them as mayBeMines
            _fields[x][y] = maybeMine;
          }
          // progress = true;
          // continue;
          return true;
        }
        // Check if remaining field may savely be uncovered
        if (fieldInfo.mayBeMines == fieldInfo.value) {
          for (var (x, y) in fieldInfo.coveredFields) {
            copyAndExpand(x, y, {});
          }
          // progress = true;
          // continue;
          return true;
        }
      }
    }
    return progress;
  }

  void unMarkSolvableField() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        _fields[x][y] = _fields[x][y] % 150;
      }
    }
  }

  bool markSolvableField() {
    var progress = false;
    // Loop over logical coordinates
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        final fieldInfo = _fillInFieldInfo(x, y);
        // Ignore covered fields
        if (fieldInfo.value == maybeMine || fieldInfo.value == covered) {
          continue;
        }
        // Ignore allready solved fields
        if (fieldInfo.coveredFields.isEmpty) {
          continue;
        }
        // Check if all covered fields are mines
        if (fieldInfo.value - fieldInfo.mayBeMines ==
            fieldInfo.coveredFields.length) {
          _fields[x][y] += 150;
          progress = true;
          continue;
        }
        // Check if remaining field may savely be uncovered
        if (fieldInfo.mayBeMines == fieldInfo.value) {
          _fields[x][y] += 150;
          // for (var (x, y) in fieldInfo.coveredFields) {
          //   _copyAndExpand(x, y, {});
          // }
          progress = true;
          continue;
        }
      }
    }
    return progress;
  }

  _FieldInfo _fillInFieldInfo(int x, int y) {
    var res = _FieldInfo();
    res.value = _fields[x][y];
    res.uncovered = getNeighbors(x, y, (val) => val == uncovered).length;
    res.mayBeMines = getNeighbors(x, y, (val) => val == maybeMine).length;
    res.coveredFields = getNeighbors(x, y, (val) => val == covered);
    return res;
  }

  bool _gameSolved() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        if (_fields[x][y] == covered) {
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
        clone._fields[x][y] = _fields[x][y];
      }
    }
    clone.mineField = mineField;
    return clone;
  }

  /// For debug output only
  void dump() {
    String res = '\n';
    String resGame = '';
    for (int y = 0; y < mineField.h; y++) {
      for (int x = 0; x < mineField.w; x++) {
        res += mineField._dumpField(x, y);
        resGame += _dumpField(x, y);
      }
      res += '\t$resGame\n';
      resGame = '';
    }
    if (kDebugMode) {
      print(res);
    }
  }
}

class _FieldInfo {
  int value = 0;
  int uncovered = 0;
  int mayBeMines = 0;
  Set<(int, int)> coveredFields = {};
}
