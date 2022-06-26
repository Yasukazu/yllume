import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:collection';
import 'orgMain.dart'; // logger
import 'package:illume/illume.dart';
import 'WallBase.dart';
import 'Paddle.dart';
import 'pongPage.dart';
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
  static const gap = 3;
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

  int _stepCount = 0;
  int get stepCount => _stepCount;

  /// core size
  late double iSize;
  static const iRatio = 0.5;
  late final PaddleO selfPaddle;
  final void Function(wallPos) pause;
  BallO(this.selfPaddle, this.yieldBallPos, this.pause, this._dx, this._dy,
      [this._speed = defaultBallSpeed, this.ratio = PongGamePage.ballSize]) {
    assert(_dx > 0 && _dy > 0);
    assert(_speed > 0);
    assert(ratio > 0);
    _angle = atan2(_dx, _dy);
  }

  /// _angle to Y-axis
  final void Function(DeltaPosition) yieldBallPos;

  late final RandAngleIterator? angleProvider;
  BallO.withAngleProvider(this.selfPaddle, this.yieldBallPos, this.pause, this.angleProvider,
      [this._speed = defaultBallSpeed, this.ratio = PongGamePage.ballSize]) {
    assert(angleProvider != null);
    _angle = angleProvider!.current;
    _dy = cos(_angle);
    _dx = sin(_angle);
  }

  double? getNextAngle() {
    if (angleProvider != null) {
      angleProvider!.moveNext();
      return angleProvider!.current;
    } else {
      return null;
    }
  }

  void reset() {
    final ang = getNextAngle();
    if (ang != null) {
      _angle = ang;
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
    final oSize = sqrt(x_ * x_ + y_ * y_); // outer size
    iSize = oSize * iRatio;
    logger.finer("Ball outer size = $oSize");
    size = Vector2.all(oSize);
    alignment = GameObjectAlignment.center;
    // final double offset = WallBaseO.bottomOffset(gameSize)[1];
    final double selfPaddleYPos = selfPaddle.position[1];
    final double selfPaddleHSize = selfPaddle.size[1];
    final double selfPaddleTopSurface = selfPaddleYPos - selfPaddleHSize / 2;
    position = Vector2(gx / 2, selfPaddleTopSurface - oSize / 2 - gap); // , gy / 2);
    initialised = true;
    // _pickupDeltaPositionQueue.clear();
    _stepCount = 0;
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
    logger.info("Ball collided with ${collisions.length} collisions.");
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

  static const pickupDelay = 3; // final Vector2 ballPos;;
  final _pickupDeltaPositionQueue = Queue<DeltaPosition>();
  static const pickupCycle = 4;
  int _lastUpdate = 0;
  @override
  void update(Duration delta) {
    if (delta.inMilliseconds - _lastUpdate > stepInterval) {
      _lastUpdate = delta.inMilliseconds;
      position = stepForward();
      logger.finest("Update ball pos: (${position[0]}, ${position[1]}).");
      if (_stepCount % pickupCycle == 0) {
        // delta != Duration.zero && position != Vector2.zero() &&
        _pickupDeltaPositionQueue.add(DeltaPosition(delta, position));
        if (_pickupDeltaPositionQueue.length > pickupDelay) {
          yieldBallPos(_pickupDeltaPositionQueue.removeFirst());
        }
      }
      ++_stepCount;
    }
  }

  Vector2 _step() {
    final x = position[0];
    final y = position[1];
    final np = Vector2(x + stepX, y + stepY);
    return np;
    // position[0] += stepX;
    // position[1] += stepY;
  }

  Vector2 stepForward() {
    lastPosForBackward = position;
    return _step();
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
      // _pickupDeltaPositionQueue.clear();
      return true;
    }
    logger.fine("Paddle side hit Ball.");
    // reverseDx();
    return false;
  }
}

class RandAngleIterator extends Iterable with Iterator {
  final int start;
  final int range;
  final bool reverse;
  final rand = Random(DateTime.now().millisecondsSinceEpoch);
  var _e = 0;
  // var _s = false;
  int get v => reverse ? -(start + _e) : (start + _e); //  * (_s ? 1 : -1);

  RandAngleIterator(this.start, this.range, this.reverse) {
    _e = rand.nextInt(range);
    // _s = rand.nextBool();
  }

  @override
  double get current => v / 180 * pi;

  @override
  bool moveNext() {
    _e = rand.nextInt(range);
    // _s = rand.nextBool();
    return true;
  }

  @override
  Iterator get iterator => this;
}

class DeltaPosition {
  Duration delta;
  Vector2 position;
  DeltaPosition(this.delta, this.position);
  static zero() => DeltaPosition(Duration.zero, Vector2.zero());
}

class DelayBuffer {
  final _queue = Queue<DeltaPosition>();
  final int size;
  DelayBuffer(this.size);

  DeltaPosition putOut() {
    if (_queue.length >= size) {
      return _queue.removeFirst();
    } else {
      return DeltaPosition.zero();
    }
  }

  void putIn(DeltaPosition dp) {
    _queue.add(dp);
    if (_queue.length > size) {
      _queue.removeFirst();
    }
  }
}
