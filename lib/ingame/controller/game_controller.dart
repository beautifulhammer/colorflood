// lib/ingame/controller/game_controller.dart

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/game_data_loader.dart';
import '../../data/gold_reward_table.dart';
import '../../data/palette_model.dart';
import '../../data/stage_model.dart';
import '../../data/user_data.dart';
import '../../data/user_data_repository.dart';
import '../../data/stage_retry_repository.dart';
import '../logic/board_utils.dart';

/// 게임 결과 상태
enum GameResultState {
  none,
  clear,
  gameOver,
}

/// 화면에서 읽기 쉬운 “한 덩어리 상태”
///
/// ✅ 지금 단계에서는 game_state.dart로 분리하지 않고,
/// controller 파일 내부에 포함해서 작업 범위를 최소화함.
/// (나중에 상태가 더 커지거나 여러 화면에서 공유되면 분리 추천)
@immutable
class GameState {
  final bool isLoading;
  final String? errorMessage;

  final StageData? stage;
  final Palette? palette;

  /// 보드: [row][col] 색 인덱스
  final List<List<int>> board;

  final int remainingMoves;

  final GameResultState resultState;
  final bool isResultPending;
  final int earnedGold;

  final UserData? userData;

  const GameState({
    required this.isLoading,
    required this.errorMessage,
    required this.stage,
    required this.palette,
    required this.board,
    required this.remainingMoves,
    required this.resultState,
    required this.isResultPending,
    required this.earnedGold,
    required this.userData,
  });

  factory GameState.initial() {
    return const GameState(
      isLoading: true,
      errorMessage: null,
      stage: null,
      palette: null,
      board: <List<int>>[],
      remainingMoves: 0,
      resultState: GameResultState.none,
      isResultPending: false,
      earnedGold: 0,
      userData: null,
    );
  }

  GameState copyWith({
    bool? isLoading,
    String? errorMessage,
    StageData? stage,
    Palette? palette,
    List<List<int>>? board,
    int? remainingMoves,
    GameResultState? resultState,
    bool? isResultPending,
    int? earnedGold,
    UserData? userData,
    bool clearErrorMessage = false,
  }) {
    return GameState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      stage: stage ?? this.stage,
      palette: palette ?? this.palette,
      board: board ?? this.board,
      remainingMoves: remainingMoves ?? this.remainingMoves,
      resultState: resultState ?? this.resultState,
      isResultPending: isResultPending ?? this.isResultPending,
      earnedGold: earnedGold ?? this.earnedGold,
      userData: userData ?? this.userData,
    );
  }
}

/// GameScreen에서 로직을 분리한 컨트롤러
///
/// 책임:
/// - init(stageNum): 유저/스테이지/팔레트 로딩 + 보드 생성
/// - applyMove(colorIndex): flood fill + clear/gameOver 판정
/// - retry(), nextStage(), continueAfterGameOver()
/// - clear 시 Firestore 보상 반영
///
/// UI 책임(네비게이션/컨페티 재생)은 GameScreen에 남겨둠.
/// (이벤트/애니메이션은 화면에서 처리하는 게 리스크가 적음)
class GameController extends ChangeNotifier {
  /// 클리어 팝업 표시 전 딜레이 (사용자 요청: 200ms)
  static const Duration clearDelay = Duration(milliseconds: 200);

  final Random _random;
  final UserDataRepository _userRepo;
  final StageRetryRepository _stageRetryRepo;

  GameState _state = GameState.initial();
  GameState get state => _state;

  /// 외부에서 “클리어로 전환되는 순간”을 감지하기 위한 카운터
  /// - 화면에서 이 값 변화를 감지하면 confetti.play() 같은 연출 처리 가능
  int _clearSignal = 0;
  int get clearSignal => _clearSignal;

  GameController({
    Random? random,
    UserDataRepository? userRepo,
    StageRetryRepository? stageRetryRepo,
  })  : _random = random ?? Random(),
        _userRepo = userRepo ?? UserDataRepository.instance,
        _stageRetryRepo = stageRetryRepo ?? StageRetryRepository.instance;

