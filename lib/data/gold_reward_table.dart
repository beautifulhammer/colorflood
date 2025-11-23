// lib/data/gold_reward_table.dart

/// 스테이지 난이도에 따른 골드 보상 테이블
///
/// difficulty 문자열은 stage_data.json 의 값과 동일하게 사용:
/// - "very_easy"
/// - "easy"
/// - "normal"
/// - "moderate"
/// - "hard"
/// - "extreme"
class GoldRewardTable {
  GoldRewardTable._();

  /// 난이도 문자열을 받아 해당 난이도의 기본 골드 보상을 반환
  ///
  /// 정의:
  /// - very_easy : +1골드
  /// - easy      : +1골드
  /// - normal    : +2골드
  /// - moderate  : +3골드
  /// - hard      : +4골드
  /// - extreme   : +6골드
  ///
  /// 정의되지 않은 난이도면 0 반환
  static int getRewardByDifficulty(String difficulty) {
    switch (difficulty) {
      case 'very_easy':
        return 1;
      case 'easy':
        return 1;
      case 'normal':
        return 2;
      case 'moderate':
        return 3;
      case 'hard':
        return 4;
      case 'extreme':
        return 6;
      default:
      // 예외적인 경우: 잘못된 난이도 문자열이면 0골드
        return 0;
    }
  }
}
