import 'package:example/MyHomePage.dart';
import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'Wall.dart';
import 'WallBase.dart';
import 'Backwardable.dart';
import 'package:illume/illume.dart';

class PaddleO extends GameObject with Backwardable {
  static const color = Colors.yellow;
  static const shape = BoxShape.rectangle;
  final double stepRatio;
  late final double widthRatio;
  late final RangeNum offset;
  late final double xCenter;
  static const wallGapRatio = MyHomePage.ballSize / 2;
  late final double wallGap;
  double get x => xCenter + offset.d;
  set x(double v) => offset.assign(v - xCenter);

  late final double _step;
  double get step => _step;
  late final double _y;
  double get y => _y;
  final wallPos pos;

  PaddleO(this.pos, this.widthRatio, this.stepRatio) {
    assert(pos == wallPos.top || pos == wallPos.bottom);
    assert(widthRatio > 0 && widthRatio <= 1);
    assert(stepRatio > 0 && stepRatio <= 1);
  }

  static const b = MyHomePage.paddleT;

  @override
  void init() {
    // _offset[0] = super.offset[0];
    final diff =
        (MyHomePage.wpGap + MyHomePage.wallT / 2 + b / 2) * gameSize[1];
    _y = pos == wallPos.top
        ? WallBaseO.topOffset(gameSize)[1] + diff
        : WallBaseO.bottomOffset(gameSize)[1] - diff;
    _step = stepRatio * gameSize[0];
    offset = RangeNum(
        (1 - widthRatio - 2 * MyHomePage.wallT - 2 * MyHomePage.wpGap) *
            gameSize[0]);
    xCenter = gameSize[0] / 2;
    position = Vector2(x, y);
    size = Vector2(widthRatio * gameSize[0], MyHomePage.paddleT * gameSize[1]);
    wallGap = MyHomePage.wpGap * gameSize[0];
  }

  @override
  void update(Duration delta) {
    // x = offset.d + offset[0];
    // position[0] = x; position[1] = y;
    position = Vector2(x, y);
    logger.finer("Paddle.x = $x; position[0]= ${position[0]}");
  }

  @override
  void onCollision(List<Collision> collisions) {
    WallO? wall;
    double lap = 0;
    for (Collision col in collisions) {
      if (col.component is WallO) {
        wall = col.component as WallO;
        lap = col.intersectionRect.width;
        break;
      }
    }
    if (wall != null) {
      final moveLen = lap.abs() + wallGap;
      if (wall.pos == wallPos.left) {
        offset.moveBy(moveLen);
        position = Vector2(x, y);
        logger.finer("offset moveBy ${moveLen}");
      } else {
        offset.moveBy(-moveLen);
        position = Vector2(x, y);
        logger.finer("offset moveBy ${-moveLen}");
      }
      /*
      backward(this);
      if (lastPosForBackward != null) {
        x = (lastPosForBackward as Vector2)[0];
        logger.finer("Paddle backward with Wall.");
      }
      */
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
        width: 10,
        height: 10,
      ),
    ]);
  }

  @override
  void onScreenSizeChange(Vector2 size) {}

  void moveRight() {
    if (offset.isRightLimit) {
      return;
    }
    // if (lastPosForBackward != null) { return; }
    lastPosForBackward = position;
    offset.inc(step);
    // offset.inc(step);
    logger.finer("move Right. x = $x");
  }

  void moveLeft() {
    if (offset.isLeftLimit) {
      return;
    }
    // if (lastPosForBackward != null) { return; }
    lastPosForBackward = position;
    offset.dec(step);
    logger.finer("move Left. x = $x");
  }
}

class EnemyPaddleO extends PaddleO {
  final Vector2 ballPos;
  final Vector2 lastBallPos = Vector2(0, 0);
  EnemyPaddleO(super.pos, super.width, super.step, this.ballPos) {
    lastBallPos[0] = ballPos[0];
    lastBallPos[1] = ballPos[1];
  }

  @override
  void update(Duration delta) {
    if (ballPos[0] == 0.0) {
      return;
    }
    if (lastBallPos[0] == 0.0) {
      lastBallPos[0] = ballPos[0];
      lastBallPos[1] = ballPos[1];
      return;
    }
    if (lastBallPos[0] != ballPos[0]) {
      final dx = ballPos[0] - lastBallPos[0];
      offset.moveBy(dx);
      position = Vector2(x, y);
      logger.finer("Paddle.x = $x; position[0]= ${position[0]}");
      lastBallPos[0] = ballPos[0];
      lastBallPos[1] = ballPos[1];
    }
  }
}

class RangeNum {
  double _d = 0;
  double get d => _d;
  final double range;
  late final double halfRange;
  bool get isLeftLimit => d == -halfRange;
  bool get isRightLimit => d == halfRange;

  RangeNum(this.range) {
    halfRange = range.abs() / 2;
  }

  void inc(double step) {
    if ((_d + step) <= range) {
      _d += step;
    } else {
      _d = halfRange;
    }
  }

  void dec(double step) {
    if ((_d - step) >= 0) {
      _d -= step;
    } else {
      _d = -halfRange;
    }
  }

  void assign(double v) {
    if (v < -halfRange) {
      _d = -halfRange;
    } else if (v > halfRange) {
      _d = halfRange;
    } else {
      _d = v;
    }
  }

  void moveBy(double dx) {
    final moved = d + dx;
    if (moved < -halfRange) {
      _d = -halfRange;
    } else if (moved > halfRange) {
      _d = halfRange;
    } else {
      _d = moved;
    }
  }
}
