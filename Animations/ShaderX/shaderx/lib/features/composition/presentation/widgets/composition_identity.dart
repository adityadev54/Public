import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

abstract final class CompositionIdentity {
  static const icons = {
    'layers': ('Layers', HeroiconsOutline.square3Stack3d),
    'wave': ('Wave', HeroiconsOutline.signal),
    'prism': ('Prism', HeroiconsOutline.cubeTransparent),
    'leaf': ('Botany', HeroiconsOutline.bugAnt),
    'orbit': ('Orbit', HeroiconsOutline.sun),
    'contours': ('Contours', HeroiconsOutline.fingerPrint),
  };
  static const colors = [
    ('Chartreuse', 0xFFAAB85A),
    ('Amber', 0xFFD7A758),
    ('Copper', 0xFFC88463),
    ('Rose', 0xFFC98090),
    ('Lilac', 0xFFA69BC4),
    ('Stone', 0xFF9C9B8D),
  ];
  static IconData icon(String id) => (icons[id] ?? icons['layers']!).$2;
  static Color foreground(Color color) =>
      color.computeLuminance() > .35 ? const Color(0xFF272820) : Colors.white;
}
