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
  late final double _angle;
  double get angle => _angle;
  late final double stepInterval;
  late final double _stepX;
  late final double _stepY;
  double get stepX => dxReverse ? -_stepX : _stepX;
  double get stepY => dyReverse ? -_stepY : _stepY;
  Vector2 get stepVector => Vector2(stepX, stepY);
  late final double _dx;
  late final double _dy;
  /*
  late final double _x;
  late final double _y;
  double get x => _x;
  double get y => _y;
  */
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
  // int corePos = 0;
  static const Color color = Color.fromRGBO(255, 255, 255, 1);
  final double ratio; // self size
  static const BoxShape shape = BoxShape.circle;
  /* Vector2 get lastPos => Vector2(x, y);
  set lastPos(Vector2 nxy) {
    assert(nxy[0] >= 0 && nxy[0] <= gameSize[0]);
    assert(nxy[1] >= 0 && nxy[1] <= gameSize[1]);
    _x = nxy[0];
    _y = nxy[1];
  } */

  // final _lastPos = Vector2(0, 0);
  // final _lastXY = Vector2(initialX, initialY);
  // Vector2 get lastXY => _lastXY;
  /*
  set lastXY(Vector2 nxy) {
    final x_ = nxy[0];
    final y_ = nxy[1];
    assert(x_ >= 0 && x_ <= 1.0);
    assert(y_ >= 0 && y_ <= 1.0);
    _lastXY[0] = x_;
    _lastXY[1] = y_;
  } */

  int _stepCount = 0;
  int get stepCount => _stepCount;
  /*
  Vector2 get curXY {
    final x_ = lastXY[0];
    final y_ = lastXY[1];
    final ndx = stepCount * dx;
    final ndy = stepCount * dy;
    return Vector2(x_ + ndx, y_ + ndy);
  } */

  /* Vector2 get curPos {
    return lastPos + _offsets;
  } */

  // final _offsets = Vector2(0, 0);
  late double iSize;
  static const iRatio = 0.5;

  BallO(this._dx, this._dy,
      [this._speed = defaultBallSpeed, this.ratio = MyHomePage.ballSize]) {
    assert(_dx > 0 && _dy > 0);
    assert(_speed > 0);
    assert(ratio > 0);
    _angle = atan2(_dx, _dy);
  }

  /// _angle to Y-axis
  BallO.withAngle(double angl,
      [this._speed = defaultBallSpeed, this.ratio = MyHomePage.ballSize]) {
    _angle = angl;
    _dy = cos(angl);
    _dx = sin(angl);
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
        bounceAtPaddle(paddle.pos, col.intersectionRect);
      } else if (col.component is WallO) {
        final wall = col.component as WallO;
        if (wall.pos == wallPos.left || wall.pos == wallPos.right) {
          bounceAtWall(wall.pos);
        } else {
          logger.info("Ball hit top/bottom wall!");
          MyHomePage.gameController.pause();
          // throw GameEndException("Ball hit top/bottom wall!");
        }
      }
      // WallO colWall = col.component as WallO;
      // final p = colWall.pos;
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
    }
    /* if (delta.inMilliseconds % 200 == 0) {
      ++corePos;
      logger.fine("corePos:$corePos");
    } */
  }

  void _step() {
    /*
    final nx = stepCount * dx * stepRatio;
    final rnx = lastPos[0] + (nx * gameSize[0]).round();
    final ny = stepCount * dy * stepRatio;
    final rny = lastPos[1] + (ny * gameSize[1]).round();
    */
    final x = position[0];
    final y = position[1];
    final np = Vector2(x + stepX, y + stepY);
    // final fmt = NumberFormat('##.0#', 'en_US');
    // final ifmt = NumberFormat('###', 'en_US');
    // logger.finest( "lastPos:${ifmt.format(lastPos[0])},${ifmt.format(lastPos[0])}");
    // logger.finest("stepCount:$stepCount, dx: $dx, dy: $dy, stepRatio: $stepRatio" + "position:${fmt.format(position[0])}, ${fmt.format(position[1])}. np:${ifmt.format(np[0])},${ifmt.format(np[1])}.");
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

  void bounceAtPaddle(wallPos pos, Rect rect) {
    // wallPos wp) {
    // clearStepCount();
    // updateLastPosWithPosition();
    stepBackward();
    final rx = position[0];
    if (rx >= rect.left && rx <= rect.right) {
      logger.finer("Paddle top/bottom hit Ball.");
      reverseDy();
      return;
    }
    logger.finer("Paddle side hit Ball.");
    reverseDx();
    return;
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
