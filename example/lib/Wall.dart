import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tuple/tuple.dart';
import 'orgMain.dart';
import 'MyHomePage.dart';
import 'package:illume/illume.dart';

enum wallPos {top, bottom, left, right}

enum gameSizes {sizeX, sizeY}

typedef Vector2 v2ToV2(Vector2 vector2);

class WallO extends GameObject {
  static const shape = BoxShape.rectangle;
  static const b = MyHomePage.wallT;
  static topOffset(Vector2 gameSize) => Vector2(gameSize[0] / 2, b / 2);
  static leftOffset(Vector2 gameSize) => Vector2(b / 2, gameSize[1] / 2);
  static bottomOffset(Vector2 gameSize) => Vector2(gameSize[0] / 2, gameSize[1] - b / 2);
  static rightOffset(Vector2 gameSize) => Vector2(gameSize[0] - b / 2, gameSize[1] / 2);
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
        return Vector2(gameSize[0], b);
      case wallPos.left:
      case wallPos.right:
        return Vector2(b, gameSize[1]);
    }
  }
  final wallPos pos;

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
    final Vector2 size = gameSize; // MediaQuery.of(context).size.height;
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
  }

  @override
  void onScreenSizeChange(Vector2 size) {
  }

  @override
  void update(Duration delta) {
  }
}
