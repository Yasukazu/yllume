import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tuple/tuple.dart';
import 'orgMain.dart';
import 'MyHomePage.dart';
import 'package:illume/illume.dart';

class BallO extends GameObject {
  double xV = 0; // x velocity
  double yV = 0;
  late final double dx;
  double x = 0;
  late final double dy;
  double y = 0;
  final Color color;
  final double ratio;
  final BoxShape shape;
  late final BallPos ballPos;
  /// args: x, y, ratio, color, shape,
  BallO(this.dx, this.dy, [this.x = 0, this.y = 0, this.ratio = 0.1, this.color = Colors.white, this.shape = BoxShape.circle]) {
    ballPos = BallPos(dx, dy);
  }

  BallO.withAngleDivider(double angle, int divider, [this.ratio = 0.1, this.color = Colors.white, this.shape = BoxShape.circle])  {
    ballPos = BallPos.withAngleDivider(angle, divider);
    dx = ballPos.dx;
    dy = ballPos.dy;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height;
    return Container(
        alignment: Alignment(x, y),
        child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                decoration: BoxDecoration(shape: shape, color: color),
                width: ratio * size,
                height: ratio * size,
              ),
              Container(
                decoration: BoxDecoration(shape: shape, color: Colors.black),
                width: ratio * size * 0.5,
                height: ratio * size * 0.5,
              ),
            ])
    );
  }

  @override
  void init() {
    size = Vector2.all(ratio * gameSize[0]);
    alignment = GameObjectAlignment.center;
    position = Vector2(
      gameSize[0] * x,
      gameSize[1] * y,
    );
  }

  @override
  void onCollision(List<Collision> collisions) {
    // illumeController.stopGame();
  }

  @override
  void onScreenSizeChange(Vector2 size) {
    // This is a quick demo but you really should shift your positions in a
    // real world app or at least lock orientation.
  }

  @override
  void update(Duration delta) {
    final ox = ballPos.x;
    final oy = ballPos.y;
    StepResults stepResults = ballPos.step();
    final cx = ballPos.x;
    final cy = ballPos.y;
    final rDx = (ox - cx) / ballPos.sideToSide * gameSize[0];
    final rDy = (oy - cy) / ballPos.homeToAway * gameSize[1];
    position += Vector2(rDx, rDy);
  }
}


// x and y both keep between -1 and 1
class BallPos {
  double get x => bX.x;
  double get y => bY.x;
  double get dx => bX.d;
  double get dy => bY.d;
  double get toSide => bX.w; // side from home
  double get sideToSide => 2 * toSide;
  double get w => toSide; // side from home
  double get homeToAway => 2 * bY.w;
  double get toAway => bY.w; // home from center
  double get h => toAway; // home from center
  final Bouncer bX;
  final Bouncer bY;

  BallPos(double dx, double dy,
      {x = Bouncer.XDFLT,
      y = Bouncer.XDFLT,
      xf = Screen.sideToSide,
      yf = Screen.centerToPlayer})
      : bX = FullBouncer(dx, wall: xf, x: x),
        bY = FullBouncer(dy, wall: yf, x: y);

  // angle[radian] to Y axis
  BallPos.withAngleDivider(double angle, int divider, {xf = Screen.centerToSide, yf = Screen.centerToPlayer})
      : bY = FullBouncer(1 / divider, wall: yf),
        bX = FullBouncer(tan(angle) / divider, wall: xf);

  BallPos.withBouncers(Bouncer xB, Bouncer yB)
      : bY = yB,
        bX = xB;

  /// return: [x._neg, y._neg]
  StepResults step() {
    final x = bX.step();
    final y = bY.step();
    return StepResults(x, y);
  }

  /// jump to wall
  Tuple2<double, int> jumpDown() {
    BallPos vp = clone();
    // const limit = 65535;
    var n = 0;
    StepResults sr;
    do {
      sr = vp.step();
      ++n;
    } while (sr.y == stepResult.keep);
    // final x = bX.jumpCount();
    // final y = bY.jumpCount();
    // final n = min(x, y);
    // logger.info("$n steps jumpCount min.");
    // StepResults? sr;
    // for (int i = 0; i < n; ++i) sr = step();
    logger.info("jumpDown returns with count: $n");
    return Tuple2(vp.x, n);
  }

