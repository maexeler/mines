import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
  late SharedPreferences prefs;

  double _percentMines = 20;
  double _percentCellSize = 50;

  void initialize() async {
    prefs = await SharedPreferences.getInstance();
    load();
  }

  final double minPercentMines = 10;
  final double maxPercentMines = 30;
  double get percentMines => _percentMines;
  void set percentMines(double value) {
    _percentMines = value;
    save();
  }

  final double maxCellsForShortSide = 12;

  double get percentCellSize => _percentCellSize;
  void set percentCellSize(double value) {
    _percentCellSize = value;
    save();
  }

  void load() {
    _percentMines = prefs.getDouble('percent_mines') ?? 20;
    _percentCellSize = prefs.getDouble('percent_cell_size') ?? 50;
  }

  void save() {
    prefs.setDouble('percent_mines', _percentMines);
    prefs.setDouble('percent_cell_size', _percentCellSize);
    load();
  }
}
