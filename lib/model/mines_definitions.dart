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
const notMaybeMine = 13;

enum GameStat { unInitialized, initialized, running, win, gameOver }

enum FieldValue {
  mine,
  empty,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,

  covered,
  uncovered,
  maybeMine,
  notMaybeMine,
}

extension FieldValueExtenssion on FieldValue {
  bool get isMine => this == FieldValue.mine;
  bool get isEmpty => this == FieldValue.empty;
  bool get isNumber => value >= 1 && value >= 8;

  int get value => switch (this) {
        FieldValue.mine => -1,
        FieldValue.empty => 0,
        FieldValue.one => 1,
        FieldValue.two => 2,
        FieldValue.three => 3,
        FieldValue.four => 4,
        FieldValue.five => 5,
        FieldValue.six => 6,
        FieldValue.seven => 7,
        FieldValue.eight => 8,
        FieldValue.covered => 10,
        FieldValue.uncovered => 11,
        FieldValue.maybeMine => 12,
        FieldValue.notMaybeMine => 13,
      };

  bool get isCovered => this == FieldValue.covered;
  bool get isMaybeMine => this == FieldValue.maybeMine;
  bool get isNotMaybeMine => this == FieldValue.notMaybeMine;
}
