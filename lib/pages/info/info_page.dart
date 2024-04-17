import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Instruction(),
            State(),
            Actions(),
            AboutMe(),
          ],
        ),
      ),
    );
  }
}

class Instruction extends TopicWidget {
  static final info = [
    (Text('tab a field'), 'to reveale the field content'),
    (Text('long tab or \ndouble tab a field'), 'to mark a fields as mine'),
  ];
  Instruction() : super('Instructions', info);
}

class State extends TopicWidget {
  static final info = [
    (Text('😀'), 'Game is solvable'),
    (Text('😐'), 'Game is only solvable with guessing'),
    (Text('😀😀'), 'You have won'),
    (Text('🙁🙁'), 'You have lost the game'),
  ];
  State() : super('Game State', info);
}

class Actions extends TopicWidget {
  static final info = [
    (Icon(Icons.play_circle), 'Start a new game'),
    (Icon(Icons.replay_circle_filled), 'Replay the last game'),
    (Icon(Icons.help), 'Show a hint'),
    (Icon(Icons.undo), 'Undo the last move'),
  ];
  Actions() : super('Game Actions', info);
}

class TopicWidget extends StatelessWidget {
  TopicWidget(this.title, this.data);
  final String title;
  final List<(Widget, String)> data;

  @override
  Widget build(BuildContext context) {
    data.map((row) {
      return TableRow(children: [
        row.$1,
        Text(row.$2),
      ]);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$title',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Table(
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(4),
            },
            border: TableBorder.all(width: 1, color: Colors.grey),
            children: data.map((row) {
              return TableRow(children: [
                Padding(padding: const EdgeInsets.all(8), child: row.$1),
                Padding(padding: const EdgeInsets.all(8), child: Text(row.$2)),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class AboutMe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'About me',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(19),
                      bottomLeft: Radius.circular(19),
                      bottomRight: Radius.circular(19),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '''Hi I am Max
I’ve been playing the Minesweeper classic from 'Dev Null' for years, but with the latest update, he added ads, which sucks.
So I decided to write my own game with all the bells and whistles I always wanted.
I promise:
\t\u25CF no advertising
\t\u25CF no tracking
\t\u25CF no analytics
Never ever.
\nYou can find the source code at ''',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Github',
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse(
                                  'https://github.com/maexeler/mines'));
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CustomPaint(
                  painter: Triangle(
                Colors.grey.shade300,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

// Create a custom triangle
class Triangle extends CustomPainter {
  final Color backgroundColor;
  Triangle(this.backgroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = backgroundColor;

    var path = Path();
    path.lineTo(-10, 0);
    path.lineTo(0, -10);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
