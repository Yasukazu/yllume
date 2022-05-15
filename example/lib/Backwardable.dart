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
