import 'package:flutter/material.dart';
// logger.fine('stepBackwardResult: $backwardResult. after position = [$position].');

import 'package:vector_math/vector_math.dart' hide Colors;
import 'dart:math';
import 'dart:collection';
import 'ballchaser.dart';
import 'main.dart'; // logger
import 'package:illume/illume.dart';
import 'WallBase.dart';
import 'Wall.dart';
import 'Paddle.dart';
import 'pongPage.dart';
import 'Backwardable.dart';
import 'motionline.dart';

class BallO extends GameObject with Backwardable {
  static const defaultBallSpeed = 1000; // ms / diagonal
  static const defaultBallFPS = 30;
  static const initialX = 0.5;
  static const initialY = 0.5;
  static final initialXY = Vector2(initialX, initialY);
  final int _speed; // millisecond per diagonal
  int get speed => (_speed * _speedRatio).round();
  double _angle = 0;
  double get angle => _angle;
  double _stepInterval = 0;
  double get stepInterval => _stepInterval;
  // double _stepX = 0;
  // double _stepY = 0;
  final Vector2 steps = Vector2(0, 0);
  double get stepX => steps.x; // _stepX; // dxReverse ? -_stepX : _stepX;
  double get stepY => steps.y; // _stepY; // dyReverse ? -_stepY : _stepY;
  // Vector2 get stepVector => Vector2(stepX, stepY);
  double _dx = 0;
  double _dy = 0;
  static const gap = 30;
  // bool _dxReverse = false;
  // bool _dyReverse = false;
  // bool get dxReverse => _dxReverse;
  // bool get dyReverse => _dyReverse;
  // double get dx => dxReverse ? -_dx : _dx;
  // double get dy => dyReverse ? -_dy : _dy;
  double get orgAngle => atan2(_dx, _dy);
  static const coreAlignments = [
    Alignment.topCenter,
    Alignment.centerRight,
    Alignment.bottomCenter,
    Alignment.centerLeft,
  ];
  Alignment coreAlignment = coreAlignments[0];
  static Alignment getCoreAlignment(int i) {
    return coreAlignments[i % coreAlignments.length];
  }

  static const Color color = Color.fromRGBO(255, 255, 255, 1);
  final double ratio; // self size
  static const BoxShape shape = BoxShape.circle;

  int _stepCount = 0;
  int get stepCount => _stepCount;

  /// core size
  double iSize = 0;
  static const iRatio = 0.5;
  int iPos = 0;
  bool _rotateCW = true;
  late final PaddleO selfPaddle;
  final void Function(GameObject) pause;
  final List<MotionLine> motionLines;
  static const defaultRotation = 0.3; // rad
  double _rotation = 0;
  double get rotation => _rotateCW ? _rotation : -_rotation;
  BallO(this.motionLines, this.selfPaddle, this.ballChaser, this.pause,
      this._dx, this._dy,
      [this._speed = defaultBallSpeed,
      this.ratio = PongGamePage.ballSize,
      this.pickupCycle = 2,
      this.pickupDelay = 2,
      this._rotation = defaultRotation]) {
    assert(_dx > 0 && _dy > 0);
    assert(_speed > 0);
    assert(ratio > 0);
    _angle = atan2(_dx, _dy);
  }
  Matrix2 _bounceRotator = Matrix2(1, -0, 0, 1);
  Matrix2 _stepRotator = Matrix2(1, -0, 0, 1);

  /// send null to clear dp queue
  void Function(DeltaPosition?) get yieldBallPos => ballChaser.putinBallPos;
  final BallChaser ballChaser;

  void setLastHitPaddle(PaddleO paddle) {
    if (paddle is EnemyPaddleO) {
      ballChaser.lastHitPaddleIsEnemy = true;
      logger.info("lastHitPaddle is enemy.");
    } else {
      ballChaser.lastHitPaddleIsEnemy = false;
      logger.info("lastHitPaddle is player.");
    }
  }

