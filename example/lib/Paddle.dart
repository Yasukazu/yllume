import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'MyHomePage.dart';
import 'Ball.dart';
import 'Wall.dart';
import 'package:illume/illume.dart';
import 'package:intl/intl.dart';

class PaddleO extends HWallO {
  static const wRatio = 0.2;
  PaddleO(wallPos pos) : super(pos) {
    assert(pos == wallPos.top || pos == wallPos.bottom);
  }
  static const gapToWall = 0.05;
  static const b = 0.25;
  @override
  Color getColor() => Colors.yellow;

  @override
  Vector2 getOffset() {
    final baseOffset = super.offset;
    return pos == wallPos.bottom
        ? Vector2(baseOffset[0], (1 - WallO.b - b - gapToWall) * gameSize[1])
        : Vector2(baseOffset[0], (WallO.b + gapToWall + b / 2) * gameSize[1]);
  }

  @override
  Vector2 getRect() => Vector2(wRatio * gameSize[0], b * gameSize[1]);
}
