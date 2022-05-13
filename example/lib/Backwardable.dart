import 'package:flutter/material.dart';
import 'dart:math';
import 'orgMain.dart'; // logger
import 'MyHomePage.dart'; // WallO
import 'WallBase.dart';
import 'package:illume/illume.dart';
import 'package:intl/intl.dart';

mixin Backwardable on GameObject {
  Vector2? lastPosForBackward;
  void backward(GameObject go) {
    if (lastPosForBackward != null) {
      go.position = lastPosForBackward as Vector2;
    }
  }
}
