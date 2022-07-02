import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';
import 'Wall.dart';
import 'WallBase.dart';
import 'dart:collection';

class BallChaser extends GameObject {
  static const color = Colors.red;
  static const sizeRatio = 0.2;
  static const sampleCount = 2;
  final dPQueue = Queue<DeltaPosition>();
  List<DeltaPosition> ballDPs = [];
  Vector2? _calculatedPos;
  Vector2? get calculatedPos => _calculatedPos;
  final Map<wallPos, WallO> pos2wall;
  final double _ballRatio;
  double? _ballSize;
  double? get xMin {
    final wallSurfaceXPos = pos2wall[wallPos.left]?.surfacePosition()[0];
    return wallSurfaceXPos! + _ballSize!;
  }
  double? get xMax {
    final wall = pos2wall[wallPos.right];
    if (wall == null) {
      return null;
    }
    final surfaceOffset = wall.surfaceOffset;
    final wallXPos = wall.position[0] + surfaceOffset;
    return wallXPos - _ballSize!;
  }

  BallChaser(this.pos2wall, this._ballRatio){}

  bool? ballIsApproaching() {
    if (dPQueue.length < 2) {
      return null;
    }
    else {
      final dY = dPQueue.elementAt(1).position[1] - dPQueue.elementAt(0).position[1];
      return dY < 0;
    }
  }
  void yieldBallPos(DeltaPosition? deltaPosition) {
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

  static const dTForward = 500;
  Vector2 getBallCurPos(Duration delta) {
    assert(ballDPs.length >= 2);

    /// vectors
    final double dY = ballDPs[1].position[1] - ballDPs[0].position[1];
    final double dX = ballDPs[1].position[0] - ballDPs[0].position[0];

    /// time dT
    final int dT = ballDPs[1].delta.inMilliseconds - ballDPs[0].delta.inMilliseconds;

    /// speeds
    final double xSpeed = dX / dT;
    final double ySpeed = dY / dT;

    /// current scalars
    final dT2 = delta.inMilliseconds - ballDPs[1].delta.inMilliseconds + dTForward;
    final d2X = xSpeed * dT2;
    final d2Y = ySpeed * dT2;

    double x2 = ballDPs[1].position[0] + d2X;
    double? max = xMax;
    if (max != null && x2 > max) {
      final diff = x2 - max;
      x2 -= 2 * diff;
    }
    double? min = xMin;
    if (min != null && x2 < min) {
      final diff = min - x2;
      x2 += 2 * diff;
    }
    final y1 = ballDPs[1].position[1];
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
  void onScreenSizeChange(Vector2 size) {
    /// TODO: implement onScreenSizeChange
  }
  @override
  void init() {
    // super.init();
    collidable = false;
    alignment = GameObjectAlignment.center;
    size = Vector2(sizeRatio * gameSize[0], sizeRatio * gameSize[1]);
    // position = Vector2(x, y);
    initialised = true;
    visible = true;
    _ballSize = BallO.calcSize(gameSize, _ballRatio) / 2;
  }

  @override
  void update(Duration delta) {
    if (dPQueue.length >= 2) {
      ballDPs = dPQueue.take(2).toList();
      _calculatedPos = getBallCurPos(delta);
      logger.finer("calculatedPos = $_calculatedPos");
      position = _calculatedPos as Vector2;
      // visible = true;
    }
    // position = Vector2(x, y);
  }
  @override
  void onCollision(List<Collision> collisions) {
  }
}
