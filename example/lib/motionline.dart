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
  final Vector2 givenSize;
  final Vector2 givenPosition;

  MotionLine(this.givenSize, this.givenPosition);

  @override init() {
    size = givenSize;
    position = givenPosition;
    alignment = GameObjectAlignment.center;
    collidable = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.3)),
    );
  }

  @override void onCollision(List<Collision> collisions) {
  }

  @override void update(Duration delta) {
  }

  @override void onScreenSizeChange(Vector2 size) {
  }
}