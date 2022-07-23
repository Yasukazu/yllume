import 'package:illume/illume.dart';

mixin Backwardable on GameObject {
  Vector2? lastPosForBackward;
  void backward(GameObject go) {
    if (lastPosForBackward != null) {
      go.position = lastPosForBackward as Vector2;
      lastPosForBackward = null;
    }
  }
}

mixin CollisionFront on GameObject {
  Vector2 get toFront => Vector2(0, size.y / 2); // for player paddle;override other class
  Vector2 get frontPosition => position - toFront;
}