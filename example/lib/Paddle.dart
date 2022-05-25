import 'package:example/MyHomePage.dart';
import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'Ball.dart';
import 'Wall.dart';
import 'WallBase.dart';
import 'Backwardable.dart';
import 'package:illume/illume.dart';

class PaddleO extends WallBaseO with Backwardable {
  late final double step;
  late final double width;
  late final RangeNum rn;
  static const wallGapRatio = MyHomePage.ballSize / 2;
  late final double wallGap;
  double _x = 0;
  @override
  double get x => _x;
  late final _dx;
  double get dx => _dx;
  late final double _y;
  @override
  double get y => _y;
  /*
  final _offset = Vector2(0, 0);
  @override
  Vector2 get offset => _offset;
  */
  @override
  Vector2 getOffset() {
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
  void init() {
    super.init();
    // _offset[0] = super.offset[0];
    final diff =
        (MyHomePage.wpGap + MyHomePage.wallT / 2 + b / 2) * gameSize[1];
    _y = pos == wallPos.top
        ? WallBaseO.topOffset(gameSize) + diff
        : WallBaseO.bottomOffset(gameSize) - diff;
    _x = gameSize[0] / 2;
    _dx = MyHomePage.paddleStep * gameSize[0];
  }

  @override
  void update(Duration delta) {
    super.update(delta);
    // x = rn.d + offset[0];
    position[0] = x;
    logger.finer("Paddle.x = $x; position[0]= ${position[0]}");
  }

  @override
  Color getColor() => Colors.yellow;

  @override
  Vector2 getRect() => Vector2(width * gameSize[0], b * gameSize[1]);

  @override
  void onCollision(List<Collision> collisions) {
    final col = collisions[0];
    if (col is WallO) {
      backward(this);
      _x = lastPosForBackward[0];
      logger.finer("Paddle backward with Wall.");
    }
  }

  void moveRight() {
    // if (lastPosForBackward != null) { return; }
    lastPosForBackward = position;
    _x += dx;
    // rn.inc(step);
    logger.finer("move Right. x = $x");
  }

  void moveLeft() {
    // if (lastPosForBackward != null) { return; }
    lastPosForBackward = position;
    _x -= dx;
    // rn.dec(step);
    logger.finer("move Left. x = $x");
  }
}

class EnemyPaddleO extends PaddleO {
  final BallO ball;
  EnemyPaddleO(super.pos, super.width, super.step, this.ball);
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
