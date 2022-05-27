import 'package:example/MyHomePage.dart';
import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'Ball.dart';
import 'Wall.dart';
import 'WallBase.dart';
import 'Backwardable.dart';
import 'package:illume/illume.dart';

class PaddleO extends GameObject with Backwardable {
  static const color = Colors.yellow;
  static const shape = BoxShape.rectangle;
  late final double step;
  late final double width;
  late final RangeNum rn;
  static const wallGapRatio = MyHomePage.ballSize / 2;
  late final double wallGap;
  double _x = 0;
  double get x => _x;
  late final double _dx;
  double get dx => _dx;
  late final double _y;
  final wallPos pos;

  PaddleO(this.pos, this.width, this.step) {
    assert(pos == wallPos.top || pos == wallPos.bottom);
    assert(width > 0 && width <= 1);
    assert(step > 0 && step <= 1);
  }

  static const b = MyHomePage.paddleT;
  late final RangeNum range;

  @override
  void init() {
    // _offset[0] = super.offset[0];
    final diff =
        (MyHomePage.wpGap + MyHomePage.wallT / 2 + b / 2) * gameSize[1];
    _y = pos == wallPos.top
        ? WallBaseO.topOffset(gameSize) + diff
        : WallBaseO.bottomOffset(gameSize) - diff;
    _x = gameSize[0] / 2;
    _dx = MyHomePage.paddleStep * gameSize[0];
    rn = RangeNum((1 - width) * gameSize[0]);
  }

  @override
  void update(Duration delta) {
    // x = rn.d + offset[0];
    position[0] = x;
    logger.finer("Paddle.x = $x; position[0]= ${position[0]}");
  }

  @override
  void onCollision(List<Collision> collisions) {
    final col = collisions[0];
    if (col is WallO) {
      backward(this);
      if (lastPosForBackward != null) {
        _x = (lastPosForBackward as Vector2)[0];
        logger.finer("Paddle backward with Wall.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        // Container( //alignment: Alignment(x, y), child:
        Stack(alignment: AlignmentDirectional.center, children: [
      Container(
        decoration: const BoxDecoration(shape: shape, color: color),
        // width: size[0],
        // height: size[1],
      ),
      Container(
        decoration: const BoxDecoration(shape: shape, color: Colors.black),
        width: 100,
        height: 100,
      ),
    ]);
  }

  @override
  void onScreenSizeChange(Vector2 size) {}

  void moveRight() {
    // if (lastPosForBackward != null) { return; }
    lastPosForBackward = position;
    rn.inc(dx);
    _x = rn.d;
    // rn.inc(step);
    logger.finer("move Right. x = $x");
  }

  void moveLeft() {
    // if (lastPosForBackward != null) { return; }
    lastPosForBackward = position;
    rn.dec(dx);
    _x = rn.d;
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
    } else {
      _d = range / 2;
    }
  }

  void dec(double step) {
    if ((_d - step) >= -range / 2) {
      _d -= step;
    } else {
      _d = -range / 2;
    }
  }
}
