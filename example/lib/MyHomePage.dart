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
  static const wallT = 5.0; // wall thickness1
  const MyHomePage({Key? key}) : super(key: key);
  static const mainText = 'Pong game';
  static String statusBar = '$mainText';
  static BallO ball = BallO();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// Quick demo for vertical screens
class _MyHomePageState extends State<MyHomePage> {
  IllumeController gameController = IllumeController();

  // FlappyWidget flappyWidget = FlappyWidget();
  // Wall wall = Wall(200, false);
  // Wall wall2 = Wall(400, true);
  final topWall = WallO(wallPos.top);
  final bottomWall = WallO(wallPos.bottom);
  final leftWall = WallO(wallPos.left);
  final rightWall = WallO(wallPos.right);
  List<WallO> get walls => [topWall, bottomWall, leftWall, rightWall];

  @override
  void initState() {
    super.initState();
    gameController.startGame();
    MyHomePage.statusBar = MyHomePage.mainText + ":started";
    MyHomePage.ball = BallO.withAngle(100, 30);
    gameController.gameObjects.addAll([MyHomePage.ball, topWall, bottomWall, leftWall, rightWall]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // flappyWidget.jump();
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
  void onScreenSizeChange(Vector2 size) {
  }

  @override
  void update(Duration delta) {
    position += velocity;
  }
}