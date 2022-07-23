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
  final Vector2 givenPosition = Vector2(0, 0);
  double opacity = 0.0;
  // double get opacity => _opacity;
  // void set opacity(double v) { _opacity = v;}
  final int seq;

  MotionLine(this.seq, this.givenSize);

  void setPosition(Vector2 other) {
    givenPosition.setFrom(other);
  }

  @override init() {
    size = givenSize;
    // position = givenPosition;
    alignment = GameObjectAlignment.center;
    collidable = false;
    rebuildWidgetIfNeeded = true;
    visible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(opacity)),
    );
  }

  @override void onCollision(List<Collision> collisions) {
  }

  @override void update(Duration delta) {
    // size = givenSize;
    // position = givenPosition;
    // opacity = 0.6;
    rebuildWidget();
    logger.finer("MotionLine: size: $size, position: $position, opacity: $opacity.");
  }

  @override void onScreenSizeChange(Vector2 size) {
    // opacity = 0.0;
  }

  void turnOn() {
    opacity = 0.6;
  }

  void dim() {
    opacity -= 0.2;
  }

  void turnOff() {
    opacity = 0;
  }

}