// lib/data/player_gold_repository.dart

import 'package:shared_preferences/shared_preferences.dart';

/// 플레이어의 전체 보유 골드를 관리하는 리포지토리
///
/// - 앱 전체 공용으로 사용 (Static 메서드)
/// - 내부 저장은 SharedPreferences 사용
/// - 최초 값은 0골드
class PlayerGoldRepository {
  PlayerGoldRepository._();

  static const String _keyPlayerGold = 'player_gold';

  /// 현재 저장된 골드를 불러옴 (기본값 0)
  static Future<int> getGold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyPlayerGold) ?? 0;
  }

  /// 골드를 특정 값으로 설정
  static Future<void> setGold(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPlayerGold, value);
  }

  /// 골드를 delta 만큼 증감하고, 변경된 최종 값을 반환
  ///
  /// - delta > 0 : 골드 증가
  /// - delta < 0 : 골드 감소 (0 아래로는 내려가지 않도록 처리)
  static Future<int> addGold(int delta) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyPlayerGold) ?? 0;
    final next = (current + delta).clamp(0, 1 << 31); // 음수 방지
    await prefs.setInt(_keyPlayerGold, next);
    return next;
  }
}
