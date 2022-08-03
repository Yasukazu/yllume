import 'package:flutter/material.dart';
import 'WallBase.dart';
import 'Ball.dart';
import 'package:illume/illume.dart';
import 'main.dart'; // logger
import 'pongPage.dart';

typedef DoWithBall = void Function(BallO ball, Rect rect);

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
    bounce = (ball, rect) => ball.bounceAtWall(this, rect);

  }

  Vector2 surfacePosition() => position + surfaceOffsets;


  @override
  void onCollision(List<Collision> collisions) {
    for (Collision col in collisions) {
      if (col.component is BallO) {
        // final ball = col.component as BallO;
          // ball.bounceAtWall(this);
        logger.finer("Ball collision is delegated to ball.");
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
    size.setFrom(_rect);
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
    position.setFrom(_offset);
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
      return
          Container(
            color: color,
          );
   }

}

class SideWallO extends WallO {

  final double maxGapRatio;
  SideWallO(super.pos, {this.maxGapRatio = 0.05}) {
    assert(pos == wallPos.left || pos == wallPos.right);
  }

  double maxGap = 0;
  @override
  void init() {
    super.init();
    maxGap = size.y * maxGapRatio;
    logger.info("side wall max gap is initialized to $maxGap.");
  }

  @override
  void onScreenSizeChange(Vector2 size) {
    super.onScreenSizeChange(size);
    maxGap = size.y * maxGapRatio;
    logger.info("side wall max gap is reset to $maxGap.");
  }

  static const double minGap = 1;

  /// variable gap
  double gap(double y) {
    final r = y / size.y;
    final r2 = maxGap * r;
    logger.info("gap ratio = $r, maxGap = $maxGap, return = $r2.");
    return r2;
  }
  @override
  Widget build(BuildContext context) {
    final alpha = maxGap / size.y;
    if (pos == wallPos.right) {
      return
        Transform(
            transform: Matrix4.skewX(-alpha),
            child:
            Container(
              color: color,
            )
        );
    }
    else if (pos == wallPos.left) {
      return
        Transform(
            transform: Matrix4.skewX(alpha),
            child:
            Container(
              color: color,
            )
        );
    }
    else {
      return
        Container(
          color: color,
        );
    }
  }
}

class PlayerWallO extends WallO {
  final void Function(GameObject) pause;
  PlayerWallO(super.pos, this.pause);
  @override
  void onCollision(List<Collision> collisions) {
    logger.info("Wall collided with ${collisions.length} collisions.");
    for (Collision col in collisions) {
      if (col.component is BallO) {
        logger.info("Ball hit top/bottom wall!");
        pause(col.component); // if (pos == wallPos.top) { scoreEnemy(); }
        break;
      }
    }
  }
}
