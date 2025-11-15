// lib/l10n/l10n.dart

import 'package:flutter/foundation.dart';
import 'l10n_strings.dart';

/// Color Flood 앱용 간단 로컬라이제이션 헬퍼
///
/// 사용 예시:
/// ```dart
/// final lang = 'en'; // 기본 언어는 영어
/// Text(AppL10n.get('start', lang));
/// ```
class AppL10n {
  AppL10n._();

  /// 지원 언어 코드 목록
  ///
  /// - ko : 한국어
  /// - en : 영어
  /// - zh : 중국어 간체
  static const List<String> supportedLanguages = ['ko', 'en', 'zh'];

  /// 기본 언어 (fallback) - 요구사항대로 영어
  static const String defaultLanguage = 'en';

  /// 키와 언어코드로 번역 문자열을 가져옵니다.
  ///
  /// - [key] : 문자열 키 (예: 'start', 'moves_left')
  /// - [languageCode] : 언어 코드 (예: 'ko', 'en', 'zh')
  ///
  /// 동작 순서:
  /// 1) languageCode가 지원되지 않으면 defaultLanguage('en') 사용
  /// 2) 해당 언어의 번역이 없으면 defaultLanguage('en')로 fallback
  /// 3) 그래도 없으면 key 자체를 반환
  static String get(String key, String languageCode) {
    final lang = supportedLanguages.contains(languageCode)
        ? languageCode
        : defaultLanguage;

    final mapForKey = localizedValues[key];
    if (mapForKey == null) {
      if (kDebugMode) {
        // 개발 중 누락된 키를 찾기 쉽도록 (실서비스에서는 비활성 권장)
        // ignore: avoid_print
        print('AppL10n: missing key "$key"');
      }
      return key;
    }

    // 1차: 요청한 언어
    final value = mapForKey[lang];
    if (value != null && value.isNotEmpty) return value;

    // 2차: 기본 언어(en) fallback
    final fallback = mapForKey[defaultLanguage];
    if (fallback != null && fallback.isNotEmpty) return fallback;

    // 3차: 그래도 없으면 key 반환
    return key;
  }
}
