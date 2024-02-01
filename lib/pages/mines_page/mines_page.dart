import 'package:flutter/material.dart';
import 'package:mines/model/mines.dart';
import 'package:mines/model/mines_definitions.dart';

import 'package:mines/pages/mines_page/components/mines_field.dart';
import 'package:mines/pages/mines_page/components/mines_footer.dart';
import 'package:mines/pages/mines_page/components/mines_header.dart';
import 'package:provider/provider.dart';

class MinesPage extends StatelessWidget {
  final String title;

  const MinesPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Consumer<MinesGame>(
        builder: (context, minesGame, child) => Container(
          color: minesGame.gameStatus == GameStat.gameOver
              ? Colors.red.shade100
              : minesGame.gameStatus == GameStat.win
                  ? Colors.green.shade100
                  : Colors.yellow.shade100,
          child: const Column(
            children: [
              MinesHeader(),
              Expanded(child: MinesField()),
              MinesFooter()
            ],
          ),
        ),
      ),
    );
  }
}
