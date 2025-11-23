// lib/data/user_data_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_data.dart';

/// Firestore 의 users 컬렉션을 다루는 리포지토리
///
/// - 문서 경로: users/{uid}
/// - clearedStage / gold / languageCode 필드 관리
class UserDataRepository {
  UserDataRepository._();

  static final UserDataRepository instance = UserDataRepository._();

  static const String collectionPath = 'users';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionPath);

  /// 유저 문서를 읽어오고, 없으면 새로 생성
  ///
  /// - [defaultLanguageCode]: 유저 최초 생성 시 넣어줄 기본 언어 코드
  Future<UserData> loadOrCreateUser({
    required String uid,
    String defaultLanguageCode = 'en',
  }) async {
    final docRef = _collection.doc(uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() ?? {};
      return UserData.fromMap(uid, data);
    } else {
      final userData = UserData.initial(
        uid: uid,
        languageCode: defaultLanguageCode,
      );
      await docRef.set(userData.toMap(), SetOptions(merge: true));
      return userData;
    }
  }

  /// 스테이지 클리어 시 진행도 & 골드 갱신
  ///
  /// - clearedStage: 현재 클리어한 스테이지 번호
  /// - deltaGold   : 이번 클리어 보상 골드(+값만 사용)
  ///
  /// Firebase 콘솔에서 clearedStage / gold 값을 수정해도
  /// 다음 로딩 시 그 값을 그대로 가져오게 설계되어 있음.
  Future<UserData> updateOnClear({
    required UserData current,
    required int clearedStage,
    required int deltaGold,
  }) async {
    final uid = current.uid;

    // 더 높은 스테이지만 반영 (뒤로 가지 않게)
    final int newClearedStage =
    clearedStage > current.clearedStage ? clearedStage : current.clearedStage;

    final int newGold = current.gold + deltaGold;

    final docRef = _collection.doc(uid);
    await docRef.set(
      {
        'clearedStage': newClearedStage,
        'gold': newGold,
      },
      SetOptions(merge: true),
    );

    return current.copyWith(
      clearedStage: newClearedStage,
      gold: newGold,
    );
  }

  /// 언어 코드만 개별 갱신
  Future<void> updateLanguage({
    required String uid,
    required String languageCode,
  }) async {
    final docRef = _collection.doc(uid);
    await docRef.set(
      {
        'languageCode': languageCode,
      },
      SetOptions(merge: true),
    );
  }

  /// 서버 기준 최신 데이터를 다시 읽고 싶을 때 사용
  Future<UserData> refresh(String uid) async {
    final docRef = _collection.doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw StateError('User document not found for uid=$uid');
    }
    final data = snapshot.data() ?? {};
    return UserData.fromMap(uid, data);
  }
}
