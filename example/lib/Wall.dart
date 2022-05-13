import 'package:flutter/material.dart';
import 'MyHomePage.dart';
import 'WallBase.dart';
import 'Ball.dart';
import 'package:illume/illume.dart';

typedef DoWithBall = void Function(BallO ball);

class WallO extends WallBaseO {
  @override
  Color getColor() => Colors.brown;
  static const shape = BoxShape.rectangle;
  static const b = MyHomePage.wallT;
  static topOffset(Vector2 gameSize) =>
      Vector2(gameSize[0] / 2, b / 2 * gameSize[1]);
  static leftOffset(Vector2 gameSize) =>
      Vector2(b / 2 * gameSize[0], gameSize[1] / 2);
  static bottomOffset(Vector2 gameSize) =>
      Vector2(gameSize[0] / 2, gameSize[1] * (1 - b / 2));
  static rightOffset(Vector2 gameSize) =>
      Vector2(gameSize[0] * (1 - b / 2), gameSize[1] / 2);
  static const offsets = [topOffset, leftOffset, bottomOffset, rightOffset];
  double get x => offset[0];
  double get y => offset[1];

  @override
  Vector2 getOffset() {
    switch (pos) {
      case wallPos.top:
        return topOffset(gameSize);
      case wallPos.left:
        return leftOffset(gameSize);
      case wallPos.bottom:
        return bottomOffset(gameSize);
      case wallPos.right:
        return rightOffset(gameSize);
    }
  }

  
  @override
  Vector2 getRect() {
    switch (pos) {
      case wallPos.top:
      case wallPos.bottom:
        return Vector2(
            (1 - b - MyHomePage.ballSize) * gameSize[0], b * gameSize[1]);
      case wallPos.left:
      case wallPos.right:
        return Vector2(
            b * gameSize[0], (1 - b - MyHomePage.ballSize) * gameSize[1]);
    }
  }

  late final DoWithBall bounce;

  WallO(wallPos pos) : super(pos) {
    if (pos == wallPos.top || pos == wallPos.bottom) {
      bounce = (ball) => ball.reverseDy;
    } else {
      bounce = (ball) => ball.reverseDx;
    }
  }

  @override
  void init() {
    size = rect;
    alignment = GameObjectAlignment.center;
    position = offset;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(x, y),
        child: Stack(alignment: AlignmentDirectional.center, children: [
          Container(
            decoration: BoxDecoration(shape: shape, color: color),
            width: size[0],
            height: size[1],
          ),
          Container(
            decoration: const BoxDecoration(shape: shape, color: Colors.black),
            width: 0.2 * size[0],
            height: 0.2 * size[1],
          ),
        ]));
  }

}
