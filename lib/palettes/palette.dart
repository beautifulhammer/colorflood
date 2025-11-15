// lib/palettes/palette.dart
import 'dart:ui';
import 'color_hex.dart';

/// 팔레트 1개의 모델.
/// - id: paletteId
/// - name: paletteName
/// - colors: 6개의 색상(Color)
class Palette {
  final String id;
  final String name;
  /// index 0~5에 6개의 색상(Color) 저장
  final List<Color> colors;

  const Palette({
    required this.id,
    required this.name,
    required this.colors,
  }) : assert(colors.length == 6, 'Palette must have exactly 6 colors');

  /// JSON(v1) -> Palette
  /// {
  ///   "paletteId": "palette1",
  ///   "paletteName": "Light",
  ///   "colorHex": { "1":"FF0000", ... "6":"FFFF00" }
  /// }
  factory Palette.fromJson(Map<String, dynamic> json) {
    final id = (json['paletteId'] ?? '').toString();
    final name = (json['paletteName'] ?? '').toString();
    final colorHex = (json['colorHex'] ?? {}) as Map;

    // 키 "1"~"6" 순서 보장해 6개 추출
    final orderedKeys = ['1', '2', '3', '4', '5', '6'];
    final List<Color> parsed = orderedKeys.map((k) {
      final v = colorHex[k];
      return ColorHex.parse(v);
    }).toList();

    return Palette(id: id, name: name, colors: parsed);
  }

  /// Palette -> JSON(v1)
  Map<String, dynamic> toJson() {
    return {
      'paletteId': id,
      'paletteName': name,
      'colorHex': {
        '1': ColorHex.toHex6(colors[0]),
        '2': ColorHex.toHex6(colors[1]),
        '3': ColorHex.toHex6(colors[2]),
        '4': ColorHex.toHex6(colors[3]),
        '5': ColorHex.toHex6(colors[4]),
        '6': ColorHex.toHex6(colors[5]),
      }
    };
  }
}
