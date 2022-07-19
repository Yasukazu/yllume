import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:collection';
import 'main.dart'; // logger
import 'package:illume/illume.dart';
import 'WallBase.dart';
import 'Ball.dart';
import 'pongPage.dart';
import 'Backwardable.dart';

class MotionLine extends GameObject {
  Vector2 givenSize = Vector2.zero();
  Vector2 givenPosition = Vector2.zero();

  @override init() {
    size = givenSize;
    position = givenPosition;
    alignment = GameObjectAlignment.center;
    collidable = false;
    rebuildWidgetIfNeeded = true;
    visible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.6)),
    );
  }

  @override void onCollision(List<Collision> collisions) {
  }

  @override void update(Duration delta) {
    size = givenSize;
    position = givenPosition;
  }

  @override void onScreenSizeChange(Vector2 size) {
  }
}