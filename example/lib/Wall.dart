import 'package:flutter/material.dart';
import 'WallBase.dart';
import 'Ball.dart';
import 'package:illume/illume.dart';
import 'main.dart'; // logger
import 'pongPage.dart';

typedef DoWithBall = void Function(BallO ball);

class WallO extends WallBaseO {
  Vector2 _rect = Vector2.zero();
  Vector2 _offset = Vector2.zero();

  @override
  Color getColor() => Colors.brown;

  @override
  Vector2 getOffset() => _offset;

  @override
  Vector2 getRect() => _rect;

  late final DoWithBall bounce;

  WallO(wallPos pos) : super(pos) {
    if (pos == wallPos.top || pos == wallPos.bottom) {
      bounce = (ball) => ball.reverseDy;
    } else {
      bounce = (ball) => ball.reverseDx;
    }
  }

  Vector2 surfacePosition() {
    switch(pos) {
      case wallPos.top:
      case wallPos.bottom:
        return Vector2(position[0], position[1] + surfaceOffset);
      case wallPos.left:
      case wallPos.right:
        return Vector2(position[0] + surfaceOffset, position[1]);
    }
  }

  @override
  void onCollision(List<Collision> collisions) {
    for (Collision col in collisions) {
      if (col.component is BallO) {
        final ball = col.component as BallO;
          ball.bounceAtWall(pos);
          logger.fine("Ball is reversed by Wall.");
          break;
      }
    }
  }

  @override
  void init() {
    _rect = (pos == wallPos.top || pos == wallPos.bottom)
        ? Vector2((1 - WallBaseO.b - PongGamePage.ballSize) * gameSize[0],
            WallBaseO.b * gameSize[1])
        : Vector2(WallBaseO.b * gameSize[0],
            (1 - WallBaseO.b - PongGamePage.ballSize) * gameSize[1]);
    size = _rect;
    alignment = GameObjectAlignment.center;
    switch (pos) {
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
    position = _offset;
  }

  @override
  void onScreenSizeChange(Vector2 size) {
    final gameSize = size;
    _rect = (pos == wallPos.top || pos == wallPos.bottom)
        ? Vector2((1 - WallBaseO.b - PongGamePage.ballSize) * gameSize[0],
        WallBaseO.b * gameSize[1])
        : Vector2(WallBaseO.b * gameSize[0],
        (1 - WallBaseO.b - PongGamePage.ballSize) * gameSize[1]);
    this.size = _rect;
    alignment = GameObjectAlignment.center;
    switch (pos) {
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
    position = _offset;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }

}

class PlayerWallO extends WallO {
  final void Function(wallPos) pause;
  PlayerWallO(super.pos, this.pause);
  @override
  void onCollision(List<Collision> collisions) {
    logger.info("Wall collided with ${collisions.length} collisions.");
    for (Collision col in collisions) {
      if (col.component is BallO) {
        logger.info("Ball hit top/bottom wall!");
        pause(pos); // if (pos == wallPos.top) { scoreEnemy(); }
        break;
      }
    }
  }
}
