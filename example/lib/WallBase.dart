import 'package:flutter/material.dart';
import 'package:illume/illume.dart';

enum wallPos { top, bottom, left, right }

abstract class WallBaseO extends GameObject {
  static const shape = BoxShape.rectangle;
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
  WallBaseO(this.pos);

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


  @override
  void onScreenSizeChange(Vector2 size) {}

  @override
  void update(Duration delta) {}
}
