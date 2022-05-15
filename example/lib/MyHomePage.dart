import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';
import 'WallBase.dart';
import 'Wall.dart';
import 'Paddle.dart';

class Screen {
  static const centerToSide = 1.0;
  static const sideToSide = centerToSide * 2;
  static const centerToPlayer = 1.0;
}

class MyHomePage extends StatefulWidget {
  static const ballSize = 0.05;
  static const wallT = 0.04; // wall thickness1 per 1
  static const paddleStep = 0.1;
  static const paddleWidth = 0.25;
  const MyHomePage({Key? key}) : super(key: key);
  static const mainText = 'Pong game';
  static String statusBar = '$mainText';
  static String wallMsg = '';
  static IllumeController gameController = IllumeController();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// Pong game
class _MyHomePageState extends State<MyHomePage> {
  // FlappyWidget flappyWidget = FlappyWidget();
  // Wall wall = Wall(200, false);
  // Wall wall2 = Wall(400, true);
  static const speed = 100;
  late final BallO ball;
  late final WallO topWall;
  late final WallO bottomWall;
  late final WallO leftWall;
  late final WallO rightWall;
  late final PaddleO enemyPaddle;
  late final PaddleO selfPaddle;
  List<WallO> get walls => [topWall, bottomWall, leftWall, rightWall];
  IllumeController get gameController => MyHomePage.gameController;
  bool gameStarted = false;

  _MyHomePageState() {
    ball = BallO.withAngle(speed, RandAngleIterator(14).current);
    topWall = WallO(wallPos.top);
    bottomWall = WallO(wallPos.bottom);
    rightWall = WallO(wallPos.right);
    leftWall = WallO(wallPos.left);
    enemyPaddle = PaddleO(wallPos.top, MyHomePage.paddleWidth, MyHomePage.paddleStep);
    selfPaddle = PaddleO(wallPos.bottom, MyHomePage.paddleWidth, MyHomePage.paddleStep);
  }

  @override
  void initState() {
    super.initState();
    // gameController.startGame();
    MyHomePage.statusBar = MyHomePage.mainText + ":started";
    gameController.gameObjects.addAll([
      topWall,
      bottomWall,
      leftWall,
      rightWall,
      ball,
      enemyPaddle,
      selfPaddle
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          logger.info("arrowLeft key");
          selfPaddle.moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          logger.info("arrowRight key");
          selfPaddle.moveRight();
        }
      },
      child: GestureDetector(
        onTap: () {
          if (!gameStarted) {
            gameController.startGame();
            gameStarted = true;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(MyHomePage.statusBar),
          ),
          body: Stack(
            children: [
              gradient,
              Illume(
                illumeController: gameController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  var gradient = Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
          colors: [Colors.teal, Colors.deepPurple],
          stops: [0.0, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
    ),
  );
}

class GameEndException implements Exception {
  late final String _message;

  GameEndException([String message = 'Game end.']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
