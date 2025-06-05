import 'dart:math' as math;

import 'package:flutter/animation.dart';

class CubicEaseInCurve extends Curve {
  const CubicEaseInCurve();

  @override
  double transformInternal(double t) {
    return math.pow(t, 3).toDouble();
  }
}
