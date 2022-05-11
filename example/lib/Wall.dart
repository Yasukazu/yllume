import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'MyHomePage.dart';
import 'Ball.dart';
import 'package:illume/illume.dart';
import 'package:intl/intl.dart';

enum wallPos { top, bottom, left, right }

abstract class Axis {
  Vector2 bounce(Vector2 v);
}

class XAxis implements Axis {
  @override
  Vector2 bounce(Vector2 v) => Vector2(v[0], -v[1]);
}

class WallPos {}

enum gameSizes { sizeX, sizeY }

typedef Vector2 v2ToV2(Vector2 vector2);

abstract class WallO extends GameObject {
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
  Vector2 get offset => getOffset();
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

  Vector2 get rect => getRect();
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

  final wallPos pos;
  // final BallO ball;

  WallO(this.pos);

  @override
  void init() {
    size = rect;
    alignment = GameObjectAlignment.center;
    position = offset;
  }

  @override
  Widget build(BuildContext context) {
    const color = Colors.yellow;
    return Container(
        alignment: Alignment(x, y),
        child: Stack(alignment: AlignmentDirectional.center, children: [
          Container(
            decoration: const BoxDecoration(shape: shape, color: color),
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

  @override
  void onCollision(List<Collision> collisions) {
    /*
    assert(collisions.length == 1); // only ball
    assert(collisions[0].component == ball);
    MyHomePage.collisionWallPos = pos;
    ball.backward();
    logger.info("ball backward by wall $pos.");
    ball.bounceAtWall(pos);
    */
    logger.fine("Wall colided with ${collisions.length} collisions:");
    var n = 1;
    for (Collision col in collisions) {
      BallO ball = col.component as BallO;
      ball.bounceAtWall(this);
      logger.finer("Wall($pos) bounced ball $n.");
      ++n;
    }
  }

  @override
  void onScreenSizeChange(Vector2 size) {}

  @override
  void update(Duration delta) {}

  void bounce(BallO ball);
}

class HWallO extends WallO {
  HWallO(wallPos pos) : super(pos) {
    assert(pos == wallPos.top || pos == wallPos.bottom);
  }

  @override
  void bounce(BallO ball) {
    ball.reverseDy();
  }
}

class VWallO extends WallO {
  VWallO(wallPos pos) : super(pos) {
    assert(pos == wallPos.left || pos == wallPos.right);
  }

  @override
  void bounce(BallO ball) {
    ball.reverseDx();
  }
}
