import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'MyHomePage.dart';
import 'Ball.dart';
import 'package:illume/illume.dart';
import 'package:intl/intl.dart';

enum wallPos {top, bottom, left, right}

enum gameSizes {sizeX, sizeY}

typedef Vector2 v2ToV2(Vector2 vector2);

class WallO extends GameObject {
  static const shape = BoxShape.rectangle;
  static const b = MyHomePage.wallT;
  static topOffset(Vector2 gameSize) => Vector2(gameSize[0] / 2, b / 2 * gameSize[1]);
  static leftOffset(Vector2 gameSize) => Vector2(b / 2 * gameSize[0], gameSize[1] / 2);
  static bottomOffset(Vector2 gameSize) => Vector2(gameSize[0] / 2, gameSize[1] * ( 1 - b / 2));
  static rightOffset(Vector2 gameSize) => Vector2(gameSize[0] * (1 - b / 2), gameSize[1] / 2);
  static const offsets = [topOffset, leftOffset, bottomOffset, rightOffset];
  double get x => offset[0];
  double get y => offset[1];
  Vector2 get offset {
    switch(pos) {
      case wallPos.top: return topOffset(gameSize);
      case wallPos.left: return leftOffset(gameSize);
      case wallPos.bottom: return bottomOffset(gameSize);
      case wallPos.right: return rightOffset(gameSize) ;
    }
  }
  Vector2 get rect {
    switch(pos) {
      case wallPos.top:
      case wallPos.bottom:
        return Vector2((1 - b - MyHomePage.ballSize) * gameSize[0], b * gameSize[1]);
      case wallPos.left:
      case wallPos.right:
        return Vector2(b * gameSize[0], (1 - b - MyHomePage.ballSize) * gameSize[1]);
    }
  }
  final wallPos pos;
  final BallO ball;

  WallO(this.pos, this.ball);

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
        child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
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
            ])
    );
  }


  @override
  void onCollision(List<Collision> collisions) {
    // final fmt = NumberFormat('##.0#', 'en_US');
    // final lenText = "Wall .len=${collisions.length} at ballX=${fmt.format(MyHomePage.ballX)},ballY=${fmt.format(MyHomePage.ballY)}";
    assert(collisions.length == 1); // only ball
    assert(collisions[0].component == ball);
    ball.backward();
    logger.info("ball backward by wall $pos.");
    switch(pos) {
      case wallPos.left:
      case wallPos.right:
        ball.dxReverse = !ball.dxReverse;
        logger.info("ball dxReverse is reversed to ${ball.dxReverse}.");
        return;
      case wallPos.top:
      case wallPos.bottom:
        ball.dyReverse = !ball.dyReverse;
        logger.info("ball dyReverse is reversed to ${ball.dyReverse}");
        return;
    }
  }

  @override
  void onScreenSizeChange(Vector2 size) {
  }

  @override
  void update(Duration delta) {
  }
}
