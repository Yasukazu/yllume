import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';
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
  const MyHomePage({Key? key}) : super(key: key);
  static const mainText = 'Pong game';
  static String statusBar = '$mainText';
  static String wallMsg = '';
  static IllumeController gameController = IllumeController();
  static wallPos? collisionWallPos;

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
    topWall = HWallO(wallPos.top);
    bottomWall = HWallO(wallPos.bottom);
    rightWall = VWallO(wallPos.right);
    leftWall = VWallO(wallPos.left);
    enemyPaddle = PaddleO(wallPos.top);
    selfPaddle = PaddleO(wallPos.bottom);
  }

  @override
  void initState() {
    super.initState();
    // gameController.startGame();
    MyHomePage.statusBar = MyHomePage.mainText + ":started";
    gameController.gameObjects
        .addAll([topWall, bottomWall, leftWall, rightWall, ball, enemyPaddle, selfPaddle]);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          logger.info("arrowLeft key");
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          logger.info("arrowRight key");
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
