// lib/data/stage_retry_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 스테이지별 재도전 횟수를 관리하는 리포지토리
///
/// 경로 예시:
/// users/{uid}/stageStats/{stageNum}
/// - retryCount : 해당 스테이지에서 몇 번 "재시작" 되었는지 (첫 입장은 0)
/// - stageNum   : 스테이지 번호 (검색용)
/// - updatedAt  : 마지막 갱신 시각
class StageRetryRepository {
  StageRetryRepository._();

  static final StageRetryRepository instance = StageRetryRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _stageCollection(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('stageStats');
  }

  /// 스테이지에 "입장"할 때 호출.
  ///
  /// - 해당 유저가 이 스테이지를 처음 시작하는 경우:
  ///   - retryCount = 0 으로 문서를 생성 (첫 시도는 재도전이 아니므로)
  /// - 이미 한번이라도 시도한 적이 있는 경우:
  ///   - retryCount 를 +1 증가
  ///
  /// 반환값: 증가 이후의 retryCount (첫 입장은 0)
  Future<int> onStageStart({
    required String uid,
    required int stageNum,
  }) async {
    final docRef = _stageCollection(uid).doc(stageNum.toString());

    return _firestore.runTransaction<int>((tx) async {
      final snapshot = await tx.get(docRef);

      if (!snapshot.exists) {
        // ✅ 이 스테이지를 "처음" 시작하는 경우: 재도전이 아니므로 0으로 생성
        tx.set(
          docRef,
          <String, dynamic>{
            'retryCount': 0,
            'stageNum': stageNum,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return 0;
      } else {
        // ✅ 이미 한 번 이상 시도한 적이 있다 → 이번 입장은 '재도전'
        final data = snapshot.data() ?? <String, dynamic>{};
        final current = (data['retryCount'] as num?)?.toInt() ?? 0;
        final newRetryCount = current + 1;

        tx.update(docRef, <String, dynamic>{
          'retryCount': newRetryCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return newRetryCount;
      }
    });
  }

  /// 현재 저장된 retryCount 만 읽고 싶을 때 사용
  Future<int?> getRetryCount({
    required String uid,
    required int stageNum,
  }) async {
    final docRef = _stageCollection(uid).doc(stageNum.toString());
    final snapshot = await docRef.get();

    if (!snapshot.exists) return null;

    final data = snapshot.data() ?? <String, dynamic>{};
    return (data['retryCount'] as num?)?.toInt();
  }
}
