enum GameStat {
  startingUp,
  unInitialized,
  calculating,
  initialized,
  running,
  win,
  gameOver
}

class FieldValue {
  int _value = empty;
  bool get isMine => isExploded || (_value % _highlightOffset) == mine;
  bool get isNotMine => !isMine;
  bool get isEmpty => (_value % _highlightOffset) == empty;
  bool get isNotEmpty => !isEmpty;
  bool get isNumber =>
      (_value % _highlightOffset) >= 1 && (_value % _highlightOffset) <= 8;
  bool get isNotNumber => !isNumber;

  bool get isCovered => (_value % _highlightOffset) == covered;
  bool get isUncovered => !isCovered;
  bool get isMaybeMine => (_value % _highlightOffset) == maybeMine;
  bool get isNotMaybeMine => (_value % _highlightOffset) == notMaybeMine;

  bool get isHint => _value > 100;

  bool get isExploded => _value == mine + 20;

  // Value handling
  set value(int value) {
    assert(value >= empty && value <= notMaybeMine);
    _value = value;
  }

  void add(int value) {
    _value += value;
    assert(isNumber);
  }

  int get value => _value % _highlightOffset;

  // Hint handling

  void setHint() {
    _value = value + _highlightOffset;
  }

  void resetHint() {
    _value = value % _highlightOffset;
  }

  // Marking for exploded

  void markExploded() {
    _value += 20;
  }

  static int empty = 0;
  static int one = 1;
  static int two = 2;
  static int three = 3;
  static int four = 4;
  static int five = 5;
  static int six = 6;
  static int seven = 7;
  static int eight = 8;
  static int mine = 9;

  static int covered = 10;
  static int uncovered = 11;
  static int maybeMine = 12;
  static int notMaybeMine = 13;

  static const int _highlightOffset = 150;
}
