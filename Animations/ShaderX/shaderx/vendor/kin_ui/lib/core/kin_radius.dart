import 'package:flutter/widgets.dart';

/// Corner-radius constants and pre-built [BorderRadius] values.
abstract final class KinRadius {
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 26.0;
  static const double xl = 28.0;
  static const double pill = 999.0;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
