import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _initialized = false;
  late SharedPreferences _prefs;

  double _percentMines = 20;
  double _percentCellSize = 0.055;
  static final double _maxCellsForShortSide = 12;

  bool get isInitialized => _initialized;

  void initialize() async {
    _prefs = await SharedPreferences.getInstance();
    load();
    _initialized = true;
    notifyListeners();
  }

  static double calcCellSize(double fromShortSide, double percent) {
    var cellSize = fromShortSide / _maxCellsForShortSide;
    cellSize = cellSize + cellSize * percent;
    return cellSize;
  }

  static final double minPercentMines = 10;
  static final double maxPercentMines = 30;
  double get percentMines => _percentMines;
  void set percentMines(double value) {
    _percentMines = value;
    save();
  }

  double get percentCellSize => _percentCellSize;
  void set percentCellSize(double value) {
    _percentCellSize = value;
    save();
  }

  void load() {
    _percentMines = _prefs.getDouble('percent_mines') ?? 20;
    _percentCellSize = _prefs.getDouble('percent_cell_size') ?? 0.1;
  }

  void save() {
    _prefs.setDouble('percent_mines', _percentMines);
    _prefs.setDouble('percent_cell_size', _percentCellSize);
  }
}
