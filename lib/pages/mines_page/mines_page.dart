import 'package:flutter/material.dart';

import 'package:mines/pages/mines_page/components/mines_field.dart';
import 'package:mines/pages/mines_page/components/mines_footer.dart';
import 'package:mines/pages/mines_page/components/mines_header.dart';
import 'package:mines/provider/full_screen_provider.dart';
import 'package:provider/provider.dart';

class MinesPage extends StatelessWidget {
  const MinesPage({super.key});

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
