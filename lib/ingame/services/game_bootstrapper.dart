// lib/ingame/services/game_bootstrapper.dart

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/game_data_loader.dart';
import '../../data/palette_model.dart';
import '../../data/stage_model.dart';
import '../../data/user_data.dart';
import '../../data/user_data_repository.dart';
import '../../data/stage_retry_repository.dart';
import '../logic/board_utils.dart';

/// 인게임 진입(또는 재시작/다음 스테이지) 시 필요한 모든 데이터를 한 번에 준비해주는 서비스
///
/// 책임:
/// - FirebaseAuth currentUser 확인 → uid 확보
/// - users/{uid} 로드/생성
/// - 스테이지 입장 처리(stageStats retryCount 증가 등)
/// - GameDataLoader.loadAll() → stage/palette 로드
/// - 보드 생성 + remainingMoves 세팅
///
/// 컨트롤러는 이 결과를 받아서 state만 갱신하면 됨.
class GameBootstrapper {
  final FirebaseAuth _auth;
  final UserDataRepository _userRepo;
  final StageRetryRepository _stageRetryRepo;
  final Random _random;

  GameBootstrapper({
    FirebaseAuth? auth,
    UserDataRepository? userRepo,
    StageRetryRepository? stageRetryRepo,
    Random? random,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _userRepo = userRepo ?? UserDataRepository.instance,
        _stageRetryRepo = stageRetryRepo ?? StageRetryRepository.instance,
        _random = random ?? Random();

  /// stageNum으로 게임 세션을 준비
  ///
  /// 검토 포인트(중요):
  /// - 유저가 로그인(익명 포함)되어 있지 않으면 예외
  /// - userData는 “없으면 생성” 로직으로 항상 확보
  /// - stageStart(retryCount)는 “스테이지에 들어갈 때” 정확히 한 번 호출되도록
  /// - palette.colors가 비어있으면 보드 생성 불가 → 예외로 처리
  Future<GameBootstrapResult> bootstrap({
    required int stageNum,
    String defaultLanguageCode = 'en',
  }) async {
    // 1) uid 확인
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not signed in.');
    }
    final uid = user.uid;

    // 2) 유저 데이터 로드/생성
    final userData = await _userRepo.loadOrCreateUser(
      uid: uid,
      defaultLanguageCode: defaultLanguageCode,
    );

    // 3) 스테이지 입장 처리(재도전 카운트 증가 등)
    //    - “스테이지 시작 시점”을 여기로 고정하면 추적이 쉬워짐
    await _stageRetryRepo.onStageStart(
      uid: uid,
      stageNum: stageNum,
    );

    // 4) 로컬 게임 데이터 로드 (캐싱되어 있으면 내부에서 skip되도록 하는 게 이상적)
    await GameDataLoader.loadAll();

    // 5) 스테이지 로드
    final stage = GameDataLoader.getStage(stageNum);
    if (stage == null) {
      throw Exception('Stage not found: $stageNum');
    }

    // 6) 팔레트 로드
    final palette = GameDataLoader.getPalette(stage.paletteId);
    if (palette == null) {
      throw Exception('Palette not found: ${stage.paletteId}');
    }

    // 7) 팔레트 색상 검증 (비어있으면 보드 생성 불가)
    final int colorCount = palette.colors.length;
    if (colorCount <= 0) {
      throw Exception('Palette has no colors: ${stage.paletteId}');
    }

    // 8) 보드 생성
    final board = BoardUtils.generateRandomBoard(
      size: stage.boardSize,
      colorCount: colorCount,
      random: _random,
    );

    // 9) 남은 횟수 초기값
    final remainingMoves = stage.maxMoves;

    return GameBootstrapResult(
      uid: uid,
      stage: stage,
      palette: palette,
      userData: userData,
      board: board,
      remainingMoves: remainingMoves,
    );
  }
}

/// bootstrap 결과 모델
@immutable
class GameBootstrapResult {
  final String uid;
  final StageData stage;
  final Palette palette;
  final UserData userData;
  final List<List<int>> board;
  final int remainingMoves;

  const GameBootstrapResult({
    required this.uid,
    required this.stage,
    required this.palette,
    required this.userData,
    required this.board,
    required this.remainingMoves,
  });
}
