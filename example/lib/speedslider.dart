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

  double value = 0.5;

  final void Function(double) startSlider;
  final void Function(double) setSlider;
  final void Function(double) endSlider;

  SpeedSlider(this.startSlider, this.setSlider, this.endSlider,
      {Key? key}
      )
      : super(key: key);

  /// as ratio min and max
  final double min = 0;
  final double max = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: <Widget>[
            // Center(child:Text("Speed：${_value}")),
            Slider(
              label: 'Ball Speed',
              min: min,
              max: max,
              value: value,
              // divisions: 10,
              onChanged: (value) {
                setState()
              },
              onChangeStart: startSlider,
              onChangeEnd: endSlider,
            )
          ],
        )
    );
  }
}