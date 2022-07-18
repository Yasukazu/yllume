import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:illume/illume.dart';
import 'Ball.dart';
import 'WallBase.dart';
import 'Wall.dart';
import 'Paddle.dart';
import 'ballchaser.dart';
import 'motionline.dart';


class SpeedSlider extends StatelessWidget {

  double _value = 0.5;
  double _startValue = 0.0;
  double _endValue = 0.0;

  final void Function(double) changeSlider;
  final void Function(double) startSlider;
  final void Function(double) endSlider;

  SpeedSlider(this.changeSlider, this.startSlider, this.endSlider, [this._min = 0.0, this._value = 0.5, this._max = 1], {Key? key}) : super(key: key);

  /// as ratio min and max
  final double _min;
  final double _max;
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: <Widget>[
            // Center(child:Text("Speed：${_value}")),
            Slider(
              label: 'Ball Speed',
              min: _min,
              max: _max,
              value: _value,
              activeColor: Colors.orange,
              inactiveColor: Colors.blueAccent,
              // divisions: 10,
              onChanged: changeSlider,
              onChangeStart: startSlider,
              onChangeEnd: endSlider,
            )
          ],
        )
    );
  }
Speed