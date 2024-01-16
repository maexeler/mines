import 'dart:math' as math;
//import 'dart:developer';
// import 'dart:html';

const int mine = -1;
const int empty = 0;
const int one = 1;
const int two = 2;
const int three = 3;
const int four = 4;
const int five = 5;
const int six = 6;
const int seven = 7;
const int eight = 8;
const int unknown = 9;

const covered = 10;
const uncovered = 11;
const maybeMine = 12;

class Grid {
  int w, h;
  final List<List<int>> _fields;
  Grid(this.w, this.h, int initialValue)
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

  void _fillWith(int value) {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        _fields[x][y] = value;
      }
    }
  }
}

class MineField extends Grid {
  final rnd = math.Random();

  MineField(int w, int h) : super(w, h, empty);

  void intitMineField(int xs, int ys, double percent) {
    int mines = (w * h * percent / 100).round();
    // Start empty
    _fillWith(empty);
    // Fill in mines
    while (mines > 0) {
      // No bomb at start position and only one bomb at each location
      int x = rnd.nextInt(w);
      int y = rnd.nextInt(h);
      if (x == xs && y == ys || getField(x, y) == mine) {
        continue;
      }

      // Change coordinate system to local
      // and set mine
      _fields[x][y] = mine;
      mines--;

      // Update the surrounding field values
      setField(x - 1, y - 1, getField(x - 1, y - 1) + 1);
      setField(x - 1, y, getField(x - 1, y) + 1);
      setField(x - 1, y + 1, getField(x - 1, y + 1) + 1);
      setField(x, y - 1, getField(x, y - 1) + 1);
      setField(x, y + 1, getField(x, y + 1) + 1);
      setField(x + 1, y - 1, getField(x + 1, y - 1) + 1);
      setField(x + 1, y, getField(x + 1, y) + 1);
      setField(x + 1, y + 1, getField(x + 1, y + 1) + 1);
    }
  }
}

class GameField extends Grid {
  late MineField mineField;

  GameField(int w, int h) : super(w, h, empty);

  void initFromMineField(MineField mineField, int xs, int ys) {
    this.mineField = mineField;
    _fillWith(covered);
    // Transfer the start value
    _copyAndExpand(xs, ys, <(int, int)>{});
  }

  void _copyAndExpand(int x, int y, Set<(int, int)> allreadyProcessed) {
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
      _copyAndExpand(element.$1, element.$2, allreadyProcessed);
    }
  }

  bool solveGame() {
    while (!_gameSolved()) {
      while (_solveField()) {}
    }
    return true;
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
          progress = true;
          continue;
        }
        // Check if remaining field may savely be uncovered
        if (fieldInfo.mayBeMines == fieldInfo.value) {
          for (var (x, y) in fieldInfo.coveredFields) {
            _copyAndExpand(x - 1, y - 1, {});
          }
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
      for (int y = h; y < h; y++) {
        if (_fields[x][y] == covered) {
          return false;
        }
      }
    }
    return true;
  }
}

class _FieldInfo {
  int value = 0;
  int uncovered = 0;
  int mayBeMines = 0;
  Set<(int, int)> coveredFields = {};
}

class MinesGame {
  int w, h;
  late MineField mineField;
  late GameField gameField;
  MinesGame(this.w, this.h);

  void initNewGame(int xs, int ys, double percent) {
    mineField = MineField(w, h);
    gameField = GameField(w, h);

    mineField.intitMineField(xs, ys, percent);
    gameField.initFromMineField(mineField, xs, ys);
  }

  void startGame(int xs, int ys, double percent) {
    xs = xs % w;
    ys = ys % h;
    // Generate and solve the game
    do {
      initNewGame(xs, ys, percent);
      dump();
    } while (!gameIsSolvable());
    // now start the game
    dump();
    gameField.initFromMineField(mineField, xs, ys);
    // TODO notify observers
  }

  bool gameIsSolvable() {
    return gameField.solveGame();
  }

  void dump() {
    String res = '\n';
    String resGame = '';
    for (int x = 0; x < mineField.w; x++) {
      for (int y = 0; y < mineField.h; y++) {
        res += dumpField(mineField, x, y);
        resGame += dumpField(gameField, x, y);
      }
      res += '\t$resGame\n';
      resGame = '';
    }
    print(res);
  }

  String dumpField(Grid field, int x, int y) {
    if (field.getField(x, y) == mine) {
      return 'x';
    } else if (field.getField(x, y) == empty) {
      return '_';
    } else if (field.getField(x, y) == covered) {
      return 'c';
    } else if (field.getField(x, y) == uncovered) {
      return 'u';
    } else if (field.getField(x, y) == maybeMine) {
      return 'm';
    } else {
      return field.getField(x, y).toString();
    }
  }
}