  late final RandAngleIterator? angleProvider;
  final RandSignIterator randSignIterator = RandSignIterator();
  BallO.withAngleProvider(this.motionLines, this.selfPaddle, this.ballChaser,
      this.pause, this.angleProvider, this._speed, this.ratio,
      [this.pickupCycle = 2,
      this.pickupDelay = 2,
      this._rotation = defaultRotation]) {
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
    randSignIterator.moveNext();
    _rotateCW = randSignIterator.current;
    final ang = getNextAngle();
    if (ang != null) {
      _angle = ang;
      _dy = cos(_angle);
      _dx = sin(_angle);
    }
    // _dxReverse = false;
    // _dyReverse = false;
    init();
  }

  static double calcSize(Vector2 gameSize, double ratio) {
    final x_ = ratio * gameSize[0];
    final y_ = ratio * gameSize[1];
    return sqrt(x_ * x_ + y_ * y_); // outer size
  }

  void _setSteps(Vector2 gameSize) {
    final gx = gameSize[0];
    final gy = gameSize[1];
    final diagonal = sqrt(gx * gx + gy * gy);
    final stepLength = diagonal / defaultBallFPS * speed / 1000;
    _stepInterval = diagonal / stepLength;
    steps.x = stepLength * _dx;
    steps.y = stepLength * _dy;
  }

  @override
  void init() {
    _setSteps(gameSize);
    logger.finer("stepInterva 33= $stepInterval");
    // final virtualLandingPoint = y * dx / dy;
    final oSize = calcSize(gameSize, ratio);
    iSize = oSize * iRatio;
    logger.finer("Ball outer size = $oSize");
    size = Vector2.all(oSize);
    alignment = GameObjectAlignment.center;
    // final double offset = WallBaseO.bottomOffset(gameSize)[1];
    final double selfPaddleYPos = selfPaddle.position.y;
    final double selfPaddleHSize = selfPaddle.size.y;
    final double selfPaddleTopSurface = selfPaddleYPos - selfPaddleHSize / 2;
    position.setValues(
        gameSize[0] / 2, selfPaddleTopSurface - oSize / 2 - gap); // , gy / 2);
    initialised = true;
    _stepCount = 0;
    rebuildWidgetIfNeeded = true;
    randSignIterator.moveNext();
    for (var motionLine in motionLines) {
      motionLine.size = size;
    }
    _bounceRotator =
        Matrix2(cos(rotation), -sin(rotation), sin(rotation), cos(rotation));
    _stepRotator = Matrix2(cos(rotation / 9), -sin(rotation / 9),
        sin(rotation / 9), cos(rotation / 9));
  }

