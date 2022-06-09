import 'package:flutter/material.dart';
import 'package:illume/illume.dart';
import 'pongPage.dart';
enum wallPos { top, bottom, left, right }

abstract class WallBaseO extends GameObject {
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
  void onScreenSizeChange(Vector2 size) {}

  @override
  void update(Duration delta) {}
}
