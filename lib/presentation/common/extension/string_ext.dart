import 'dart:ui';

extension HexColorString on String {
  Color hexToColor() => Color(int.parse(replaceAll('#', '0xff')));
}
