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
  static const defaultBallSpeed = 1;
  static const initialX = 0.5;
  static const initialY = 0.5;
  final int _speed; // millisecond
  int get speed => _speed;
  late final double _dx;
  bool dxReverse = false;
  bool dyReverse = false;
  double get dx => dxReverse ? -_dx : _dx;
  double get dy => dyReverse ? -_dy : _dy;
  double get orgAngle => atan2(_dx, _dy);
  static const coreAlignments = [
    Alignment.topCenter,
    Alignment.centerRight,
    Alignment.bottomCenter,
    Alignment.centerLeft,
  ];
  int corePos = 0;
  double get x => curXY[0];
  double get y => curXY[1];
  late final double _dy;
  static const Color color = Color.fromRGBO(255, 255, 255, 1);
  final double ratio; // self size
  static const BoxShape shape = BoxShape.circle;
  Vector2 get lastPos =>
      Vector2(gameSize[0] * lastXY[0], gameSize[1] * lastXY[1]);
  set lastPos(Vector2 nxy) {
    final x_ = nxy[0] / gameSize[0];
    final y_ = nxy[1] / gameSize[1];
    lastXY = Vector2(x_, y_);
  }

  final _lastXY = Vector2(initialX, initialY);
  Vector2 get lastXY => _lastXY;
  set lastXY(Vector2 nxy) {
    final x_ = nxy[0];
    final y_ = nxy[1];
    assert(x_ >= 0 && x_ <= 1.0);
    assert(y_ >= 0 && y_ <= 1.0);
    _lastXY[0] = x_;
    _lastXY[1] = y_;
  }

  int _stepCount = 0;
  int get stepCount => _stepCount;
  Vector2 get curXY {
    final x_ = lastXY[0];
    final y_ = lastXY[1];
    final ndx = stepCount * dx;
    final ndy = stepCount * dy;
    return Vector2(x_ + ndx, y_ + ndy);
  }

  Vector2 get curPos {
    final x_ = curXY[0];
    final y_ = curXY[1];
    return Vector2(x_ * gameSize[0], y_ * gameSize[1]);
  }

  // late final BallPos ballPos;
  /// args: x, y, ratio, color, shape,
  BallO(this._dx, this._dy,
      [this._speed = defaultBallSpeed, this.ratio = MyHomePage.ballSize]) {
    assert(_dx > 0 && _dy > 0);
    assert(_speed > 0);
    assert(ratio > 0);
  }

  /// angle to Y-axis
  BallO.withAngle(this._speed, double rad, [this.ratio = MyHomePage.ballSize]) {
    _dx = cos(rad);
    _dy = sin(rad);
  }

  @override
  void init() {
    size = Vector2.all(ratio * gameSize[0]);
    alignment = GameObjectAlignment.center;
    position = curPos;
  }

  @override
  Widget build(BuildContext context) {
    final size = gameSize; // MediaQuery.of(context).size.height;
    assert(ratio > 0);
    // assert(x >= 0 && x <= 1.0);
    // assert(y >= 0 && y <= 1.0);
    return Container(
        alignment: Alignment(x, y),
        child: Stack(children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: const BoxDecoration(shape: shape, color: color),
              width: ratio * size[0],
              height: ratio * size[0],
            ),
          ),
          Align(
            alignment: Alignment.center, // coreAlignments[corePos % 4],
            child: Container(
              decoration:
                  const BoxDecoration(shape: shape, color: Colors.black),
              width: ratio * size[0] * 0.5,
              height: ratio * size[0] * 0.5,
            ),
          ),
        ]));
  }

  // bool on1stCollision = true;
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
  @override
  void update(Duration delta) {
    forward();
    if (delta.inMilliseconds % 200 == 0) {
      ++corePos;
      logger.fine("corePos:$corePos");
    }
  }

  void _step() {
    final nx = stepCount * dx * stepRatio;
    final rnx = lastPos[0] + (nx * gameSize[0]).round();
    final ny = stepCount * dy * stepRatio;
    final rny = lastPos[1] + (ny * gameSize[1]).round();
    final np = Vector2(rnx, rny);
    final fmt = NumberFormat('##.0#', 'en_US');
    final ifmt = NumberFormat('###', 'en_US');
    logger.finest(
        "lastPos:${ifmt.format(lastPos[0])},${ifmt.format(lastPos[0])}");
    logger.finest("stepCount:$stepCount, dx: $dx, dy: $dy, stepRatio: $stepRatio" +
        "position:${fmt.format(position[0])}, ${fmt.format(position[1])}. np:${ifmt.format(np[0])},${ifmt.format(np[1])}.");
    position = np;
  }

  void forward() {
    lastPosForBackward = position;
    ++_stepCount;
    logger.finer(
        "position=${position[0]},${position[1]}. stepCount=$_stepCount;Calling step().");
    _step();
  }

  /* void backward() {
    --_stepCount;
    _step();
  } */

  void clearStepCount() {
    _stepCount = 0;
  }

  void updateLastPosWithPosition() {
    lastPos = position;
  }

  void reverseDx() => dxReverse = !dxReverse;
  void reverseDy() => dyReverse = !dyReverse;

  void bounceAtWall(wallPos pos) {
    // wallPos wp) {
    clearStepCount();
    updateLastPosWithPosition();
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
    clearStepCount();
    updateLastPosWithPosition();
    final rx = x * gameSize[0];
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
  final rand = new Random(new DateTime.now().millisecondsSinceEpoch);
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
