import 'package:example/MyHomePage.dart';
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
  // Vector2? lastPosForBackward;
  @override
  double x = 0;
  // @override double get x => rn.d + offset[0];

  @override
  Vector2 getOffset() {
    final offset = super.getOffset();
    final diff =
        (MyHomePage.wpGap + MyHomePage.wallT / 2 + b / 2) * gameSize[1];
    final rdiff = pos == wallPos.top ? diff : -diff;
    return Vector2(offset[0], offset[1] + rdiff);
  }

  PaddleO(wallPos pos, this.width, this.step) : super(pos) {
    assert(pos == wallPos.top || pos == wallPos.bottom);
    assert(width > 0 && width <= 1);
    assert(step > 0 && step <= 1);
    rn = RangeNum(1 - width);
  }

  static const b = MyHomePage.paddleT;
  late final RangeNum range;

  @override
  void update(Duration delta) {
    super.update(delta);
    // x = rn.d + offset[0];
    position = Vector2(x * gameSize[0] + offset[0], offset[1]);
    logger.finer("Paddle.x = $x; position[0]= ${position[0]}");
  }

  @override
  Color getColor() => Colors.yellow;

  @override
  Vector2 getRect() => Vector2(width * gameSize[0], b * gameSize[1]);

  @override
  void onCollision(List<Collision> collisions) {
    backward(this);
    x = (position[0] - offset[0]) / gameSize[0];
    logger.finer("Paddle backward.");
  }

  void moveRight() {
    // if (lastPosForBackward != null) { return; }
    lastPosForBackward = position;
    x += MyHomePage.paddleStep;
    // rn.inc(step);
    logger.finer("move Right. x = $x");
  }

  void moveLeft() {
    // if (lastPosForBackward != null) { return; }
    lastPosForBackward = position;
    x -= MyHomePage.paddleStep;
    // rn.dec(step);
    logger.finer("move Left. x = $x");
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
