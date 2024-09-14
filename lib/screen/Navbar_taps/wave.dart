import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

Widget _buildWave() {
  return WaveWidget(
    config: CustomConfig(
      gradients: [
        [Colors.blue, Colors.blueAccent],
        [Colors.lightBlueAccent, Colors.lightBlue],
      ],
      durations: [35000, 19440, 10800],
      heightPercentages: [0.20, 0.23, 0.25],
      blur: MaskFilter.blur(BlurStyle.solid, 10),
      gradientBegin: Alignment.bottomLeft,
      gradientEnd: Alignment.topRight,
    ),
    waveAmplitude: 0,
    size: Size(double.infinity, 150),
  );
}
