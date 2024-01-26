import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mines/model/mines.dart';
import 'package:mines/model/mines_timer.dart';
import 'package:mines/pages/mines_page/mines_page.dart';

void main() {
  MinesTimer minesTimer = MinesTimer();
  MinesGame minesGame = MinesGame(7, 12, timer: minesTimer);

  runApp(
    MultiProvider(
      providers: [
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
    );
  }
}
