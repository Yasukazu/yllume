import 'dart:collection';

import 'package:example/Ball.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'Wall.dart';
import 'WallBase.dart';
import 'pongPage.dart';
import 'ballchaser.dart';
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
  final Map<wallPos, WallO> pos2wall;
  PaddleO(this.pos, this.widthRatio, this.stepRatio, this.pos2wall) {
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

  RightLeft? _lastCollisionMove;

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
        logger.finer("offset moveBy ${moveLen}");
        _lastCollisionMove = RightLeft.right;
      } else {
        offset.moveBy(-moveLen);
        logger.finer("offset moveBy ${-moveLen}");
        _lastCollisionMove = RightLeft.left;
      }
      position = Vector2(x, y);
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
    position = Vector2(x, y);
    logger.finer("move Right. x = $x");
  }

  void moveLeft() {
    if (offset.isLeftLimit) {
      return;
    }
    // if (lastPosForBackward != null) { return; }
    lastPosForBackward = position;
    offset.dec(step);
    position = Vector2(x, y);
    logger.finer("move Left. x = $x");
  }
}

class EnemyPaddleO extends PaddleO {
  final BallChaser ballChaser; // List<DeltaPosition> Function() getBallPoss;
  EnemyPaddleO(this.ballChaser, super.pos, super.width, super.step, super.pos2wall);

  @override
  void update(Duration delta) {
    // final ballIsApproaching = ballChaser.ballIsApproaching();
    // if (ballIsApproaching != null && ballIsApproaching) {
      Vector2 calculatedPos = ballChaser.calculatedPos;
      if (calculatedPos != Vector2.zero()) {
        logger.finest(
            "Estimated ball position: (${calculatedPos[0]}, ${calculatedPos[1]}).");
        final posDiff = x - calculatedPos[0];
        if (posDiff > size[0] / 2) {
          moveLeft();
          logger.finer("Enemy paddle moveLeft by $posDiff");
        } else if (posDiff < -size[0] / 2){
          moveRight();
          logger.finer("Enemy paddle moveRight by $posDiff");
        }
      }
    if (commandPacket != null) {
      final command = commandPacket as CommandPacket;
      if (command.count > 0) {
        if (command.direction == RightLeft.right) {
          moveRight();
        } else if (command.direction == RightLeft.left) {
          moveLeft();
        }
        command.count--;
        logger.finest(
            "EnemyPaddle ${command.direction} command made count: ${command.count}.");
      }
    }
  }

  CommandPacket? commandPacket;
  late RightLeft _direction;

  @override
  void moveRight() {
    super.moveRight();
    _direction = RightLeft.right;
  }

  @override
  void moveLeft() {
    super.moveLeft();
    _direction = RightLeft.left;
  }

  void move() {
    if (_direction == RightLeft.right) {
      moveRight();
    } else if (_direction == RightLeft.left) {
      moveLeft();
    } else {
      throw Exception("_direction is not set when move() is called!");
    }
  }

  @override
  void center() {
    super.center();
    estimatedBallPos = null;
  }

  Vector2? estimatedBallPos;

  @override
  void onCollision(List<Collision> collisions) {
    super.onCollision(collisions);
    estimatedBallPos = null;
  }
}

enum RightLeft { right, left }

class CommandPacket {
  final RightLeft direction;
  int count;
  CommandPacket(this.direction, this.count);
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
