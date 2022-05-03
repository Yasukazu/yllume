import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'MyHomePage.dart';

final logger = Logger('TrainLogger');
late final MyApp myApp;

void main() {
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
      title: 'Train Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: homePage
    );
  }
}
