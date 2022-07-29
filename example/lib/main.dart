import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'pongPage.dart';

final logger = Logger('TrainLogger');

late final PongGame pongGame;

void main() {
  Logger.root.level = Level.FINE; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.message}'); // ${record.time}:
  });
  pongGame = PongGame();
  runApp(pongGame);
}

class PongGame extends StatelessWidget {
  late final Widget pongPage;
  PongGame({Key? key}) : super(key: key) {
    pongPage = const PongGamePage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pong game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: pongPage);
  }
}
