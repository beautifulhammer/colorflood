// lib/data/user_data.dart

/// Firebase Firestore 에 저장되는 유저 데이터 모델
///
/// 컬렉션: users
/// 문서 ID: FirebaseAuth 의 uid
///
/// 필드:
/// - clearedStage : 완료한 최고 스테이지 번호
/// - gold         : 보유 골드
/// - languageCode : 사용 언어 코드 (ex: 'en', 'ko', 'cn')
class UserData {
  final String uid;
  final int clearedStage;
  final int gold;
  final String languageCode;

  const UserData({
    required this.uid,
    required this.clearedStage,
    required this.gold,
    required this.languageCode,
  });

  /// 새 유저 기본값
  factory UserData.initial({
    required String uid,
    String languageCode = 'en',
  }) {
    return UserData(
      uid: uid,
      clearedStage: 0,
      gold: 0,
      languageCode: languageCode,
    );
  }

  /// Firestore 문서 → UserData
  factory UserData.fromMap(String uid, Map<String, dynamic> map) {
    return UserData(
      uid: uid,
      clearedStage: (map['clearedStage'] as num?)?.toInt() ?? 0,
      gold: (map['gold'] as num?)?.toInt() ?? 0,
      languageCode: map['languageCode'] as String? ?? 'en',
    );
  }

  /// UserData → Firestore 문서용 Map
  Map<String, dynamic> toMap() {
    return {
      'clearedStage': clearedStage,
      'gold': gold,
      'languageCode': languageCode,
    };
  }

  UserData copyWith({
    int? clearedStage,
    int? gold,
    String? languageCode,
  }) {
    return UserData(
      uid: uid,
      clearedStage: clearedStage ?? this.clearedStage,
      gold: gold ?? this.gold,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
