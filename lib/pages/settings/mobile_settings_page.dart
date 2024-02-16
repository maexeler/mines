import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mines/components/covered_button.dart';
import 'package:mines/pages/settings/settings_provider.dart';
import 'package:provider/provider.dart';

class MobileSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
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
              child: CellSizeWidget(settingsProvider),
            )),
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
          max: 1.00,
          value: _value,
          onChanged: (double value) {
            setState(() {
              _value = value;
              // widget.settingsProvider.percentCellSize = value;
            });
          },
        ),
        Row(
          // This Row is only used to center its content
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizeableCellsWidget(shortSide, _value,
                widget.settingsProvider.maxCellsForShortSide),
          ],
        ),
      ],
    );
  }
}

class SizeableCellsWidget extends StatelessWidget {
  SizeableCellsWidget(
      this.shortestSide, this.percentCellSize, this.maxCellsForShortSide);
  final double shortestSide;
  final double percentCellSize;
  final double maxCellsForShortSide;

  @override
  Widget build(BuildContext context) {
    var cellSize = shortestSide / maxCellsForShortSide;
    cellSize += cellSize * percentCellSize;
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
    _value = min(widget.settingsProvider.maxPercentMines,
        widget.settingsProvider.percentMines);
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
          min: widget.settingsProvider.minPercentMines,
          max: widget.settingsProvider.maxPercentMines,
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
