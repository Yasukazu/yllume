import 'package:flutter/material.dart';
import 'main.dart'; // logger
import 'package:illume/illume.dart';

class MotionLine extends GameObject {
  final double givenRatio;
  double opacity = 0.0;
  final int seq; // ID

  MotionLine(this.seq, this.givenRatio);

  @override init() {
    size *= givenRatio;
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
    rebuildWidget();
    logger.finer("MotionLine: size: $size, position: $position, opacity: $opacity.");
  }

  @override void onScreenSizeChange(Vector2 size) {
    this.size.setFrom(size);
    this.size *= givenRatio;
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