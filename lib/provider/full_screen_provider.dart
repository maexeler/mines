import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullscreen_window/fullscreen_window.dart';

class FullScreenProvider extends ChangeNotifier {
  bool _fullScreenMode = false;
  late SharedPreferences _prefs;

  void initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
    FullScreenWindow.setFullScreen(_fullScreenMode);
    notifyListeners();
  }

  bool get isFullScreenMode => _fullScreenMode;
  void set fullSceenMode(bool value) {
    if (value == _fullScreenMode) return;

    _fullScreenMode = value;
    FullScreenWindow.setFullScreen(_fullScreenMode);
    notifyListeners();
    _save();
  }

  void _save() {
    _prefs.setBool('full_screen_mode', _fullScreenMode);
  }

  void _load() {
    _fullScreenMode = _prefs.getBool('full_screen_mode') ?? true;
  }
}