  void _setState(GameState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 초기 로딩 + 보드 생성
  Future<void> init({required int stageNum, String defaultLanguageCode = 'en'}) async {
    _setState(
      _state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
        resultState: GameResultState.none,
        earnedGold: 0,
        isResultPending: false,
      ),
    );

    try {
      // 1) uid 확인
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not signed in.');
      }
      final uid = user.uid;

      // 2) 유저 데이터 로드/생성
      final userData = await _userRepo.loadOrCreateUser(
        uid: uid,
        defaultLanguageCode: defaultLanguageCode,
      );

      // 3) 스테이지 입장 처리(재도전 카운트 등)
      await _stageRetryRepo.onStageStart(
        uid: uid,
        stageNum: stageNum,
      );

      // 4) 스테이지/팔레트 로딩
      await GameDataLoader.loadAll();

      final stage = GameDataLoader.getStage(stageNum);
      if (stage == null) {
        throw Exception('Stage not found: $stageNum');
      }

      final palette = GameDataLoader.getPalette(stage.paletteId);
      if (palette == null) {
        throw Exception('Palette not found: ${stage.paletteId}');
      }

      // 5) 보드 생성
      final board = BoardUtils.generateRandomBoard(
        size: stage.boardSize,
        colorCount: palette.colors.length,
        random: _random,
      );

      _setState(
        _state.copyWith(
          isLoading: false,
          stage: stage,
          palette: palette,
          userData: userData,
          board: board,
          remainingMoves: stage.maxMoves,
          resultState: GameResultState.none,
          earnedGold: 0,
          isResultPending: false,
        ),
      );
    } catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// 색상 버튼 입력 처리
  void applyMove(int newColorIndex) {
    final stage = _state.stage;
    final palette = _state.palette;

    if (stage == null || palette == null) return;
    if (_state.isLoading) return;
    if (_state.resultState != GameResultState.none) return;
    if (_state.isResultPending) return;
    if (_state.remainingMoves <= 0) return;
    if (_state.board.isEmpty) return;

    final board = _cloneBoard(_state.board);

    final currentColor = board[0][0];
    if (currentColor == newColorIndex) return;

    // moves 감소
    final nextMoves = _state.remainingMoves - 1;

    // flood fill
    BoardUtils.floodFill(
      board: board,
      row: 0,
      col: 0,
      targetColor: currentColor,
      newColor: newColorIndex,
    );

    // 일단 보드+카운트 반영
    _setState(
      _state.copyWith(
        board: board,
        remainingMoves: nextMoves,
      ),
    );

    // 클리어 체크
    if (BoardUtils.isAllSameColor(board)) {
      _setState(_state.copyWith(isResultPending: true));

      Future.delayed(clearDelay, () async {
        // 화면이 이미 dispose되어도 controller는 살아있을 수 있어서,
        // 여기서는 상태 기준으로만 방어.
        if (_state.resultState != GameResultState.none) return;
        if (!_state.isResultPending) return;

        await _handleClear();
      });

      return;
    }

    // 게임오버 체크
    if (nextMoves <= 0) {
      _handleGameOver();
    }
  }

  Future<void> _handleClear() async {
    final stage = _state.stage;
    final userData = _state.userData;
    if (stage == null || userData == null) return;

    final reward = GoldRewardTable.getRewardByDifficulty(stage.difficulty);

    try {
      final updated = await _userRepo.updateOnClear(
        current: userData,
        clearedStage: stage.stageNum,
        deltaGold: reward,
      );

      // clear로 전환 “순간” 신호(화면에서 confetti 트리거용)
      _clearSignal++;

      _setState(
        _state.copyWith(
          earnedGold: reward,
          userData: updated,
          resultState: GameResultState.clear,
          isResultPending: false,
        ),
      );
    } catch (e) {
      _setState(
        _state.copyWith(
          errorMessage: '클리어 저장 중 오류 발생: $e',
          resultState: GameResultState.none,
          isResultPending: false,
        ),
      );
    }
  }

  void _handleGameOver() {
    _setState(
      _state.copyWith(
        earnedGold: 0,
        resultState: GameResultState.gameOver,
        isResultPending: false,
      ),
    );
  }

  /// 현재 스테이지 재시작
  Future<void> retry() async {
    final stage = _state.stage;
    if (stage == null) return;
    await init(stageNum: stage.stageNum);
  }

  /// 다음 스테이지로 진행
  Future<void> nextStage() async {
    final stage = _state.stage;
    if (stage == null) return;
    await init(stageNum: stage.stageNum + 1);
  }

  /// 게임오버 오버레이에서 “계속하기” 눌렀을 때(추후 RV/아이템 연결 포인트)
  void continueAfterGameOver() {
    _setState(
      _state.copyWith(
        resultState: GameResultState.none,
        isResultPending: false,
        earnedGold: 0,
      ),
    );
  }

  List<List<int>> _cloneBoard(List<List<int>> src) {
    return List<List<int>>.generate(
      src.length,
          (r) => List<int>.from(src[r]),
      growable: false,
    );
  }
}
