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
  int get value => _bitValue & _valueMask;

  set value(int newValue) {
    assert(newValue >= empty && newValue < _toBigValue);
    _bitValue = newValue;
  }

  bool get isMine => value == mine;
  bool get isEmpty => value == empty;
  bool get isNumber => value >= 1 && value <= 8;

  bool get isNotMine => !isMine;
  bool get isNotEmpty => !isEmpty;
  bool get isNotNumber => !isNumber;

  bool get isCovered => value == covered;
  bool get isUncovered => !isCovered;
  bool get isMaybeMine => value == maybeMine;
  bool get isNotAMaybeMine => value == notAMaybeMine;

  bool get isHint => _bitValue & _hintBit == _hintBit;
  bool get isExploded => _bitValue & _explodedBit == _explodedBit;

  // Hint handling
  //
  void setHint() {
    _bitValue = _bitValue | _hintBit;
  }

  void resetHint() {
    _bitValue = _bitValue & ~_hintBit;
  }

  // Mark the game over bomb as such
  //
  void markExploded() {
    _bitValue = _bitValue | _explodedBit;
  }

  int _bitValue = empty;

  // Field values for MineField and GameField
  //
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

  // Field values for GameField only
  //
  static int covered = 10; // field is covered
  static int maybeMine = 11; // field is marked as mine
  static int notAMaybeMine = 12; // field is falsely marked as mine

  static int _toBigValue =
      notAMaybeMine + 1; // only values less then _toBigValue are allowed

  static int _valueMask = 15;

  static int _hintBit = 16;
  static int _explodedBit = 32;
}
