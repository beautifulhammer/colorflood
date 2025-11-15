// lib/palettes/color_hex.dart
import 'dart:ui';

/// 다양한 형태의 입력(문자열/정수/공백/소문자/#포함 등)을
/// 안전하게 Flutter Color(ARGB 0xFFRRGGBB)로 변환하는 유틸.
class ColorHex {
  /// 입력값 예시:
  /// - "ff0000", "FF0000", "#ff0000", " FF0000 ", 16711680(정수) 등
  /// 실패 시 fallback 반환(기본: Magenta)
  static Color parse(dynamic value, {Color fallback = const Color(0xFFFF00FF)}) {
    try {
      String hex;

      if (value == null) return fallback;

      if (value is int) {
        // 정수 → 16진수(대문자), 6자리 패딩
        hex = value.toRadixString(16).toUpperCase();
      } else {
        hex = value.toString().trim().toUpperCase();
      }

      // 앞의 # 제거
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      }

      // "0x" 접두 방어
      if (hex.startsWith('0X')) {
        hex = hex.substring(2);
      }

      // 16진수 이외 문자 제거(공백 포함)
      hex = hex.replaceAll(RegExp(r'[^0-9A-F]'), '');

      if (hex.isEmpty) return fallback;

      // 자리수 보정: 6자리 미만이면 왼쪽 0 패딩, 초과면 마지막 6자리 사용
      if (hex.length < 6) {
        hex = hex.padLeft(6, '0');
      } else if (hex.length > 6) {
        hex = hex.substring(hex.length - 6);
      }

      // 범위 클램프
      final intVal = int.parse(hex, radix: 16).clamp(0x000000, 0xFFFFFF);
      return Color(0xFF000000 | intVal);
    } catch (_) {
      return fallback;
    }
  }

  /// Color → "RRGGBB"(대문자) 문자열
  static String toHex6(Color color) {
    final rgb = color.value & 0x00FFFFFF;
    return rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
  }
}
