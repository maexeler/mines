import 'package:flutter/material.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:mines/pages/settings/settings_provider.dart';
import 'package:provider/provider.dart';

import 'package:mines/model/mines.dart';
import 'package:mines/model/mines_timer.dart';
import 'package:mines/pages/mines_page/mines_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SettingsProvider settingsProvider = SettingsProvider();
  settingsProvider.initialize();

  MinesTimer minesTimer = MinesTimer();
  MinesGame minesGame =
      MinesGame(timer: minesTimer, settings: settingsProvider);

  FullScreenWindow.setFullScreen(true);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => minesTimer),
        ChangeNotifierProvider(create: (_) => minesGame),
      ],
      child: const MinesApp(),
    ),
  );
}

class MinesApp extends StatelessWidget {
  const MinesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solvable Mines',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MinesPage('Solvable Minesweeper'),
      debugShowCheckedModeBanner: false,
    );
  }
}
