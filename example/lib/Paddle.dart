import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'MyHomePage.dart';
import 'Ball.dart';
import 'Wall.dart';
import 'package:illume/illume.dart';
import 'package:intl/intl.dart';

class PaddleO extends HWallO {
  PaddleO(wallPos pos) : super(pos);

  static const gapToWall = 5;
  static const b = 12;

  @override
  Vector2 getOffset() {
    final baseOffset = super.offset;
    return pos == wallPos.bottom ? Vector2(baseOffset[0], (1 - WallO.b - b - gapToWall) * gameSize[1]):
    Vector2(baseOffset[0], (WallO.b + gapToWall + b / 2) * gameSize[1]);
  }

}