  @override
  void onScreenSizeChange(Vector2 size) {
    _setSteps(size);
    logger.finer("stepInterval = $stepInterval");
    final oSize = calcSize(size, ratio);
    iSize = oSize * iRatio;
    logger.finer("Ball outer size = $oSize");
    this.size = Vector2.all(oSize);
    alignment = GameObjectAlignment.center;
    final double selfPaddleYPos = selfPaddle.position[1];
    final double selfPaddleHSize = selfPaddle.size[1];
    final double selfPaddleTopSurface = selfPaddleYPos - selfPaddleHSize / 2;
    position.setValues(
        size[0] / 2, selfPaddleTopSurface - oSize / 2 - gap); // , gy / 2);
    initialised = true;
    _stepCount = 0;
    randSignIterator.moveNext();
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
        alignment: coreAlignment,
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
      logger.finer("collision component is ${col.component}.");
      if (col.component is PaddleO) {
        final paddle = col.component as PaddleO;
        if (!bounceAtPaddle(paddle, col.intersectionRect)) {
          logger.fine("Paddle hit fail. Pausing..");
          pause(paddle);
        } else {
          resetYield();
        }
      } else if (col.component is WallO) {
        if (col.component is SideWallO) {
          final wall = col.component as SideWallO;
          bounceAtWall(wall, col.intersectionRect);
          logger.finer("bounce at wall.");
          resetYield();
        } else {
          final wall = col.component as WallO;
          logger.fine("ball hit top/bottom wall. pause..");
          pause(wall);
        }
      }
    }
  }

  void resetYield() {
    _yieldCount = 0;
    yieldBallPos(null);
    _pickupDeltaPositionQueue.clear();
    logger.finer("yieldBallPos(null) to clear DPQueue.");
  }

  final int pickupDelay; // final Vector2 ballPos;;
  final _pickupDeltaPositionQueue = Queue<DeltaPosition>();
  final int pickupCycle;
  int _lastUpdate = 0;
  int _yieldCount = 0;
  static const yieldMax = 6;

  DeltaPosition yieldPosition(Duration delta, Vector2 position) {
    return DeltaPosition(delta, position.x, position.y);
  }

  final motionCycleRatio = 2;
  int _motionCount = 0;
  int _motionCycle = 0;

  @override
  void update(Duration delta) {
    if (delta.inMilliseconds - _lastUpdate > stepInterval) {
      _lastUpdate = delta.inMilliseconds;

      steps.postmultiply(_stepRotator);
      final stepsAddedPosition = position + steps;
      if (stepsAddedPosition.x > 0 && stepsAddedPosition.y > 0 && stepsAddedPosition.x < gameSize.x && stepsAddedPosition.y < gameSize.y) {
        position.add(steps); // setFrom(stepForward());
      }
      else {
        logger.warning("steps added position not in screen range.");
        return;
      }

      iPos = iPos + (_rotateCW ? 1 : -1);
      coreAlignment = coreAlignments[iPos % coreAlignments.length];
      ++_stepCount;
      logger.finer("coreAlignment is set as $coreAlignment by $iPos.");
      rebuildWidget();
      logger.finer("rebuild ball.");
      logger.finest("Update ball pos: (${position[0]}, ${position[1]}).");

      if (_stepCount % pickupCycle == 0) {
        _pickupDeltaPositionQueue
            .add(DeltaPosition(delta, position.x, position.y));
        logger.finer("_pickupDeltaPositionQueue.add:($delta, $position)");
        if (_pickupDeltaPositionQueue.length >= pickupDelay) {
          //_yieldCount < yieldMax &&
          final deltaPosition = _pickupDeltaPositionQueue.removeFirst();
          yieldBallPos(deltaPosition);
          ++_yieldCount;
        }
      }
      if (_stepCount % (pickupCycle * motionCycleRatio) == 0 &&
          _pickupDeltaPositionQueue.isNotEmpty) {
        final lastElement = _pickupDeltaPositionQueue.elementAt(0);
        final motionNumber = _motionCount % motionLines.length;
        final motionLine = motionLines[motionNumber];
        motionLine.position.setValues(lastElement.x, lastElement.y);
        logger.fine("Motionline[$motionNumber] position is set to $position.");
        // motionLine.size = size;
        motionLine.turnOn();
        // motionLine.update(delta);
        _motionCount++;
      }
    }
  }

  void unstep(double k) => position.add(steps * -k);
  final unstepFactor = 0.5;

  bool bounceAtWall(WallO wall, Rect rect) {
    // Vector2 offsets) {
    if (wall is! SideWallO) {
      return false;
    }
    else {
      /*
      final xLap = rect.width; // + wall.gap(position.y);
      final yLap = rect.height;
      final dist = Vector2( steps.x < 0
              ? xLap + collisionGap : -xLap - collisionGap,
          steps.y < 0 ? yLap + collisionGap : -yLap - collisionGap); // (steps.y / steps.x).abs() * xLap + collisionGap);
      logger.info("going to add position($position): $dist");
      position.add(dist);
      */
      unstep(unstepFactor);
      final gap = wall.gap(position.y);
      final wallVector = Vector2(wall.pos == wallPos.right ? gap : -gap,
          steps.y > 0 ? position.y : -position.y);
      logger.info(
          "wall angle: ${atan2(wallVector.x, wallVector.y) * 180 / pi}[degree], steps angle = ${atan2(steps.x, steps.y) * 180}");
      final double rotation = (this.rotation +
          steps.angleToSigned(wallVector)) * 2; // ((wall.pos == wallPos.right) ? 2 : -2);
      logger.info("bounceToWall rotation angle = ${rotation * 180 / pi}[degree].");
      final rotator =
          Matrix2(cos(rotation), -sin(rotation), sin(rotation), cos(rotation));
      steps.postmultiply(rotator);
      // steps.postmultiply(_bounceRotator);
      // position.add(steps);
      return true;
    }
  }

  static const collisionGap = 0;
  bool bounceAtPaddle(PaddleO paddle, Rect iRect) {
    final rx = position.x;
    if (rx >= iRect.left && rx <= iRect.right) {
      logger.fine("Paddle top/bottom hit Ball.");
    /*
      // final backwardResult = stepBackward();
      steps.multiply(
          Vector2(1, -1)); // _reverseDy(); // _dy = -_dy; // reverse dy
      logger.fine("_dy is reversed to $_dy.");
      final paddleSurface = paddle.frontPosition.y;
      assert(paddleSurface == intersectionRect.bottom ||
          paddleSurface == intersectionRect.top);
      final lap = intersectionRect.height;
      assert(lap > 0);
      // final double yDistToPaddle = (position - paddle.position)[1];
      final dist = Vector2(
          0,
          paddleSurface == intersectionRect.bottom
              ? lap + collisionGap
              : -lap - collisionGap);
      logger.fine("Get distance from paddle:($position): $dist");
      position.add(dist);
      */
      unstep(unstepFactor / 2);
      logger.fine("position is unstepped to ($position) by steps($steps).");
      final slant = paddle.paddleSlant;
      final paddleVector = Vector2(paddle.size.x / 2,
          position.x > paddle.position.x ?
           slant : -slant);
      logger.info(
          "wall angle: ${atan2(paddleVector.x, paddleVector.y) * 180 / pi}[degree], steps angle = ${atan2(steps.x, steps.y) * 180}");
      final double angle = steps.angleToSigned(paddleVector) * (steps.x > 0 ? -2 : 2);
      logger.info("bounceToPaddle bounce angle = ${angle * 180 / pi}[degree].");
      final rotator =
      Matrix2(cos(angle + rotation), -sin(angle + rotation), sin(angle + rotation), cos(angle + rotation));
      logger.fine("before paddle bounce (dx, dy) = (${steps.x}, ${steps.y}).");
      steps.postmultiply(rotator);
      logger.fine("after paddle bounce (dx, dy) = (${steps.x}, ${steps.y}).");
      return true;
    } else {
      logger.fine("Paddle side hit Ball.");
      return false;
    }
  }

  double _speedRatio = 1;
  void changeSliderValue(double speed) {
    _speedRatio = speed;
  }

  double getSliderValue() => _speedRatio;
}

