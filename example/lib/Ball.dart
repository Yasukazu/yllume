import 'package:flutter/material.dart';
// logger.fine('stepBackwardResult: $backwardResult. after position = [$position].');

import 'package:vector_math/vector_math.dart' hide Colors;
import 'dart:math';
import 'dart:collection';
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
  final void Function(wallPos) pause;
  final List<MotionLine> motionLines;
  static const defaultRotation = 0.3; // rad
  double _rotation = 0;
  double get rotation => _rotateCW ? _rotation : -_rotation;
  BallO(this.motionLines, this.selfPaddle, this.yieldBallPos, this.pause, this._dx, this._dy,
      [this._speed = defaultBallSpeed, this.ratio = PongGamePage.ballSize, this.pickupCycle = 2, this.pickupDelay = 2, this._rotation = defaultRotation]) {
    assert(_dx > 0 && _dy > 0);
    assert(_speed > 0);
    assert(ratio > 0);
    _angle = atan2(_dx, _dy);
  }

  /// send null to clear dp queue
  final void Function(DeltaPosition?) yieldBallPos;

  late final RandAngleIterator? angleProvider;
  final RandSignIterator randSignIterator = RandSignIterator();
  // final void Function(GameObject) addWithDuration;
  BallO.withAngleProvider(this.motionLines, this.selfPaddle, this.yieldBallPos, this.pause, this.angleProvider,
      this._speed, this.ratio, [this.pickupCycle = 2, this.pickupDelay = 2, this._rotation = defaultRotation]) {
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
      logger.finer("stepInterval = $stepInterval");
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
        motionLine.givenSize = size;
      }
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
      position.setValues(size[0] / 2, selfPaddleTopSurface - oSize / 2 - gap); // , gy / 2);
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
          resetYield();
          final paddle = col.component as PaddleO;
          if (!bounceAtPaddle(paddle, col.intersectionRect)) {
            logger.fine("Paddle hit fail. Pausing..");
            pause(paddle.pos);
          }
        }
        else if (col.component is WallO) {
          final wall = col.component as WallO;
          switch(wall.pos) {
            case wallPos.left:
            case wallPos.right:
              bounceAtWall(wall, col.intersectionRect);
              logger.finer("bounce at wall.");
              break;
            case wallPos.top:
            case wallPos.bottom:
              resetYield();
              logger.fine("ball hit top/bottom wall. pause..");
              pause(wall.pos);
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
      return DeltaPosition(delta, position);
    }

    final motionCycleRatio = 2;
    int _motionCount = 0;

    @override
    void update(Duration delta) {
      if (delta.inMilliseconds - _lastUpdate > stepInterval) {
        _lastUpdate = delta.inMilliseconds;
        position.setFrom(stepForward());
        // setState(() {
        iPos = iPos + (_rotateCW ? 1 : -1);
        coreAlignment = coreAlignments[iPos % coreAlignments.length];
        logger.finer("coreAlignment is set as $coreAlignment by $iPos.");
        // });
        rebuildWidget();
        logger.finer("rebuild ball.");
        logger.finest("Update ball pos: (${position[0]}, ${position[1]}).");
        if (_stepCount % pickupCycle == 0) {
          // delta != Duration.zero && position != Vector2.zero() &&
          _pickupDeltaPositionQueue.add(DeltaPosition(delta, position));
          if (_yieldCount < yieldMax && _pickupDeltaPositionQueue.length >= pickupDelay) { //_yieldCount < yieldMax &&
            yieldBallPos(_pickupDeltaPositionQueue.removeFirst());
            ++_yieldCount;
          }
        }
        if (_stepCount % (pickupCycle * motionCycleRatio) == 0 && _pickupDeltaPositionQueue.isNotEmpty) {
          final Vector2 lastPosition = _pickupDeltaPositionQueue.elementAt(0).position;
          final motionNumber = _motionCount % motionLines.length;
          final motionLine = motionLines[motionNumber];
          motionLine.position = lastPosition;
          motionLine.size = size;
          motionLine.turnOn();
          logger.fine("Motionline[$motionNumber] position is set to $lastPosition, size is set to $size.");
          _motionCount++;
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
      lastPosForBackward = position.clone();
      return _step();
    }

    /*
    bool stepBackward() {
      if (lastPosForBackward != null) {
        position.setFrom(lastPosForBackward as Vector2);
        logger.finer("step backward by lastPosForBackward.");
        return true;
      }
      else {
        logger.warning("step backward failed 'cause lastPosForBackward == null.");
        return false;
      }
    } */

    // void clearStepCount() { _stepCount = 0; }
    // void updateLastPosWithPosition() { lastPos = position; }

    void _reverseDx() {
      _dx = - _dx;
      logger.finer("dx reverse.");
    }

    void _reverseDy() {
      _dy = - _dy;
      logger.finer("dy reverse.");
    }

    void _reverseByWallPos(wallPos pos) {
      switch (pos) {
        case wallPos.left:
        case wallPos.right: // if( offsets[0] == 0 && offsets[1] != 0) {
          _reverseDx();
          logger.finer("reverseByWallPos dx.");
          break;
        case wallPos.top:
        case wallPos.bottom:
          _reverseDy();
          logger.finer("reverseByWallPos dy.");
          break;
        default:
          throw Exception ( " No match condition. " );
      }
    }

    void bounceAtWall(WallBaseO wall, Rect rect) { // Vector2 offsets) {
      // if(!stepBackward()) { throw Exception("stepBackward failed!"); }
      assert(wall.pos == wallPos.left || wall.pos == wallPos.right);
      final lap = rect.width;
      assert(lap > 0);
      Vector2 dist = Vector2(wall.pos == wallPos.left ? lap + collisionGap :
      -lap -collisionGap, 0);
      logger.fine("going to add position($position): $dist");
      position.add(dist);
      _reverseByWallPos(wall.pos);
      _rotate();
      _setSteps(gameSize);
    }

    void _rotate() {
      final Vector2 _rotated = _getRotated();
      if (_dx.sign == _rotated[0].sign && _dy.sign == _rotated[1].sign) {
        logger.finer("before _dx and _dy are rotated: ($_dx, $_dy)");
        _dx = _rotated[0];
        _dy = _rotated[1];
        logger.finer("after _dx and _dy are rotated: ($_dx, $_dy)");
      }
      else {
        logger.warning("_dx _dy rotation failed.");
      }
    }

    Vector2 _getRotated() {
      final a = rotation;
      final rotator = Matrix2(cos(a), -sin(a), sin(a), cos(a));
      final vector = Vector2(_dx, _dy);
      vector.postmultiply(rotator);
      return vector;
    }

    static const collisionGap = 2;
    bool bounceAtPaddle(PaddleO paddle, Rect intersectionRect) {
      // wallPos wp) {
      // clearStepCount();
      // updateLastPosWithPosition();
      final rx = position[0];
      if (rx >= intersectionRect.left && rx <= intersectionRect.right) {
        logger.fine("Paddle top/bottom hit Ball.");
        // final backwardResult = stepBackward();
        _reverseDy(); // _dy = -_dy; // reverse dy
        logger.fine("_dy is reversed to $_dy.");
        final paddleSurface = paddle.frontPosition.y;
        assert(paddleSurface == intersectionRect.bottom || paddleSurface == intersectionRect.top);
        final lap = intersectionRect.bottom - intersectionRect.top;
        assert(lap > 0);
        // final double yDistToPaddle = (position - paddle.position)[1];
        final dist = Vector2(0, paddleSurface == intersectionRect.bottom ? lap + collisionGap : -lap - collisionGap);
        logger.fine("going to add position($position): $dist");
        position.add(dist);
        logger.fine("position is moved to $position");
        logger.fine("rotated before dx, dy = ($_dx, $_dy).");
        _rotate();
        logger.fine("rotated after dx, dy = ($_dx, $_dy).");
        logger.fine("before steps: $steps.");
        _setSteps(gameSize);
        logger.fine("after steps: $steps.");
        // _pickupDeltaPositionQueue.clear();
        return true;
      }
      else {
        logger.fine("Paddle side hit Ball.");
        // reverseDx();
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

enum Clockwise {cw, ccw}