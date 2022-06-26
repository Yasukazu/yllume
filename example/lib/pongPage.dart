import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';
import 'WallBase.dart';
import 'Wall.dart';
import 'Paddle.dart';
import 'dart:math';
import 'dart:collection';

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
  late final BallChaser ballChaser;
  late final BallO ball;
  late final WallO topWall;
  late final WallO bottomWall;
  late final WallO leftWall;
  late final WallO rightWall;
  late final EnemyPaddleO enemyPaddle;
  late final PaddleO selfPaddle;
  List<WallO> get walls => [topWall, bottomWall, leftWall, rightWall];
  IllumeController get gameController => PongGamePage.gameController;
  bool gameStarted = false;
  final ballAngleIterator =
      RandAngleIterator(30, 14, true); // 30 to 44 degree, reverse
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
    ballChaser = BallChaser();
    topWall = PlayerWallO(wallPos.top, pause);
    bottomWall = PlayerWallO(wallPos.bottom, pause);
    rightWall = WallO(wallPos.right);
    leftWall = WallO(wallPos.left);
    enemyPaddle = EnemyPaddleO(ballChaser, wallPos.top,
        PongGamePage.paddleWidth, PongGamePage.paddleStep);
    selfPaddle = PaddleO(
        wallPos.bottom, PongGamePage.paddleWidth, PongGamePage.paddleStep);
    ball = BallO.withAngleProvider(
        selfPaddle, ballChaser.yieldBallPos, pause, ballAngleIterator, speed);
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
    enemyPaddle.center();
    selfPaddle.center();
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
      // TODO: clear/flush buffer
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

  /// returns 0 if not available.
  double calcLandingPos(
      List<DeltaPosition> ballDPs, Duration delta, Vector2 gameSize, double x) {
    assert(ballDPs.length >= 2);

    /// vector dXY
    final double dY = ballDPs[1].position[1] - ballDPs[0].position[1];
    final double dX = ballDPs[1].position[0] - ballDPs[0].position[0];
    final double dXY = sqrt(dX * dX + dY * dY);

    /// time dT
    final int dT = (ballDPs[1].delta - ballDPs[0].delta).inMilliseconds;

    /// speed vXY
    final double speed = dXY / dT;

    /// current position = dXY + d2XY
    // final d2XY = speed * (delta - ballDPs[1].delta).inMilliseconds;
    // final Vector2 curPos = (dXY + d2XY) / dXY * ballDPs[0];
    /* if (ballDPs.length < 2) {
      ballDPs = peekBallPos();
    }
    if (ballDPs.length < 2) {
      return 0;
    } */
    final ballDy = ballDPs[1].position[1] - ballDPs[0].position[1];
    if (ballDy >= 0) {
      return 0;
    }
    // TODO: set proper dx
    final lastBallX = ballDPs[1].position[0];
    final ballDx = ballDPs[1].position[0] - ballDPs[0].position[0];
    // final ballDt = ballDPs[1].delta - ballDPs[0].delta;
    // final ballXspeed = ballDx / ballDt.inMilliseconds;
    // final past = delta - ballDPs[1].delta;
    final landingDy = gameSize[1] - ballDPs[1].position[1];
    final landingCycle = landingDy / ballDy;
    // final landingTime = ballDt * landingCycle - past;
    final landingDx = lastBallX + ballDx * landingCycle;
    var cdx = 0.0;
    if (landingDx.abs() > gameSize[1]) {
      final fold = landingDx.abs() - gameSize[1];
      cdx = landingDx + ((landingDx >= 0) ? -fold : fold) - x;
    } else {
      cdx = landingDx - x;
    }

    return 0.0;
  }
}

class BallChaser {
  static const sampleCount = 2;
  final dPQueue = Queue<DeltaPosition>();
  // List<DeltaPosition> ballDPs;
  // Duration delta;
  // Vector2 gameSize;
  // BallChaser(this.ballDPs, this.delta, this.gameSize);

  void yieldBallPos(DeltaPosition deltaPosition) {
    if (dPQueue.isNotEmpty) {
      assert(dPQueue.last != deltaPosition);
    }
    dPQueue.add(deltaPosition);
    if (dPQueue.length > sampleCount) {
      dPQueue.removeFirst();
    }
  }

  Vector2 getBallCurPos(Duration delta, List<DeltaPosition> ballDPs) {
    assert(ballDPs.length >= 2);

    /// vectors
    final double dY = ballDPs[1].position[1] - ballDPs[0].position[1];
    final double dX = ballDPs[1].position[0] - ballDPs[0].position[0];

    /// time dT
    final int dT = ballDPs[1].delta.inMilliseconds - ballDPs[0].delta.inMilliseconds;

    /// speeds
    final double xSpeed = dX / dT;
    final double ySpeed = dY / dT;

    /// current scalars
    final dT2 = delta.inMilliseconds - ballDPs[1].delta.inMilliseconds;
    final d2X = xSpeed * dT2;
    final d2Y = ySpeed * dT2;

    final x1 = ballDPs[1].position[0];
    final y1 = ballDPs[1].position[1];

    return Vector2(x1 + d2X, y1 + d2Y);
  }

  /// returns [] if not enough data
  List<DeltaPosition> getBallPoss() {
    if (dPQueue.length >= sampleCount) {
      return dPQueue.take(sampleCount).toList();
    } else {
      return [];
    }
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
