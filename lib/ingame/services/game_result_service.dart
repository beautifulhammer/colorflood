// lib/ingame/services/game_result_service.dart

import 'package:flutter/foundation.dart';

import '../../data/gold_reward_table.dart';
import '../../data/stage_model.dart';
import '../../data/user_data.dart';
import '../../data/user_data_repository.dart';

/// 클리어/보상/저장 관련 처리 서비스
///
/// 책임:
/// - 난이도 기반 골드 보상 계산
/// - Firestore 업데이트(updateOnClear) 수행
/// - 업데이트된 UserData와 earnedGold를 결과로 반환
class GameResultService {
  final UserDataRepository _userRepo;

  GameResultService({
    UserDataRepository? userRepo,
  }) : _userRepo = userRepo ?? UserDataRepository.instance;

  /// 스테이지 클리어 처리
  ///
  /// 검토 포인트(중요):
  /// - 보상은 GoldRewardTable을 단일 소스로 사용
  /// - Firestore 갱신은 updateOnClear() 한 경로로 통일
  /// - updateOnClear 내부에서 “clearedStage는 더 큰 값만 반영” 같은 보호 로직이 있으면
  ///   중복 클리어/역행 상황에서도 안전해짐
  Future<GameClearResult> onClear({
    required UserData currentUserData,
    required StageData stage,
  }) async {
    final earnedGold = GoldRewardTable.getRewardByDifficulty(stage.difficulty);

    final updated = await _userRepo.updateOnClear(
      current: currentUserData,
      clearedStage: stage.stageNum,
      deltaGold: earnedGold,
    );

    return GameClearResult(
      earnedGold: earnedGold,
      updatedUserData: updated,
    );
  }
}

@immutable
class GameClearResult {
  final int earnedGold;
  final UserData updatedUserData;

  const GameClearResult({
    required this.earnedGold,
    required this.updatedUserData,
  });
}
