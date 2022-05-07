import 'package:flutter/material.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';
import 'Wall.dart';

class Screen {
  static const centerToSide = 1.0;
  static const sideToSide = centerToSide * 2;
  static const centerToPlayer = 1.0;
}

class MyHomePage extends StatefulWidget {
  static const ballSize = 0.05;
  static const wallT = 0.04; // wall thickness1 per 1
  const MyHomePage({Key? key}) : super(key: key);
  static const mainText = 'Pong game';
  static String statusBar = '$mainText';
  static String wallMsg = '';
  static IllumeController gameController = IllumeController();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// Quick demo for vertical screens
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
  List<WallO> get walls => [topWall, bottomWall, leftWall, rightWall];
  IllumeController get gameController => MyHomePage.gameController;

  _MyHomePageState() {
    ball = BallO.withAngle(speed, RandAngleIterator(14).current);
    topWall = WallO(wallPos.top, ball);
    bottomWall = WallO(wallPos.bottom, ball);
    rightWall = WallO(wallPos.right, ball);
    leftWall = WallO(wallPos.left, ball);
  }

  @override
  void initState() {
    super.initState();
    gameController.startGame();
    MyHomePage.statusBar = MyHomePage.mainText + ":started";
    gameController.gameObjects
        .addAll([topWall, bottomWall, leftWall, rightWall, ball]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ball.forward();
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

class BouncerO extends GameObject {
  var velocity = Vector2(0, 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: const Text('Demo'),
    );
  }

  @override
  void init() {
    size = Vector2.all(50);
    alignment = GameObjectAlignment.center;
    position = (gameSize / 2);
  }

  @override
  void onCollision(List<Collision> collisions) {
    illumeController.stopGame();
  }

  @override
  void onScreenSizeChange(Vector2 size) {}

  @override
  void update(Duration delta) {
    position += velocity;
  }
}