  double _calcBallLandingPos() {
    const k = 0.01;
    logger.fine("x: $x, y: $y, h: $h, w: $w, dx: $dx, dy: $dy");
    assert(y.abs() < k ||
        h / 2 - y.abs() < k); // Tolerate 5% ball Y position from top side.
    final w2 = w * 2;
    final h2 = h * 2;
    final x2 = x + w; // offset +w
    final ft = dx / dy * h2;
    final d = x2 - ft;
    logger.fine("x2: $x2, ft: $ft, d: $d");
    if (d >= 0 && d <= w2) {
      logger.fine("d(x2 + ft): $d");
      return d;
    }
    // double hd = (d < 0) ? h * (ft - x) / ft : h * (x + ft - w2) / ft;
    if (d < 0) {
      final ft2 = ft.abs() - x2;
      logger.fine("ft2: $ft2");
      return ft2;
    }
    final ft3 = x2 + ft.abs() - w2;
    final ft4 = w2 - ft3;
    logger.fine("ft4: $ft4");
    return ft4;
  }

  double calcBallLandingPos() {
    final r = _calcBallLandingPos() - w;
    logger.fine("r: $r");
    return r;
  }

  static arrivalXFromCenter(double ballAngle) => tan(ballAngle / 360 * 2 * pi);
}

extension Cloning on BallPos {
  BallPos clone() {
    return BallPos(dx, dy, x: x, y: y, xf: w, yf: h / 2);
  }
}

enum stepResult { toPlus, toMinus, keep }

class StepResults {
  final stepResult x;
  final stepResult y;
  StepResults(this.x, this.y);
}

abstract class Bouncer {
  set x(v);
  double get x;
  double get d;
  double get w;
  bool get neg;
  set neg(v);
  static const XDFLT = 0.0;
  static const WDFLT = 1.0;
  stepResult step();

  /// count how many steps to jump (about)
  int jumpCount() => neg ? x ~/ d : (w - x) ~/ d;

  /// jump until direction change
  int jump() {
    int n = 0;
    while (step() == stepResult.keep) ++n;
    return n;
  }
}

// between -wall and wall bouncing number
class FullBouncer extends Bouncer {
  double _x;
  //double _d;
  final double _e;
  bool _neg;
  final double wall;
  set x(v) => _x = v;
  double get x => _x;
  double get d => _neg ? -_e : _e;
  double get w => wall;
  bool get neg => _neg;
  set neg(v) => _neg = v;

  /// wall > 0
  FullBouncer(d, {x = Bouncer.XDFLT, wall = Bouncer.WDFLT})
      : this._e = d.abs(),
        _neg = d < 0,
        _x = x,
        this.wall = wall;

  /// return: bounced ? _neg : null
  stepResult step() {
    final a = _x + d;
    if (a < -wall) {
      _x = -a - 2 * wall;
      _neg = false;
      return stepResult.toPlus;
    } else if (a > wall) {
      _x = 2 * wall - a;
      _neg = true;
      return stepResult.toMinus;
    }
    _x = a;
    return stepResult.keep;
  }
}

// between 0 and wall bouncing number
class HalfBouncer extends Bouncer {
  double _x;
  //double _d;
  final double _e;
  bool _neg;
  final double wall;
  set x(v) => _x = v;
  double get x => _x;
  double get d => _neg ? -_e : _e;
  double get w => wall;
  bool get neg => _neg;
  set neg(v) => _neg = v;

  /// wall > 0
  HalfBouncer(d, {x = Bouncer.XDFLT, wall = Bouncer.WDFLT})
      : this._e = d.abs(),
        _neg = d < 0,
        _x = x,
        this.wall = wall;

  /// return: bounced ? _neg : null
  stepResult step() {
    final a = _x + d;
    if (a < 0) {
      _x = -a;
      _neg = false;
      return stepResult.toPlus;
    } else if (a > wall) {
      _x = 2 * wall - a;
      _neg = true;
      return stepResult.toMinus;
    }
    _x = a;
    return stepResult.keep;
  }
}

class RandAngleIterator extends Iterable with Iterator {
  final int range;
  final rand = new Random(new DateTime.now().millisecondsSinceEpoch);
  var _e = 0;
  var _s = false;
  int get v => (30 + _e) * (_s ? 1 : -1);

  RandAngleIterator(this.range) {
    _e = rand.nextInt(range);
    _s = rand.nextBool();
  }

  @override
  double get current => v / 180 * pi;

  @override
  bool moveNext() {
    _e = rand.nextInt(range);
    _s = rand.nextBool();
    return true;
  }

  @override
  Iterator get iterator => this;
}