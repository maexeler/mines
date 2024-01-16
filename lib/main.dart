import 'package:flutter/material.dart';
import 'package:mines/model/mines.dart';

void main() {
  runApp(const MinesApp());
}

class MinesApp extends StatelessWidget {
  const MinesApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mines',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MinesPage(title: 'Mines'),
    );
  }
}

class MinesPage extends StatefulWidget {
  const MinesPage({super.key, required this.title});

  final String title;

  @override
  State<MinesPage> createState() => _MinesPageState();
}

class _MinesPageState extends State<MinesPage> {
  final game = MinesGame(5, 5);

  _MinesPageState() {
    game.startGame(0, 0, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Container(),
        ));
  }
}
