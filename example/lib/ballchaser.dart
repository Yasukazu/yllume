import 'main.dart';
import 'package:flutter/material.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';
import 'Wall.dart';
import 'WallBase.dart';
import 'dart:collection';

class BallChaser extends GameObject {
  static const color = Colors.red;
  final double sizeRatio;
  static const sampleCount = 2;
  final dPQueue = Queue<DeltaPosition>();
  List<DeltaPosition> ballDPs = [];
  Vector2 _calculatedPos = Vector2.zero();
  Vector2 get calculatedPos => _calculatedPos;
  // final Map<wallPos, WallO> pos2wall;
  final WallO Function(wallPos) posToWall;
  final double _ballRatio;
  double _ballRad = 0.0;

  double _xMin = 0;
  double _xMax = 0;

  /// forward calculated ball position.
  static const int defaultForward = 900; // ms
  final int forwardTime;

  BallChaser(this.posToWall, this._ballRatio, {this.sizeRatio = 0.2, this.forwardTime = defaultForward});

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

    size..setFrom(gameSize)
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
    size..setFrom(size)
      ..scale(sizeRatio);
  }

  bool? ballIsApproaching() {
    if (dPQueue.length < 2) {
      return null;
    }
    else {
      final dY = dPQueue.elementAt(1).y - dPQueue.elementAt(0).y;
      return dY < 0;
    }
  }
  void pickupBallPos(DeltaPosition? deltaPosition) {
    if (deltaPosition == null) {
      dPQueue.clear();
      logger.finer("dPQueue clear.");
    }
    else {
      if (dPQueue.isNotEmpty) {
        assert(dPQueue.last != deltaPosition);
      }
      dPQueue.add(deltaPosition);
      if (dPQueue.length > sampleCount) {
        dPQueue.removeFirst();
      }
    }
  }


  /// returns null if ballDPs.length is not enough to calculate.
  Vector2 getBallCurPos(Duration delta) {
    assert(ballDPs.length >= 2);

    /// speeds
    final speeds = ballDPs[0].getSpeedVector(ballDPs[1]);
    final double xSpeed = speeds.x;
    final double ySpeed = speeds.y;

    /// current scalars
    final int dT2 = delta.inMilliseconds - ballDPs[1].delta.inMilliseconds + forwardTime;
    final d2X = xSpeed * dT2;
    final d2Y = ySpeed * dT2;

    double x2 = ballDPs[1].x + d2X;
    final double max = _xMax;
    if (x2 > max) {
      final diff = x2 - max;
      x2 -= 2 * diff;
    }
    final min = _xMin;
    if (x2 < min) {
      final diff = min - x2;
      x2 += 2 * diff;
    }
    final y1 = ballDPs[1].x;
    return Vector2(x2, y1 + d2Y);
  }

  /// returns [] if not enough data
  List<DeltaPosition> getBallPoss() {
    if (dPQueue.length >= sampleCount) {
      return dPQueue.take(sampleCount).toList();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Align(
          alignment: Alignment.center,
          child: Container(
            color: color,
            height: 2,
          )
      ),
      Align(
          alignment: Alignment.center,
          child: Container(
            color: color,
            width: 1,
          )
      ),
    ]);
  }


  @override
  void update(Duration delta) {
    if (dPQueue.length >= 2) {
      ballDPs = dPQueue.take(2).toList();
      final stepTime = (ballDPs[1].delta - ballDPs[0].delta).inMilliseconds;
      final stepSpeeds = ballDPs[0].getSpeedVector(ballDPs[1]);
      final ballCurPos = getBallCurPos(delta);
      logger.finer("calculated current ball Position = $ballCurPos");
      position.setFrom(ballCurPos);
      _calculatedPos.setFrom(ballCurPos);
    }
  }

  @override
  void onCollision(List<Collision> collisions) {
  }
}
