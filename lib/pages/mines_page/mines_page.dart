import 'package:flutter/material.dart';

import 'package:Minesweeper/pages/mines_page/components/mines_field.dart';
import 'package:Minesweeper/pages/mines_page/components/mines_footer.dart';
import 'package:Minesweeper/pages/mines_page/components/mines_header.dart';
import 'package:Minesweeper/provider/full_screen_provider.dart';
import 'package:Minesweeper/provider/game_provider.dart';
import 'package:Minesweeper/provider/game_time_provider.dart';
import 'package:provider/provider.dart';

class MinesPage extends StatefulWidget {
  const MinesPage(this.gameProvider, this._minesTimeProvider, {super.key});
  final MinesTimeProvider _minesTimeProvider;
  final GameProvider gameProvider;

  @override
  State<MinesPage> createState() => _MinesPageState();
}

class _MinesPageState extends State<MinesPage> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        if (widget.gameProvider.isRunning) {
          widget._minesTimeProvider.resumeTimer();
        }
      },
      onPause: () {
        widget._minesTimeProvider.stopTimer();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FullScreenProvider provider = Provider.of<FullScreenProvider>(context);
    if (provider.isFullScreenMode) {
      return Scaffold(
        body: minesBody(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Minesweeper'), //MinesHeader(),
        ),
        body: minesBody(),
      );
    }
  }
}

Widget minesBody() => const Column(
      children: [
        MinesHeader(),
        Expanded(child: MinesFieldWidget()),
        MinesFooter()
      ],
    );
