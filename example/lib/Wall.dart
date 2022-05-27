import 'package:flutter/material.dart';
import 'MyHomePage.dart';
import 'WallBase.dart';
import 'Ball.dart';
import 'package:illume/illume.dart';

typedef DoWithBall = void Function(BallO ball);

class WallO extends WallBaseO {
  late final Vector2 _rect;
  late final Vector2 _offset;
  @override
  Color getColor() => Colors.brown;


  @override
  Vector2 getOffset() => _offset;

  @override
  Vector2 getRect() => _rect;

  @override
  void onCollision(List<Collision> collisions) {}

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
    _rect = (pos == wallPos.top || pos == wallPos.bottom)
        ? Vector2((1 - WallBaseO.b - MyHomePage.ballSize) * gameSize[0], WallBaseO.b * gameSize[1])
        : Vector2(WallBaseO.b * gameSize[0], (1 - WallBaseO.b - MyHomePage.ballSize) * gameSize[1]);
    size = rect;
    alignment = GameObjectAlignment.center;
    switch(pos) {
      case wallPos.top:
        _offset = WallBaseO.topOffset(gameSize);
        break;
      case wallPos.left:
        _offset = WallBaseO.leftOffset(gameSize);
        break;
      case wallPos.bottom:
        _offset = WallBaseO.bottomOffset(gameSize);
        break;
      case wallPos.right:
        _offset = WallBaseO.rightOffset(gameSize);
        break;
    }
    position = offset;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}
