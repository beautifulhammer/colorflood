import 'package:flutter/material.dart';

/// 팔레트 한 개를 나타내는 모델
class Palette {
  final String id; // paletteId
  final Map<String, String> name; // 'ko', 'en', 'cn'
  final List<Color> colors; // 6개의 색상

  Palette({
    required this.id,
    required this.name,
    required this.colors,
  });

  factory Palette.fromJson(Map<String, dynamic> json) {
    final rawName = Map<String, dynamic>.from(json['paletteName'] as Map);
    // JSON은 en/ko/cn 구조라고 가정
    final Map<String, String> nameMap = {
      'ko': (rawName['ko'] ?? '').toString(),
      'en': (rawName['en'] ?? '').toString(),
      'cn': (rawName['cn'] ?? '').toString(),
    };

    final rawColors = Map<String, dynamic>.from(json['colorHex'] as Map);
    // "1" ~ "6" 키 순서대로 정렬해서 6개 색상 추출
    final List<String> keys = rawColors.keys.toList()..sort();
    final List<Color> colors = keys.map((k) {
      final value = rawColors[k]?.toString() ?? '000000';
      final normalized = _normalizeHex(value);
      return _toColor(normalized);
    }).toList();

    return Palette(
      id: json['paletteId'].toString(),
      name: nameMap,
      colors: colors,
    );
  }

  /// # 없이 들어온 6자리 HEX 문자열을 대문자로 정규화
  static String _normalizeHex(String hex) {
    var cleaned = hex.trim().replaceAll('#', '');
    if (cleaned.length == 3) {
      // 3자리라면 6자리로 확장 (예: F0A -> FF00AA)
      cleaned = cleaned.split('').map((c) => '$c$c').join();
    }
    if (cleaned.length != 6) {
      cleaned = '000000';
    }
    return cleaned.toUpperCase();
  }

  /// 6자리 HEX를 Flutter Color로 변환 (불투명)
  static Color _toColor(String hex6) {
    final int colorInt = int.parse('FF$hex6', radix: 16);
    return Color(colorInt);
  }
}
