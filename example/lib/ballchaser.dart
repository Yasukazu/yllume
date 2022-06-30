import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';
import 'dart:collection';

class BallChaser extends GameObject {
  static const color = Colors.purple;
  static const sizeRatio = 0.2;
  static const sampleCount = 2;
  final dPQueue = Queue<DeltaPosition>();
  List<DeltaPosition> ballDPs = [];

  bool? ballIsApproaching() {
    if (dPQueue.length < 2) {
      return null;
    }
    else {
      final dY = dPQueue.elementAt(0).position[1] - dPQueue.elementAt(1).position[1];
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

  Vector2 getBallCurPos(Duration delta, List<DeltaPosition> ballDPs) {
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
    final dT2 = delta.inMilliseconds - ballDPs[1].delta.inMilliseconds;
    final d2X = xSpeed * dT2;
    final d2Y = ySpeed * dT2;

    final x1 = ballDPs[1].position[0];
    final y1 = ballDPs[1].position[1];

    return Vector2(x1 + d2X, y1 + d2Y);
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
            height: 1,
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
    visible = false;
  }
  @override
  void update(Duration delta) {
    if (ballDPs.length >= 2) {
      final calculatedPos = getBallCurPos(delta, ballDPs);
      logger.finer("calculatedPos = $calculatedPos");
      position = calculatedPos;
      visible = true;
    }
    // position = Vector2(x, y);
  }
  @override
  void onCollision(List<Collision> cols) {
  }
}
