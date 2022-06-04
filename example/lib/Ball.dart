import 'package:flutter/material.dart';
import 'dart:math';
import 'MyHomePage.dart'; // WallO
import 'orgMain.dart'; // logger
import 'package:illume/illume.dart';
import 'package:intl/intl.dart';
import 'WallBase.dart';
import 'Wall.dart';
import 'Paddle.dart';
import 'Backwardable.dart';

class BallO extends GameObject with Backwardable {
  static const defaultBallSpeed = 1000; // ms / diagonal
  static const defaultBallFPS = 30;
  static const initialX = 0.5;
  static const initialY = 0.5;
  static final initialXY = Vector2(initialX, initialY);
  final int _speed; // millisecond per diagonal
  int get speed => _speed;
  late double _angle;
  double get angle => _angle;
  late double stepInterval;
  late double _stepX;
  late double _stepY;
  double get stepX => dxReverse ? -_stepX : _stepX;
  double get stepY => dyReverse ? -_stepY : _stepY;
  Vector2 get stepVector => Vector2(stepX, stepY);
  late double _dx;
  late double _dy;

  bool _dxReverse = false;
  bool _dyReverse = false;
  bool get dxReverse => _dxReverse;
  bool get dyReverse => _dyReverse;
  double get dx => dxReverse ? -_dx : _dx;
  double get dy => dyReverse ? -_dy : _dy;
  double get orgAngle => atan2(_dx, _dy);
  static const coreAlignments = [
    Alignment.topCenter,
    Alignment.centerRight,
    Alignment.bottomCenter,
    Alignment.centerLeft,
  ];
  static const Color color = Color.fromRGBO(255, 255, 255, 1);
  final double ratio; // self size
  static const BoxShape shape = BoxShape.circle;
  // final Vector2 ballPos;

  int _stepCount = 0;
  int get stepCount => _stepCount;

  late double iSize;
  static const iRatio = 0.5;

  final void Function(wallPos) pause;
  BallO(this.pause, this._dx, this._dy,
      [this._speed = defaultBallSpeed, this.ratio = MyHomePage.ballSize]) {
    assert(_dx > 0 && _dy > 0);
    assert(_speed > 0);
    assert(ratio > 0);
    _angle = atan2(_dx, _dy);
  }

  /// _angle to Y-axis
  // final void Function(Vector2) getBallPos;

  late final RandAngleIterator? angleProvider;
  BallO.withAngleProvider(this.pause, this.angleProvider,
      [this._speed = defaultBallSpeed, this.ratio = MyHomePage.ballSize]) {
    _angle = angleProvider!.current;
    _dy = cos(_angle);
    _dx = sin(_angle);
  }

  double? getNextAngle() {
    if (angleProvider != null) {
      angleProvider!.moveNext();
      return angleProvider!.current;
    }
    return null;
  }

  void reset() {
    if (angleProvider != null) {
      angleProvider!.moveNext();
      _angle = angleProvider!.current;
      _dy = cos(_angle);
      _dx = sin(_angle);
    }
    _dxReverse = false;
    _dyReverse = false;
    init();
  }

  @override
  void init() {
    final gx = gameSize[0];
    final gy = gameSize[1];
    final diagonal = sqrt(gx * gx + gy * gy);
    final stepLength = diagonal / defaultBallFPS * speed / 1000;
    stepInterval = diagonal / stepLength;
    _stepX = stepLength * dx;
    _stepY = stepLength * dy;
    logger.finer("stepInterval = $stepInterval");
    // final virtualLandingPoint = y * dx / dy;
    final x_ = ratio * gameSize[0];
    final y_ = ratio * gameSize[1];
    final oSize = sqrt(x_ * x_ + y_ * y_);
    iSize = oSize * iRatio;
    logger.finer("oSize = $oSize");
    size = Vector2.all(oSize);
    alignment = GameObjectAlignment.center;
    position = Vector2(gx / 2, gy / 2);
    initialised = true;
  }

  @override
  Widget build(BuildContext context) {
    return // Container( // alignment: Alignment(x, y), child:
        Stack(children: [
      Align(
        alignment: Alignment.center,
        child: Container(
          decoration: const BoxDecoration(shape: shape, color: color),
        ),
      ),
      Align(
        alignment: Alignment.center, // coreAlignments[corePos % 4],
        child: Container(
          decoration: const BoxDecoration(shape: shape, color: Colors.black),
          width: iSize,
          height: iSize,
        ),
      ),
    ]);
  }

  @override
  void onCollision(List<Collision> collisions) {
    logger.info("Ball colided with ${collisions.length} collisions.");
    for (Collision col in collisions) {
      if (col.component is PaddleO) {
        final paddle = col.component as PaddleO;
        if (!bounceAtPaddle(paddle.pos, col.intersectionRect)) {
          logger.info("Paddle hit fail. Pausing..");
          pause(paddle.pos);
        }
      }
    }
  }

  @override
  void onScreenSizeChange(Vector2 size) {
    // This is a quick demo but you really should shift your positions in a
    // real world app or at least lock orientation.
  }

  final stepRatio = 0.015;
  bool update1st = true;
  int _lastUpdate = 0;
  @override
  void update(Duration delta) {
    if (delta.inMilliseconds - _lastUpdate > stepInterval) {
      _lastUpdate = delta.inMilliseconds;
      stepForward();
      // getBallPos(position);
    }
    /* if (delta.inMilliseconds % 200 == 0) {
      ++corePos;
      logger.fine("corePos:$corePos");
    } */
  }

  void _step() {
    final x = position[0];
    final y = position[1];
    final np = Vector2(x + stepX, y + stepY);

    position = np;
  }

  void stepForward() {
    lastPosForBackward = position;
    ++_stepCount;
    _step();
  }

  void stepBackward() {
    if (lastPosForBackward != null) {
      position = lastPosForBackward as Vector2;
    }
  }

  // void clearStepCount() { _stepCount = 0; }

  // void updateLastPosWithPosition() { lastPos = position; }

  void reverseDx() => _dxReverse = !_dxReverse;
  void reverseDy() => _dyReverse = !_dyReverse;

  void bounceAtWall(wallPos pos) {
    // wallPos wp) {
    // clearStepCount();
    // updateLastPosWithPosition();
    stepBackward();
    switch (pos) {
      case wallPos.right:
      case wallPos.left:
        reverseDx();
        logger.finer("Ball dx is reversed.");
        return;
      case wallPos.top:
      case wallPos.bottom:
        logger.finer("Ball dy is reversed.");
        reverseDy();
        return;
    }
  }

  bool bounceAtPaddle(wallPos pos, Rect rect) {
    // wallPos wp) {
    // clearStepCount();
    // updateLastPosWithPosition();
    stepBackward();
    final rx = position[0];
    if (rx >= rect.left && rx <= rect.right) {
      logger.finer("Paddle top/bottom hit Ball.");
      reverseDy();
      return true;
    }
    logger.fine("Paddle side hit Ball.");
    // reverseDx();
    return false;
  }
}

class RandAngleIterator extends Iterable with Iterator {
  final int range;
  final rand = Random(DateTime.now().millisecondsSinceEpoch);
  var _e = 0;
  var _s = false;
  int get v => (30 + _e) * (_s ? 1 : -1);

  RandAngleIterator(this.range) {
    _e = rand.nextInt(range);
    _s = rand.nextBool();
  }

  @override
  double get current => v / 180 * pi;

  @override
  bool moveNext() {
    _e = rand.nextInt(range);
    _s = rand.nextBool();
    return true;
  }

  @override
  Iterator get iterator => this;
}
