import 'main.dart';
import 'package:flutter/material.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';
import 'Wall.dart';
import 'WallBase.dart';
import 'Paddle.dart';
import 'dart:collection';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'dart:math';

class BallChaser extends GameObject {
  static const color = Colors.red;
  final double sizeRatio;
  static const sampleCount = 3;
  final _dPQueue = DelayBuffer(sampleCount); // Queue<DeltaPosition>();
  // List<DeltaPosition> ballDPs = [];
  final Vector2 _calculatedPos = Vector2.zero();

  Vector2 get calculatedPos => _calculatedPos;

  // final Map<wallPos, WallO> pos2wall;
  final WallO Function(wallPos) posToWall;
  final double _ballRatio;
  double _ballRad = 0.0;

  double _xMin = 0;
  double _xMax = 0;
  double yMin = 0;

  /// forward calculated ball position.
  static const int defaultForward = 900; // ms
  final int forwardTime;

  bool lastHitPaddleIsEnemy = false;

  BallChaser(this.posToWall, this._ballRatio,
      {this.sizeRatio = 0.2, this.forwardTime = defaultForward, this.chaseOnlyEnemy = true,
      this.forwardSteps = 0});

  @override
  void init() {
    collidable = false;
    alignment = GameObjectAlignment.center;
    visible = true;
    initialised = true;

    _ballRad = BallO.calcSize(gameSize, _ballRatio) / 2;
    final wallSurfaceXPos = posToWall(wallPos.left).surfacePosition()[0];
    _xMin = wallSurfaceXPos + _ballRad;
    final WallO rightWall = posToWall(wallPos.right);
    final wallXPos = rightWall.position[0] + rightWall.surfaceOffset;
    _xMax = wallXPos - _ballRad;
    // yMin =  posToWall(wallPos.top).surfacePosition().y + _ballRad;

    size
      ..setFrom(gameSize)
      ..scale(sizeRatio);
    position.x = 0;
    position.y = 0;
  }

  @override
  void onScreenSizeChange(Vector2 size) {
    _ballRad = BallO.calcSize(size, _ballRatio) / 2;
    final wallSurfaceXPos = posToWall(wallPos.left).surfacePosition()[0];
    _xMin = wallSurfaceXPos + _ballRad;
    final WallO rightWall = posToWall(wallPos.right);
    final wallXPos = rightWall.position[0] + rightWall.surfaceOffset;
    _xMax = wallXPos - _ballRad;
    size.setFrom(size);
    size.scale(sizeRatio);
  }

  bool? ballIsApproaching() {
    if (_dPQueue.length < 2) {
      return null;
    } else {
      final dY = _dPQueue[1].y - _dPQueue[0].y;
      return dY < 0;
    }
  }

  /// buffer clear command when parameter is null
  void putinBallPos(DeltaPosition? deltaPosition) {
    if (deltaPosition == null) {
      _dPQueue.clear();
      logger.finer("dPQueue clear.");
    } else {
      _dPQueue.putIn(deltaPosition);
    }
  }

  /// returns null if ballDPs.length is not enough to calculate.
  Matrix2 getBallCurPos(
      Vector2 cursor, Vector2 proceed, List<DeltaPosition> ballDPs, Duration delta,
      {setCurPos = true}) {
    assert(sampleCount >= 3);
    assert(ballDPs.length >= sampleCount);

    final startPos = Vector2(ballDPs[0].x, ballDPs[0].y);
    final nextPos = Vector2(ballDPs[1].x, ballDPs[1].y);
    final nextPos2 = Vector2(ballDPs[2].x, ballDPs[2].y);
    proceed.setFrom(nextPos - startPos);
    final proceed2 = nextPos2 - nextPos;
    final rotation = proceed.angleToSigned(proceed2);
    final rotator =
        Matrix2(cos(rotation), -sin(rotation), sin(rotation), cos(rotation));
    cursor.setFrom(startPos);

    /// proceed to current ball position
    if (setCurPos) {
      /// step time [ms]
      final stepTime =
          ballDPs[1].delta.inMilliseconds - ballDPs[0].delta.inMilliseconds;
      final steps = (delta - ballDPs[0].delta).inMilliseconds / stepTime;
      logger.fine("steps = $steps.");
      for (int i = 0; i < steps; ++i) {
        cursor.add(proceed);
        if (cursor.x > _xMax || cursor.x < _xMin) {
          var ar = 2 * proceed.angleTo(Vector2(0, 1));
          if (cursor.x < _xMin) {
            ar *= -1;
          }
          final rotr = Matrix2(cos(ar), -sin(ar), sin(ar), cos(ar));
          proceed.postmultiply(rotr);
          // proceed.multiply(Vector2(-1, 1));
        }
        proceed.postmultiply(rotator);
      }
    }
    return rotator;
  }

