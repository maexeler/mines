import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mines/pages/mines_page/components/mines_button/mines_button.dart';
import 'package:mines/provider/full_screen_provider.dart';
import 'package:mines/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class LayoutSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settingsProvider = Provider.of<SettingsProvider>(context);
    var fullScreenProvider = Provider.of<FullScreenProvider>(context);
    bool isPortraitMode =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        title: Text('Layout settings'),
      ),
      body: SingleChildScrollView(
        child: isPortraitMode
            ? Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FullScreenWidget(fullScreenProvider),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CellSizeWidget(settingsProvider),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CellSizeWidget(settingsProvider),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FullScreenWidget(fullScreenProvider),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class DifficultySettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settingsProvider = Provider.of<SettingsProvider>(context);
    bool isPortraitMode =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        title: Text('Difficulty settings'),
      ),
      body: SingleChildScrollView(
        child: isPortraitMode
            ? Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MinesPercentWidget(settingsProvider),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MinesTimeoutWidget(settingsProvider),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MinesPercentWidget(settingsProvider),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MinesTimeoutWidget(settingsProvider),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class CellSizeWidget extends StatefulWidget {
  final SettingsProvider settingsProvider;
  CellSizeWidget(this.settingsProvider);

  @override
  State<CellSizeWidget> createState() => _CellSizeWidgetState();
}

class _CellSizeWidgetState extends State<CellSizeWidget> {
  double _value = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.settingsProvider.percentCellSize;
  }

  void dispose() {
    widget.settingsProvider.percentCellSize = _value;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var shortSide = MediaQuery.of(context).size.shortestSide;
    return Column(
      children: [
        Text('Choose the size of the Minefields'),
        Slider(
          min: 0,
          max: 1,
          value: _value,
          onChanged: (double value) {
            setState(() {
              _value = value;
            });
          },
        ),
        Row(
          // This Row is only used to center its content
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizeableCellsWidget(shortSide, _value),
          ],
        ),
      ],
    );
  }
}

class SizeableCellsWidget extends StatelessWidget {
  SizeableCellsWidget(this.shortestSide, this.percent);
  final double shortestSide;
  final double percent;

  @override
  Widget build(BuildContext context) {
    var cellSize = SettingsProvider.calcCellSize(shortestSide, percent);
    return Column(
      children: [
        for (var i = 0; i < 4; i++)
          Row(
            children: [
              for (var j = 0; j < 4; j++)
                SizedBox(
                  height: cellSize,
                  width: cellSize,
                  child: MineButtonDisplay(),
                ),
            ],
          ),
      ],
    );
  }
}

class MinesPercentWidget extends StatefulWidget {
  MinesPercentWidget(this.settingsProvider);
  final SettingsProvider settingsProvider;

  @override
  State<MinesPercentWidget> createState() => _MinesPercentWidgetState();
}

class _MinesPercentWidgetState extends State<MinesPercentWidget> {
  double _value = 20;

  @override
  void initState() {
    super.initState();
    _value = min(
        SettingsProvider.maxPercentMines, widget.settingsProvider.percentMines);
  }

  void dispose() {
    widget.settingsProvider.percentMines = _value;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Choose the percentage of Mines'),
        Text('${_value.toStringAsFixed(0)}%'),
        Slider(
          min: SettingsProvider.minPercentMines,
          max: SettingsProvider.maxPercentMines,
          value: _value,
          onChanged: (double value) {
            setState(() {
              _value = value;
            });
          },
        ),
        Column(
          children: [
            RadioListTile<double>(
                title: Text('Easy'),
                value: 15,
                groupValue: _value,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _value = value;
                  });
                }),
            RadioListTile<double>(
                title: Text('Medium'),
                value: 20,
                groupValue: _value,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _value = value;
                  });
                }),
            RadioListTile<double>(
                title: Text('Hard'),
                value: 25,
                groupValue: _value,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _value = value;
                  });
                }),
          ],
        )
      ],
    );
  }
}

class MinesTimeoutWidget extends StatefulWidget {
  MinesTimeoutWidget(this.settingsProvider);
  final SettingsProvider settingsProvider;

  @override
  State<MinesTimeoutWidget> createState() => _MinesTimeoutWidgetState();
}

class _MinesTimeoutWidgetState extends State<MinesTimeoutWidget> {
  int _value = 5;

  @override
  void initState() {
    super.initState();
    _value = widget.settingsProvider.timeOut;
  }

  void dispose() {
    widget.settingsProvider.timeOut = _value;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Choose the solver time'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: RadioListTile<int>(
                  title: Text('5'),
                  value: 5,
                  groupValue: _value,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _value = value;
                    });
                  }),
            ),
            Expanded(
              child: RadioListTile<int>(
                  title: Text('15'),
                  value: 15,
                  groupValue: _value,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _value = value;
                    });
                  }),
            ),
            Expanded(
              child: RadioListTile<int>(
                  title: Text('25'),
                  value: 25,
                  groupValue: _value,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _value = value;
                    });
                  }),
            ),
          ],
        )
      ],
    );
  }
}

class FullScreenWidget extends StatefulWidget {
  FullScreenWidget(this.fullScreenProvider);
  final FullScreenProvider fullScreenProvider;

  @override
  State<FullScreenWidget> createState() => _FullScreenWidgetState();
}

class _FullScreenWidgetState extends State<FullScreenWidget> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.fullScreenProvider.isFullScreenMode;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
            value: _value,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _value = value;
                widget.fullScreenProvider.fullSceenMode = _value;
              });
            }),
        Text('Full screen mode'),
      ],
    );
  }
}
