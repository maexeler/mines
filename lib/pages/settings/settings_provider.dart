import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
  late SharedPreferences prefs;

  double _percentMines = 20;
  double _percentCellSize = 0.055;
  final double _maxCellsForShortSide = 12;

  void initialize() async {
    prefs = await SharedPreferences.getInstance();
    load();
    print('SettingsProvider.initialize');
  }

  double calcCellSize(double fromShortSide) {
    var cellSize = fromShortSide / _maxCellsForShortSide;
    cellSize = cellSize + cellSize * _percentCellSize;
    print('SettingsProvider.calcCellSize ${cellSize}');
    return cellSize;
  }

  final double minPercentMines = 10;
  final double maxPercentMines = 30;
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
    _percentMines = prefs.getDouble('percent_mines') ?? 20;
    _percentCellSize = prefs.getDouble('percent_cell_size') ?? 0.1;
  }

  void save() {
    prefs.setDouble('percent_mines', _percentMines);
    prefs.setDouble('percent_cell_size', _percentCellSize);
  }
}
