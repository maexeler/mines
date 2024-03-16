import 'package:flutter/material.dart';
import 'package:mines/provider/full_screen_provider.dart';
import 'package:provider/provider.dart';

import 'package:mines/provider/game_provider.dart';
import 'package:mines/provider/settings_provider.dart';
import 'package:mines/provider/game_time_provider.dart';
import 'package:mines/provider/game_status_provider.dart';
import 'package:mines/provider/game_remaining_mines_provider.dart';

import 'package:mines/model/mines_game.dart';
import 'package:mines/pages/mines_page/mines_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FullScreenProvider fullScreenProvider = FullScreenProvider();
  fullScreenProvider.initialize();

  SettingsProvider settingsProvider = SettingsProvider();
  settingsProvider.initialize();

  GameProvider gameProvider = GameProvider();
  MinesTimeProvider minesTimerProvider = MinesTimeProvider();
  MinesGameStateProvider minesStateProvider = MinesGameStateProvider();
  RemainingMinesProvider remainingMinesProvider = RemainingMinesProvider();

  // We need a MinesGame but we will access it only by it's providers
  // ignore: unused_local_variable
  MinesGame minesGame = MinesGame(
    timer: minesTimerProvider,
    gameInterfaceProvider: gameProvider,
    minesState: minesStateProvider,
    settings: settingsProvider,
    remainingMinesProvider: remainingMinesProvider,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => gameProvider),
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => minesTimerProvider),
        ChangeNotifierProvider(create: (_) => minesStateProvider),
        ChangeNotifierProvider(create: (_) => remainingMinesProvider),
        ChangeNotifierProvider(create: (_) => fullScreenProvider),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MinesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
