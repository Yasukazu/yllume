import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:collection';
import 'main.dart'; // logger
import 'package:illume/illume.dart';
import 'WallBase.dart';
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
  int _speed = 0; // millisecond per diagonal
  int get speed => _speed;
  double _angle = 0;
  double get angle => _angle;
  double stepInterval = 0;
  double _stepX = 0;
  double _stepY = 0;
  double get stepX => dxReverse ? -_stepX : _stepX;
  double get stepY => dyReverse ? -_stepY : _stepY;
  Vector2 get stepVector => Vector2(stepX, stepY);
  double _dx = 0;
  double _dy = 0;
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
  final MotionLine motionLine;
  BallO(this.motionLine, this.selfPaddle, this.yieldBallPos, this.pause, this._dx, this._dy,
      [this._speed = defaultBallSpeed, this.ratio = PongGamePage.ballSize, this.pickupCycle = 2, this.pickupDelay = 2]) {
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
  BallO.withAngleProvider(this.motionLine, this.selfPaddle, this.yieldBallPos, this.pause, this.angleProvider,
      this._speed, this.ratio, [this.pickupCycle = 2, this.pickupDelay = 2]) {
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
    _dxReverse = false;
    _dyReverse = false;
    init();
  }

  static double calcSize(Vector2 gameSize, double ratio) {
    final x_ = ratio * gameSize[0];
    final y_ = ratio * gameSize[1];
    return sqrt(x_ * x_ + y_ * y_); // outer size
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
    final oSize = calcSize(gameSize, ratio);
    iSize = oSize * iRatio;
    logger.finer("Ball outer size = $oSize");
    size = Vector2.all(oSize);
    alignment = GameObjectAlignment.center;
    // final double offset = WallBaseO.bottomOffset(gameSize)[1];
    final double selfPaddleYPos = selfPaddle.position[1];
    final double selfPaddleHSize = selfPaddle.size[1];
    final double selfPaddleTopSurface = selfPaddleYPos - selfPaddleHSize / 2;
    position =
        Vector2(gx / 2, selfPaddleTopSurface - oSize / 2 - gap); // , gy / 2);
    initialised = true;
    _stepCount = 0;
    rebuildWidgetIfNeeded = true;
    randSignIterator.moveNext();
    motionLine.givenSize = size;
  }

  @override
  void onScreenSizeChange(Vector2 size) {
    final gameSize = size;
    final gx = gameSize[0];
    final gy = gameSize[1];
    final diagonal = sqrt(gx * gx + gy * gy);
    final stepLength = diagonal / defaultBallFPS * speed / 1000;
    stepInterval = diagonal / stepLength;
    _stepX = stepLength * dx;
    _stepY = stepLength * dy;
    logger.finer("stepInterval = $stepInterval");
    final oSize = calcSize(gameSize, ratio);
    iSize = oSize * iRatio;
    logger.finer("Ball outer size = $oSize");
    this.size = Vector2.all(oSize);
    alignment = GameObjectAlignment.center;
    final double selfPaddleYPos = selfPaddle.position[1];
    final double selfPaddleHSize = selfPaddle.size[1];
    final double selfPaddleTopSurface = selfPaddleYPos - selfPaddleHSize / 2;
    position =
        Vector2(gx / 2, selfPaddleTopSurface - oSize / 2 - gap); // , gy / 2);
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
      if (col.component is PaddleO) {
        resetYield();
        final paddle = col.component as PaddleO;
        if (!bounceAtPaddle(paddle.pos, col.intersectionRect)) {
          logger.finer("Paddle hit fail. Pausing..");
          pause(paddle.pos);
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
  double _motionCount = 0;

  @override
  void update(Duration delta) {
    if (delta.inMilliseconds - _lastUpdate > stepInterval) {
      _lastUpdate = delta.inMilliseconds;
      position = stepForward();
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
        if (_yieldCount < yieldMax && _pickupDeltaPositionQueue.length >= pickupDelay) {
          yieldBallPos(_pickupDeltaPositionQueue.removeFirst());
          ++_yieldCount;
        }
      }
      if (_stepCount % (pickupCycle * motionCycleRatio) == 0 && _pickupDeltaPositionQueue.isNotEmpty) {
        final Vector2 lastPosition = _pickupDeltaPositionQueue.elementAt(0).position;
        motionLine.givenPosition = lastPosition;
        motionLine.givenSize = size;
        logger.fine("Motionline");
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
  void reverseByOffsets(Vector2 offsets) {
    if (offsets[0] == 0 && offsets[1] != 0) {
      reverseDy();
      logger.finer("reverseByOffsets dy.");
      return;
    }
    else if (offsets[0] != 0 && offsets[1] == 0) {
      reverseDx();
      logger.finer("reverseByOffsets dx.");
      return;
    }
    throw Exception("No match condition.");
  }

  void bounceAtWall(Vector2 offsets) {
    stepBackward();
    reverseByOffsets(offsets);
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
  var _s = false;
  int get v => (reverse ? -(start + _e) : (start + _e)) * (_s ? 1 : -1);
  bool get clockwise => _s;

  RandAngleIterator(this.start, this.range, this.reverse) {
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
