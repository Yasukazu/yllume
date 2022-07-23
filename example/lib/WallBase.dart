import 'package:flutter/material.dart';
import 'package:illume/illume.dart';
import 'pongPage.dart';
import 'package:example/Backwardable.dart';

extension OffsetVector2 on Vector2 {
  static Vector2? _topOffset;
  static Vector2 get topOffset {
    _topOffset ??= Vector2(0, -1);
    return _topOffset as Vector2;
  }
}

enum WallSurface {homeToAway, sideToSide}

enum wallPos { top(0), bottom(2), left(3), right(1);
  final int value;
  const wallPos(this.value);

  WallSurface get surface => this == top || this == bottom ? WallSurface.sideToSide : WallSurface.homeToAway;

  Vector2 get offsetVector {
    switch(this) {
      case top:
        return Vector2(0, -1);
      case bottom:
        return Vector2(0, 1);
      case right:
        return Vector2(1, 0);
      case left:
        return Vector2(-1, 0);
      default:
        throw Exception("Not defined.");
    }
  }

  wallPos get opposite {
        switch(this) {
          case top:
            return wallPos.bottom;
          case bottom:
            return wallPos.top;
          case right:
            return wallPos.left;
          case left:
            return wallPos.right;
          default:
            throw Exception("Not defined.");
        }
  } // => value & 1 != 0 ? value & 0 : value + 1;
}

abstract class WallBaseO extends GameObject with CollisionFront {
  static const shape = BoxShape.rectangle;
  static const b = PongGamePage.wallT;
  static topOffset(Vector2 gameSize) =>
      Vector2(gameSize[0] / 2, b / 2 * gameSize[1]);
  static leftOffset(Vector2 gameSize) =>
      Vector2(b / 2 * gameSize[0], gameSize[1] / 2);
  static bottomOffset(Vector2 gameSize) =>
      Vector2(gameSize[0] / 2, gameSize[1] * (1 - b / 2));
  static rightOffset(Vector2 gameSize) =>
      Vector2(gameSize[0] * (1 - b / 2), gameSize[1] / 2);
  static const offsets = [topOffset, leftOffset, bottomOffset, rightOffset];
  final wallPos pos;
  // late final Vector2 lastPosBeforeCollision;
  Vector2 get rect => getRect();
  Vector2 getRect();
  Color get color => getColor();
  Color getColor();
  double get x => offset[0];
  double get y => offset[1];
  Vector2 get offset => getOffset();
  Vector2 getOffset();
  late Vector2 sSize;
  static const sRatio = 0.2;

  WallBaseO(this.pos);

  double get surfaceOffset  {
    switch(pos) {
      case wallPos.top:
        return -size[1] / 2;
      case wallPos.bottom:
        return size[1] / 2;
      case wallPos.left:
        return -size[0] / 2;
      case wallPos.right:
        return size[0] / 2;
    }
  }

  Vector2 get surfaceOffsets  {
    switch(pos) {
      case wallPos.top:
        return Vector2(0, -size[1] / 2); //  (offsetVector.clone().multiply(size)) / 2
      case wallPos.bottom:
        return Vector2(0, size[1] / 2);
      case wallPos.left:
        return Vector2(-size[0] / 2, 0);
      case wallPos.right:
        return Vector2(size[0] / 2, 0);
    }
  }

  @override
  void init() {
    size = rect;
    alignment = GameObjectAlignment.center;
    position = offset;
    sSize = Vector2(sRatio * size[0], sRatio * size[1]);
  }

  @override
  Widget build(BuildContext context) {
    return
        // Container( //alignment: Alignment(x, y), child:
        Stack(alignment: AlignmentDirectional.center, children: [
      Container(
        decoration: BoxDecoration(shape: shape, color: color),
        // width: size[0],
        // height: size[1],
      ),
      Container(
        decoration: const BoxDecoration(shape: shape, color: Colors.black),
        width: sSize[0],
        height: sSize[1],
      ),
    ]);
  }


  @override
  void update(Duration delta) {}

  @override
  Vector2 get toFront {
    switch (pos) {
      case wallPos.bottom:
        return Vector2(0, size.y / 2);
      case wallPos.top:
        return Vector2(0, -size.y / 2);
      case wallPos.right:
        return Vector2(size.y / 2, 0);
      case wallPos.left:
        return Vector2(-size.y / 2, 0);
      default:
        throw Exception("Not defined.");
    }
  }
  @override
  Vector2 get frontPosition => position + toFront;
}
