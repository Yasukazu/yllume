import 'package:flutter/material.dart';
import 'Wall.dart';
import 'WallBase.dart';
import 'package:illume/illume.dart';

class PaddleO extends WallO {
  static const wRatio = 0.2;
  PaddleO(wallPos pos) : super(pos) {
    assert(pos == wallPos.top || pos == wallPos.bottom);
  }
  static const gapToWall = 0.02;
  static const b = 0.1;

  @override
  Color getColor() => Colors.yellow;

  @override
  Vector2 getOffset() {
    final baseOffset = super.getOffset();
    return pos == wallPos.bottom
        ? Vector2(
            baseOffset[0], (1 - WallO.b - b / 2 - gapToWall) * gameSize[1])
        : Vector2(baseOffset[0], (WallO.b + gapToWall + b / 2) * gameSize[1]);
  }

  @override
  Vector2 getRect() => Vector2(wRatio * gameSize[0], b * gameSize[1]);
}
