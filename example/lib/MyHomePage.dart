import 'package:flutter/material.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';

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
  final ball = BallO.withAngle(100, 30);

  @override
  void initState() {
    super.initState();
    gameController.startGame();
    MyHomePage.statusBar = MyHomePage.mainText + ":started";
    gameController.gameObjects.addAll([ball, topWall, bottomWall, leftWall, rightWall]);
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


enum wallPos {top, bottom, left, right}
enum gameSizez {sizeX, sizeY}
typedef Vector2 v2ToV2(Vector2 vector2);

class WallO extends GameObject {
  static const shape = BoxShape.rectangle;
  static const b = MyHomePage.wallT;
  static topOffset(Vector2 gameSize) => Vector2(gameSize[0] / 2, b / 2);
  static leftOffset(Vector2 gameSize) => Vector2(b / 2, gameSize[1] / 2);
  static bottomOffset(Vector2 gameSize) => Vector2(gameSize[0] / 2, gameSize[1] - b / 2);
  static rightOffset(Vector2 gameSize) => Vector2(gameSize[0] - b / 2, gameSize[1] / 2);
  static const offsets = [topOffset, leftOffset, bottomOffset, rightOffset];
  double get x => offset[0];
  double get y => offset[1];
  Vector2 get offset {
    switch(pos) {
      case wallPos.top: return topOffset(gameSize);
      case wallPos.left: return leftOffset(gameSize);
      case wallPos.bottom: return bottomOffset(gameSize);
      case wallPos.right: return rightOffset(gameSize) ;
    }
  }
  Vector2 get rect {
    switch(pos) {
      case wallPos.top:
      case wallPos.bottom:
        return Vector2(gameSize[0], b);
      case wallPos.left:
      case wallPos.right:
        return Vector2(b, gameSize[1]);
    }
  }
  final wallPos pos;

  WallO(this.pos);

  @override
  void init() {
    size = rect;
    alignment = GameObjectAlignment.center;
    position = offset;
  }

  @override
  Widget build(BuildContext context) {
    const color = Colors.yellow;
    final Vector2 size = gameSize; // MediaQuery.of(context).size.height;
    return Container(
        alignment: Alignment(x, y),
        child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                decoration: const BoxDecoration(shape: shape, color: color),
                width: size[0],
                height: size[1],
              ),
              Container(
                decoration: const BoxDecoration(shape: shape, color: Colors.black),
                width: 0.2 * size[0],
                height: 0.2 * size[1],
              ),
            ])
    );
  }


  @override
  void onCollision(List<Collision> collisions) {
  }

  @override
  void onScreenSizeChange(Vector2 size) {
  }

  @override
  void update(Duration delta) {
  }
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