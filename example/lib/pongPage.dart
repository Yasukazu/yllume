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

class PongGamePage extends StatefulWidget {
  static const ballFPS = 30;
  static const ballSize = 0.06;
  static const wpGap = 0.01; // wall and paddle
  static const wallT = ballSize / 2 - wpGap - 0.001; // wall thickness1 per 1
  static const paddleStep = 0.1;
  static const paddleWidth = 0.25;
  static const paddleT = 0.06;
  const PongGamePage({Key? key}) : super(key: key);
  static const mainText = 'Pong game';
  static String statusBar = '$mainText';
  static String wallMsg = '';
  static IllumeController gameController = IllumeController();

  @override
  _PongGamePageState createState() => _PongGamePageState();
}

/// Pong game
class _PongGamePageState extends State<PongGamePage> {
  // FlappyWidget flappyWidget = FlappyWidget();
  // Wall wall = Wall(200, false);
  // Wall wall2 = Wall(400, true);
  static const speed = 500;

  late final BallO ball;
  late final WallO topWall;
  late final WallO bottomWall;
  late final WallO leftWall;
  late final WallO rightWall;
  late final PaddleO enemyPaddle;
  late final PaddleO selfPaddle;
  List<WallO> get walls => [topWall, bottomWall, leftWall, rightWall];
  IllumeController get gameController => PongGamePage.gameController;
  bool gameStarted = false;
  final ballPos = Vector2(0, 0);
  final ballAngleIterator = RandAngleIterator(14);
  int enemyScore = 0;
  int playerScore = 0;

  void scoreEnemy() {
    setState(() {
      enemyScore += 1;
    });
    logger.info("Enemy gained 1 score.");
  }

  void scorePlayer() {
    setState(() {
      playerScore += 1;
    });
    logger.info("Player gained 1 score.");
  }

  _PongGamePageState() {
    ball = BallO.withAngleProvider(pause, ballAngleIterator, speed);
    topWall = PlayerWallO(wallPos.top, pause);
    bottomWall = PlayerWallO(wallPos.bottom, pause);
    rightWall = WallO(wallPos.right);
    leftWall = WallO(wallPos.left);
    enemyPaddle = EnemyPaddleO(wallPos.top, PongGamePage.paddleWidth,
        PongGamePage.paddleStep, peekBallPos);
    selfPaddle = PaddleO(
        wallPos.bottom, PongGamePage.paddleWidth, PongGamePage.paddleStep);
  }

  @override
  void initState() {
    super.initState();
    // gameController.startGame();
    PongGamePage.statusBar = PongGamePage.mainText + ": Tap to start:";
    gameController.gameObjects.addAll([
      topWall,
      bottomWall,
      leftWall,
      rightWall,
      enemyPaddle,
      selfPaddle,
      ball
    ]);
  }

  void resume() {
    if (!gamePaused) {
      return;
    }
    // gameController.gameObjects.removeLast();
    // ballAngleIterator.moveNext();
    ball.reset();
    // gameController.gameObjects.add(ball as BallO);
    gameController.resume();
    gamePaused = false;
  }

  bool gamePaused = false;

  void pause(wallPos pos) {
    gameController.pause();
    gamePaused = true;
    setState(() {
      PongGamePage.statusBar = PongGamePage.mainText + ": Tap to restart:";
    });
    if (pos == wallPos.top) {
      scorePlayer();
      logger.info("Player +1 score.");
    } else if (pos == wallPos.bottom) {
      scoreEnemy();
      logger.info("Enemy +1 score.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          selfPaddle.moveLeft();
          logger.info("arrowLeft key");
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          selfPaddle.moveRight();
          logger.info("arrowRight key");
        }
      },
      child: GestureDetector(
        onTap: () {
          if (!gameStarted) {
            gameController.startGame();
            gameStarted = true;
          } else if (gamePaused) {
            resume();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(PongGamePage.statusBar),
          ),
          body: Stack(
            children: [
              gradient,
              Score(enemyScore, playerScore),
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

  void getBallPos(Vector2 ballPos) {}

  DeltaPosition peekBallPos() {
    return ball.pickupDeltaPositions.putOut();
  }
}

class Score extends StatelessWidget {
  final int enemyScore;
  final int playerScore;

  const Score(this.enemyScore, this.playerScore, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const opacity = 1.0;
    return Stack(children: [
      Container(
          alignment: const Alignment(0, 0),
          child: Container(
            height: 1,
            width: MediaQuery.of(context).size.width / 3,
            color: Colors.grey.withOpacity(opacity),
          )),
      Container(
          alignment: const Alignment(0, -0.3),
          child: Text(
            enemyScore.toString(),
            style: TextStyle(
                color: Colors.grey.withOpacity(opacity), fontSize: 100),
          )),
      Container(
          alignment: const Alignment(0, 0.3),
          child: Text(
            playerScore.toString(),
            style: TextStyle(
                color: Colors.grey.withOpacity(opacity), fontSize: 100),
          )),
    ]);
  }
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
