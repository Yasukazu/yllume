import 'package:example/Ball.dart';
import 'package:example/orgMain.dart';
import 'package:flutter/material.dart';
import 'Wall.dart';
import 'WallBase.dart';
import 'pongPage.dart';
import 'Backwardable.dart';
import 'package:illume/illume.dart';
import 'dart:math';

class PaddleO extends GameObject with Backwardable {
  static const color = Colors.yellow;
  static const shape = BoxShape.rectangle;
  final double stepRatio;
  late final double widthRatio;
  late final RangeNum offset;
  late final double xCenter;
  static const wallGapRatio = PongGamePage.ballSize / 2;
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

  static const b = PongGamePage.paddleT;

  @override
  void init() {
    // _offset[0] = super.offset[0];
    final diff =
        (PongGamePage.wpGap + PongGamePage.wallT / 2 + b / 2) * gameSize[1];
    _y = pos == wallPos.top
        ? WallBaseO.topOffset(gameSize)[1] + diff
        : WallBaseO.bottomOffset(gameSize)[1] - diff;
    _step = stepRatio * gameSize[0];
    offset = RangeNum(
        (1 - widthRatio - 2 * PongGamePage.wallT - 2 * PongGamePage.wpGap) *
            gameSize[0]);
    xCenter = gameSize[0] / 2;
    position = Vector2(x, y);
    size =
        Vector2(widthRatio * gameSize[0], PongGamePage.paddleT * gameSize[1]);
    wallGap = PongGamePage.wpGap * gameSize[0];
  }

  void center() {
    offset.center();
  }

  @override
  void update(Duration delta) {
    // x = offset.d + offset[0];
    // position[0] = x; position[1] = y;
    position = Vector2(x, y);
    logger.finest("Paddle.x = $x; position[0]= ${position[0]}");
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
  // Vector2 ballPos = Vector2.zero();
  Vector2 lastBallPos = Vector2.zero();
  final List<DeltaPosition> Function() peekBallPos;
  EnemyPaddleO(super.pos, super.width, super.step, this.peekBallPos) {}


  @override
  void update(Duration delta) {
    if (ballDPs.length < 2) {
      ballDPs = peekBallPos();
    }
    if (ballDPs.length < 2) {
      return;
    }
    final ballDy = ballDPs[1].position[1] - ballDPs[0].position[1];
    if (ballDy >= 0) {
      return;
    }
    final landingPos = calcLandingPos(ballDPs, delta);
    // TODO: set proper dx
    final lastBallX = ballDPs[1].position[0];
    final ballDx = ballDPs[1].position[0] - ballDPs[0].position[0];
    // final ballDt = ballDPs[1].delta - ballDPs[0].delta;
    // final ballXspeed = ballDx / ballDt.inMilliseconds;
    // final past = delta - ballDPs[1].delta;
    final landingDy = gameSize[1] - ballDPs[1].position[1];
    final landingCycle = landingDy / ballDy;
    // final landingTime = ballDt * landingCycle - past;
    final landingDx = lastBallX + ballDx * landingCycle;
    var cdx = 0.0;
    if (landingDx.abs() > gameSize[1]) {
      final fold = landingDx.abs() - gameSize[1];
      cdx = landingDx + ((landingDx >= 0) ? -fold : fold) - x;
    } else {
      cdx = landingDx - x;
    }
    if (cdx != 0.0) {
      offset.moveBy(cdx);
      position = Vector2(x, y);
      logger.finer("Paddle.x = $x; position[0]= ${position[0]}");
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

  void center() {
    _d = 0;
  }

  void inc(double step) {
    if ((_d + step) <= range) {
      _d += step;
    } else {
      _d = halfRange;
    }
  }

  void dec(double step) {
    if ((_d - step) >= -halfRange) {
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
