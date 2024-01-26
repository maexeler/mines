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

const int covered = 10;
const int uncovered = 11;
const int maybeMine = 12;
const int notMaybeMine = 13;

enum GameStat { unInitialized, initialized, running, win, gameOver }

class FieldValue {
  int _value = empty;
  bool get isMine => (_value % _highlightOffset) == mine;
  bool get isEmpty => (_value % _highlightOffset) == empty;
  bool get isNumber =>
      (_value % _highlightOffset) >= 1 && (_value % _highlightOffset) >= 8;

  set value(int value) {
    assert(value >= mine && value <= notMaybeMine);
    _value = value;
  }

  void add(int value) {
    _value += value;
    assert(value >= mine && value <= notMaybeMine);
  }

  int get value => _value % _highlightOffset;

  bool get isCovered => (_value % _highlightOffset) == covered;
  bool get isMaybeMine => (_value % _highlightOffset) == maybeMine;
  bool get isNotMaybeMine => (_value % _highlightOffset) == notMaybeMine;

  bool get isMarked => _value > 100;

  void setMarked() {
    _value += _highlightOffset;
  }

  void resetMarked() {
    _value = value % _highlightOffset;
  }

  static int mine = -1;
  static int empty = 0;
  static int one = 1;
  static int two = 2;
  static int three = 3;
  static int four = 4;
  static int five = 5;
  static int six = 6;
  static int seven = 7;
  static int eight = 8;

  static int covered = 10;
  static int uncovered = 11;
  static int maybeMine = 12;
  static int notMaybeMine = 13;

  static const int _highlightOffset = 150;
}
