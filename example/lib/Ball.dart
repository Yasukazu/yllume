import 'package:flutter/material.dart';
import 'dart:math';
import 'MyHomePage.dart'; // WallO
import 'package:illume/illume.dart';

class BallO extends GameObject {
  static const defaultBallSpeed = 1;
  static const initialX = 0.5;
  static const initialY = 0.5;
  final int _speed; // millisecond
  int get speed => _speed;
  late final double _dx;
  bool dxReverse = false;
  bool dyReverse = false;
  double get dx => dxReverse ? -_dx : _dx;
  double get dy => dyReverse ? -_dy : _dy;
  double get orgAngle => atan2(_dx, _dy);
    /// current position is x + dx * _stepCount
    double get x => curXY[0];
  double get y => curXY[1];
  late final double _dy;
    static const Color color = Colors.white;
    final double ratio; // self size
    static const BoxShape shape = BoxShape.circle;
    Vector2 get lastPos => Vector2(gameSize[0] * lastXY[0], gameSize[1] * lastXY[1]);
    set lastPos(Vector2 nxy) {
      final x_ = nxy[0] / gameSize[0];
      final y_ = nxy[1] / gameSize[1];
      lastXY = Vector2(x_, y_);
    }

    final _lastXY = Vector2(initialX, initialY);
    Vector2 get lastXY => _lastXY;
    set lastXY(Vector2 nxy) {
      final x_ = nxy[0];
      final y_ = nxy[1];
      assert(x_ >= 0 && x_ <= 1.0);
      assert(y_ >= 0 && y_ <= 1.0);
      _lastXY[0] = x_;
      _lastXY[1] = y_;
    }
    int _stepCount = 0;
    int get stepCount => _stepCount;
    Vector2 get curXY {
      final x_ = lastXY[0];
      final y_ = lastXY[1];
      final ndx = stepCount * dx;
      final ndy = stepCount * dy;
      return Vector2(x_ + ndx, y_ + ndy);
    }
    Vector2 get curPos {
      final x_ = curXY[0];
      final y_ = curXY[1];
      return Vector2(x_ * gameSize[0], y_ * gameSize[1]);
    }
      // late final BallPos ballPos;
      /// args: x, y, ratio, color, shape,
      BallO(this._dx, this._dy,
          [this._speed = defaultBallSpeed, this.ratio = MyHomePage.ballSize]) {
        assert(_dx > 0 && _dy > 0);
        assert(_speed > 0);
        assert(ratio > 0);
      }

      /// angle to Y-axis
      BallO.withAngle(this._speed, double rad, [this.ratio = MyHomePage.ballSize]) {
        _dx = cos(rad);
        _dy = sin(rad);
      }

      @override
      void init() {
        size = Vector2.all(ratio * gameSize[0]);
        alignment = GameObjectAlignment.center;
        position = curPos;
      }

      @override
      Widget build(BuildContext context) {
        final size = gameSize; // MediaQuery.of(context).size.height;
        return Container(
            alignment: Alignment(x, y), // (x * 2) - 1, (y * 2 ) - 1),
            child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    decoration: BoxDecoration(shape: shape, color: color),
                    width: ratio * size[0],
                    height: ratio * size[1],
                  ),
                  Container(
                    decoration: BoxDecoration(shape: shape, color: Colors.black),
                    width: ratio * size[0] * 0.5,
                    height: ratio * size[1] * 0.5,
                  ),
                ])
        );
      }

      // bool on1stCollision = true;
      @override
      void onCollision(List<Collision> collisions) {

      }

      @override
      void onScreenSizeChange(Vector2 size) {
        // This is a quick demo but you really should shift your positions in a
        // real world app or at least lock orientation.
      }

      final stepRatio = 0.015;
      bool update1st = true;
      @override
      void update(Duration delta) {
        forward();

      }

      void _step() {
        final nx = 1 + stepCount * dx * stepRatio;
        final rnx = lastPos[0] + (nx * gameSize[0]).round();
        final ny = 1 + stepCount * dy * stepRatio;
        final rny = lastPos[1] + (ny * gameSize[1]).round();
        position = Vector2(rnx, rny);
      }

      void forward() {
        ++_stepCount;
        _step();
      }

      void backward() {
        --_stepCount;
        _step();
      }

      void clearStepCount() {
        _stepCount = 0;
      }

      void updateLastPosWithPosition() {
        lastPos[0] = position[0];
        lastPos[1] = position[1];
      }
}