class RandAngleIterator extends Iterable with Iterator {
  final int start;
  final int range;
  final bool reverse;
  final rand = Random(DateTime.now().millisecondsSinceEpoch);
  int _e = 0;
  // var _s = false;
  int get v => reverse ? -(start + _e) : (start + _e); // ) * (_s ? 1 : -1);
  // bool get clockwise => _s;

  RandAngleIterator(this.start, this.range, {this.reverse = true}) {
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

class RandSignIterator extends Iterable with Iterator {
  final rand = Random(DateTime.now().millisecondsSinceEpoch);
  var _s = false;
  int get s => _s ? 1 : -1;

  RandSignIterator() {
    _s = rand.nextBool();
  }

  @override
  bool get current => _s;

  @override
  bool moveNext() {
    _s = rand.nextBool();
    return true;
  }

  @override
  Iterator get iterator => this;
}

class DeltaPosition {
  final double x;
  final double y;
  final Duration delta;

  DeltaPosition(this.delta, this.x, this.y); // Vector2 position) {
  // x = position.x; y = position.y; }

  static zero() => DeltaPosition(Duration.zero, 0, 0);

  /// speed per ms
  Vector2 getSpeedVector(DeltaPosition after) {
    /// vectors
    final double dX = after.x - x;
    final double dY = after.y - y;

    /// time dT
    final int dT = after.delta.inMilliseconds - delta.inMilliseconds;

    /// speeds
    final double xSpeed = dX / dT;
    final double ySpeed = dY / dT;
    return Vector2(xSpeed, ySpeed);
  }
}

enum PlusMinus {
  plus(1),
  minus(-1);

  final int value;

  const PlusMinus(this.value);

  static PlusMinus fromInt(int i) {
    if (i == 0) {
      throw Exception("0 is undefined plus or minus.");
    }
    return i > 0 ? PlusMinus.plus : PlusMinus.minus;
  }
}

enum Clockwise { cw, ccw }