  /// calculate about landing position into cursor.
  /// returns false if over max bounce.
  bool calcLandingPos(
      Vector2 cursor, List<DeltaPosition> ballDPs, Matrix2 rotator) {
    assert(sampleCount >= 3);
    assert(ballDPs.length >= sampleCount);

    final startPos = Vector2(ballDPs[0].x, ballDPs[0].y);
    final nextPos = Vector2(ballDPs[1].x, ballDPs[1].y);
    final proceed = nextPos - startPos;
    var maxLoop = 500;
    var maxBounce = 5;
    cursor.setFrom(startPos);
    while (maxBounce > 0 && maxLoop-- > 0) {
      cursor.add(proceed);
      if (cursor.y <= yMin) {
        return true;
      }
      if (cursor.x > _xMax || cursor.x < _xMin) {
        proceed.multiply(Vector2(-1, 1));
        --maxBounce;
      }
      proceed.postmultiply(rotator);
    }
    return false;
  }

  static const thickness = 2.0;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Align(
          alignment: Alignment.center,
          child: Container(
            color: color,
            height: thickness,
          )),
      Align(
          alignment: Alignment.center,
          child: Container(
            color: color,
            width: thickness,
          )),
    ]);
  }

  int forwardSteps = 0;
  void forwardCursor(Vector2 cursor, Matrix2 rotator, Vector2 proceed) {
    for (int i = 0; i < forwardSteps; ++i) {
      cursor.add(proceed);
      cursor.postmultiply(rotator);
    }
  }

  bool chaseOnlyEnemy;
  @override
  void update(Duration delta) {
    if (chaseOnlyEnemy && lastHitPaddleIsEnemy) {
      return;
    }
    final List<DeltaPosition>? ballDPs = _dPQueue.putOut();
    if (ballDPs == null) {
      return;
    }
    final Vector2 cursor = Vector2(0, 0);
    final Vector2 proceed = Vector2(0, 0);
    final rotator = getBallCurPos(cursor, proceed, ballDPs, delta, setCurPos: true);
    if (forwardSteps > 0) {
      forwardCursor(cursor, rotator, proceed);
      logger.info("cursor is set as [$cursor].");
    }
    else {
      final calcSuccess = calcLandingPos(cursor, ballDPs, rotator);
      if (calcSuccess) {
        logger.finer("calculated current ball Position = $cursor");
      } else {
        logger.info("ball landing position to enemy failed.");
      }
    }
    position.setFrom(cursor);
    _calculatedPos.setFrom(cursor);
  }

  @override
  void onCollision(List<Collision> collisions) {}
}

class DelayBuffer {
  final _queue = Queue<DeltaPosition>();
  final int size;
  DelayBuffer(this.size);
  int get length => _queue.length;

  operator [](int i) => _queue.elementAt(i);

  List<DeltaPosition>? putOut() {
    if (_queue.length >= size) {
      return _queue.take(size).toList();
    } else {
      return null;
    }
  }

  bool putIn(DeltaPosition dp) {
    if (_queue.length < size) {
      _queue.add(dp);
      return true;
    }
    return false;
  }

  void clear() => _queue.clear();
}
