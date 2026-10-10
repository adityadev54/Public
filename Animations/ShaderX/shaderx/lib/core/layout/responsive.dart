import 'package:flutter/material.dart';

abstract final class Responsive {
  static const phone = 600.0, desktop = 900.0;
  static double drawerRatio(double width) => width >= desktop
      ? .25
      : width >= phone
      ? .45
      : .75;
  static double drawerScale(double width) => width >= desktop
      ? .95
      : width >= phone
      ? .92
      : .88;
  static double drawerWidth(double width) => width >= desktop
      ? 320
      : width >= phone
      ? width * .43
      : width * .72;
  static int columns(double width) => width >= desktop
      ? 3
      : width >= phone
      ? 2
      : 1;
  static double gutter(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= phone ? 24 : 16;
}
