import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'MyHomePage.dart';

final logger = Logger('TrainLogger');

// logger.level = Loglev
late final MyApp myApp;

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  logger.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  myApp = MyApp();
  runApp(myApp);
}

class MyApp extends StatelessWidget {
  late final Widget homePage;
  MyApp({Key? key}) : super(key: key) {
    homePage = const MyHomePage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pong game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: homePage);
  }
}
