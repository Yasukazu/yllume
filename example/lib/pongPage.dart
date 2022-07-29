import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';
import 'WallBase.dart';
import 'Wall.dart';
import 'Paddle.dart';
import 'ballchaser.dart';
import 'motionline.dart';

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
  final List<MotionLine> motionLines = [];
  // late final MotionLine motionLine;
  List<WallO> get walls => [topWall, bottomWall, leftWall, rightWall];
  IllumeController get gameController => PongGamePage.gameController;
  bool gameStarted = false;
  final ballAngleIterator =
      RandAngleIterator(30, 14, reverse: false); // 30 to 44 degree, reverse
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

  late WallO Function(wallPos) posToWall;

  _PongGamePageState() {
    topWall = PlayerWallO(wallPos.top, pause);
    bottomWall = PlayerWallO(wallPos.bottom, pause);
    rightWall = WallO(wallPos.right);
    leftWall = WallO(wallPos.left);
    // final pos2wall = {wallPos.top: topWall, wallPos.bottom: bottomWall, wallPos.right: rightWall, wallPos.left: leftWall};
    posToWall = (wp) {
      switch(wp) {
        case wallPos.top:
          return topWall;
        case wallPos.bottom:
          return bottomWall;
        case wallPos.left:
          return leftWall;
        case wallPos.right:
          return rightWall;
      }
    };
    selfPaddle = PaddleO(posToWall, wallPos.bottom, PongGamePage.paddleWidth,
        PongGamePage.paddleStep);
    ballChaser = BallChaser(posToWall, PongGamePage.ballSize, forwardTime: 1300);
    enemyPaddle = EnemyPaddleO(ballChaser, posToWall, wallPos.top,
        PongGamePage.paddleWidth, PongGamePage.paddleStep);
    // motionLine = MotionLine();
    ball = BallO.withAngleProvider(motionLines,
        selfPaddle, ballChaser, pause, ballAngleIterator, speed, PongGamePage.ballSize);
    for (int i = 0; i < motionCount; ++i) {
      motionLines.add(MotionLine(i, ball.size));
    }
  }

  static const motionCount = 3;

  void addWithDuration(GameObject object) {
    gameController.gameObjects.add(object);
    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      object.visible = false;
      gameController.gameObjects.remove(object);
    });
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
    ]);
    for (var motionLine in motionLines) {
      gameController.gameObjects.add(motionLine);
    }
    gameController.gameObjects.addAll([
      ball,
      ballChaser
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

  _doOnTapDown(TapDownDetails details) {
    Offset position = details.localPosition;
    logger.fine("Relative tapped pos.dx: ${position.dx}, pos.dy: ${position.dy}");
    if (gameController.gameInProgress && gameController.gameObjects.isNotEmpty) {
      final GameObject gameObject = selfPaddle; // gameController.gameObjects.firstWhere((element) =>
        // element == selfPaddle // is PaddleO && element is! EnemyPaddleO );
      if (position.dx < gameObject.position[0]) { // gameSize[0] / 2) {
        selfPaddle.moveLeft();
        logger.finer("selfPaddle moveLeft by tap left area.");
      }
      else {
        selfPaddle.moveRight();
        logger.finer("selfPaddle moveRight by tap right area.");
      }
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
          logger.finer("selfPaddle moveLeft by arrowLeft key");
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          selfPaddle.moveRight();
          logger.finer("selfPaddle moveRight by arrowRight key");
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
        onTapDown: (TapDownDetails details) {
          if (gameStarted && !gamePaused) {
            _doOnTapDown(details);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(PongGamePage.statusBar),
          ),
          body: Center(
              child: Row( // Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 100,  child:
                    // SpeedSlider(pauseBySlider, ball.changeSlider, resumeBySlider)
                    RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                      label: 'Ball Speed',
                      min: 0,
                      max: 1,
                      value: ball.getSliderValue(),
                      // divisions: 10,
                      onChanged: (givenValue) {
                        setState(() {
                          ball.changeSliderValue(givenValue);
                        });
                      },
                      onChangeStart: pauseBySlider,
                      onChangeEnd: resumeBySlider,
                    )
                    )
                    ),
                    Expanded(child:  Stack( children: [
                        background,
                        Score(enemyScore, playerScore),
                        Illume( illumeController: gameController),
                      ] ) )
          ] ) ),
        )
      )
    );
  }

  void pauseBySlider(double slider) {
    gameController.pause();
    gamePaused = true;
    setState(() {
      PongGamePage.statusBar = PongGamePage.mainText + ": pause by slider.";
    });
    logger.fine("pause by slider.");
  }

  void resumeBySlider(double slider) {
    resume();
    logger.fine("resume by slider.");
  }

  var background = Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
          colors: [Colors.teal, Colors.deepPurple],
          stops: [0.0, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
    ),
  );

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
