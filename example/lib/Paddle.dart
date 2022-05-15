import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'Wall.dart';
import 'WallBase.dart';
import 'Backwardable.dart';
import 'package:illume/illume.dart';

class PaddleO extends WallO with Backwardable {
  late final double step;
  late final double width;
  late final RangeNum rn;
  @override
  double get x => rn.d + offset[0];
  PaddleO(wallPos pos, this.width, this.step) : super(pos) {
    assert(pos == wallPos.top || pos == wallPos.bottom);
    assert(width > 0 && width <= 1);
    assert(step > 0 && step <= 1);
    rn = RangeNum(1 - width);
  }

  static const gapToWall = 0.02;
  static const b = 0.1;
  late final RangeNum range;

  @override
  Color getColor() => Colors.yellow;

  @override
  Vector2 getRect() => Vector2(width * gameSize[0], b * gameSize[1]);

  void moveRight() {
    if (lastPosForBackward != null) {
      return;
    }
    lastPosForBackward = position;
    logger.finer("move Right");
    rn.inc(step);
  }

  void moveLeft() {
    if (lastPosForBackward != null) {
      return;
    }
    lastPosForBackward = position;
    logger.finer("move Left");
    rn.dec(step);
  }
}

class RangeNum {
  double _d = 0;
  double get d => _d;
  final double range;

  RangeNum(this.range);

  void inc(double step) {
    if ((_d + step) <= range / 2) {
      _d += step;
    }
  }

  void dec(double step) {
    if ((_d - step) >= -range / 2) {
      _d -= step;
    }
  }
}
