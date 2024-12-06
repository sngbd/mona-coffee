import 'package:flutter/material.dart';

class Sizer {
  static late Size _size;
  static late double screenWidth;
  static late double screenHeight;
  static double? defaultSize;

  void init(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    screenWidth = _size.width;
    screenHeight = _size.height;
  }
}
