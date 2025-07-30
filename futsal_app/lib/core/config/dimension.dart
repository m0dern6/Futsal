import 'dart:math';

import 'package:flutter/widgets.dart';

class Dimension {
  static late double deviceHeight;
  static late double deviceWidth;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    deviceHeight = size.height;
    deviceWidth = size.width;
  }

  // Use these methods to get responsive height and width
  static double height(double value) {
    // 812 is a common reference height (iPhone X)
    return (value / 812.0) * deviceHeight;
  }

  static double width(double value) {
    // 375 is a common reference width (iPhone X)
    return (value / 375.0) * deviceWidth;
  }

  // Responsive font size based on geometric mean of width and height
  static double fontSize(double value) {
    // 812 and 375 are reference height and width (iPhone X)
    double scale = sqrt((deviceHeight / 812.0) * (deviceWidth / 375.0));
    return value * scale;
  }
}
