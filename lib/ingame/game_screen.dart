// lib/ingame/game_screen.dart

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // 🎉 confetti 패키지

import '../data/game_data_loader.dart';
import '../data/palette_model.dart';
import '../data/stage_model.dart';
import '../data/gold_reward_table.dart';
import '../data/user_data.dart';
import '../data/user_data_repository.dart';
import '../data/stage_retry_repository.dart'; // ✅ 스테이지 재도전 리포지토리
import '../data/gold_indicator.dart'; // ✅ 골드 표시 공용 함수
import 'widgets/game_board.dart';
import 'widgets/color_buttons_row.dart';
import 'result/clear_result_overlay.dart';
import 'result/game_over_result_overlay.dart';
import 'logic/board_utils.dart';
import 'widgets/clear_confetti_widget.dart'; // ✅ 클리어 파티클 위젯 분리

enum GameResultState {
  none,
  clear,
  gameOver,
}

/// 실제 인게임 화면
/// - stageNum 을 받아 해당 스테이지 정보를 로드
/// - 팔레트 + 난이도 + boardSize 정보를 기반으로 보드를 그림
/// - 게임 종료 시 전면 결과 팝업(성공/실패)을 오버레이로 표시
/// - 스테이지 클리어 시 난이도에 따른 골드 보상 지급 (Firestore 저장)
/// - 완료한 최고 스테이지, 골드, 언어코드는 Firestore users/{uid} 문서에 저장
/// - 동일 스테이지 재시작 횟수는 users/{uid}/stageStats/{stageNum}.retryCount 에 저장
class GameScreen extends StatefulWidget {
  final int stageNum;

  const GameScreen({
    super.key,
    required this.stageNum,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  /// 클리어 팝업 표시 전 딜레이 (사용자 요청: 200ms)
  static const Duration _clearDelay = Duration(milliseconds: 200);

  bool _isLoading = true;
  String? _errorMessage;

  StageData? _stage;
  Palette? _palette;

  late List<List<int>> _board; // [row][col] 색 인덱스
  int _remainingMoves = 0;

  GameResultState _resultState = GameResultState.none;

  /// 클리어 결과를 보여주기 전, 잠깐 대기 중인지 여부
  bool _isResultPending = false;

  /// 이번 스테이지에서 획득한 골드 (클리어 시에만 사용)
  int _earnedGold = 0;

  /// Firestore 에서 로드한 유저 데이터
  UserData? _userData;

  final Random _random = Random();
  final _userRepo = UserDataRepository.instance;
  final _stageRetryRepo = StageRetryRepository.instance; // ✅ 재도전 카운트 리포지토리

  /// 🎉 클리어 시 사용할 컨페티 컨트롤러
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _initGame(initialStageNum: widget.stageNum);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// 스테이지 / 팔레트 / 유저 데이터 로딩 및 초기화
  Future<void> _initGame({int? initialStageNum}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resultState = GameResultState.none;
      _earnedGold = 0;
      _isResultPending = false;
    });

    try {
      // FirebaseAuth 에서 현재 유저 uid 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not signed in.');
      }
      final uid = user.uid;

      // 유저 데이터 Firestore 에서 로드 (없으면 생성)
      final userData = await _userRepo.loadOrCreateUser(
        uid: uid,
        defaultLanguageCode: 'en',
      );

      // 스테이지 번호 확정
      final int stageNum =
          initialStageNum ?? _stage?.stageNum ?? widget.stageNum;

      // ✅ 스테이지 입장 → 재도전 카운트 처리
      await _stageRetryRepo.onStageStart(
        uid: uid,
        stageNum: stageNum,
      );

      // 스테이지 / 팔레트 데이터 로딩
      await GameDataLoader.loadAll();

      final stage = GameDataLoader.getStage(stageNum);
      if (stage == null) {
        throw Exception('Stage not found: $stageNum');
      }

      final palette = GameDataLoader.getPalette(stage.paletteId);
      if (palette == null) {
        throw Exception('Palette not found: ${stage.paletteId}');
      }

      _stage = stage;
      _palette = palette;
      _userData = userData;
      _remainingMoves = stage.maxMoves;

      _board = BoardUtils.generateRandomBoard(
        size: stage.boardSize,
        colorCount: palette.colors.length,
        random: _random,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// 색상 버튼을 눌렀을 때 Flood Fill 로직
  void _onColorSelected(int newColorIndex) {
    if (_palette == null || _stage == null) return;
    if (_remainingMoves <= 0) return;
    if (_resultState != GameResultState.none) return;
    if (_isResultPending) return;

    final size = _board.length;
    if (size == 0) return;

    final currentColor = _board[0][0];
    if (currentColor == newColorIndex) {
      return;
    }

    setState(() {
      _remainingMoves--;
    });

    BoardUtils.floodFill(
      board: _board,
      row: 0,
      col: 0,
      targetColor: currentColor,
      newColor: newColorIndex,
    );

    // 클리어 체크
    if (BoardUtils.isAllSameColor(_board)) {
      setState(() {
        _isResultPending = true;
      });

      Future.delayed(_clearDelay, () {
        if (!mounted) return;
        if (_resultState != GameResultState.none) return;
        if (!_isResultPending) return;

        _handleClear();
      });

      return;
    }

    // 게임오버 체크
    if (_remainingMoves <= 0) {
      _handleGameOver();
    }
  }

  /// 스테이지 클리어 처리
  Future<void> _handleClear() async {
    final stage = _stage;
    final userData = _userData;
    if (stage == null || userData == null) return;

    final difficulty = stage.difficulty;
    final reward = GoldRewardTable.getRewardByDifficulty(difficulty);

    try {
      final updated = await _userRepo.updateOnClear(
        current: userData,
        clearedStage: stage.stageNum,
        deltaGold: reward,
      );

      setState(() {
        _earnedGold = reward;
        _userData = updated;
        _resultState = GameResultState.clear;
        _isResultPending = false;
      });

      _confettiController.play();
    } catch (e) {
      setState(() {
        _errorMessage = '클리어 저장 중 오류 발생: $e';
        _resultState = GameResultState.none;
        _isResultPending = false;
      });
    }
  }

  /// 게임오버 처리 (골드 지급 없음)
  void _handleGameOver() {
    setState(() {
      _earnedGold = 0;
      _resultState = GameResultState.gameOver;
      _isResultPending = false;
    });
  }

  void _goToNextStage() {
    if (_stage == null) return;
    final nextStageNum = _stage!.stageNum + 1;
    _initGame(initialStageNum: nextStageNum);
  }

  void _retryStage() {
    if (_stage == null) return;
    _initGame(initialStageNum: _stage!.stageNum);
  }

  void _backToHome() {
    Navigator.of(context).pop();
  }

  /// 결과 팝업에서 [계속하기] 선택 시
  void _continueGame() {
    // TODO: 아이템 구매 / RV 연동 포인트 연결 예정
    setState(() {
      _resultState = GameResultState.none;
      _isResultPending = false;
    });
  }

  // -----------------------------
  // UI 빌더 헬퍼
  // -----------------------------

  PreferredSizeWidget? _buildAppBar(bool showAppBar) {
    if (!showAppBar) return null;
    return AppBar(
      backgroundColor: const Color(0xFF232323),
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }

  /// 상단 HUD: 스테이지 + 남은 카운트
  Widget _buildHeader(StageData stage) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Stage ${stage.stageNum}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_outlined, size: 20, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                '$_remainingMoves / ${stage.maxMoves}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(Palette palette) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: GameBoard(
          board: _board,
          colors: palette.colors,
        ),
      ),
    );
  }

  Widget _buildColorButtons(Palette palette) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 120.0),
      child: ColorButtonsRow(
        colors: palette.colors,
        onColorSelected: _onColorSelected,
      ),
    );
  }

  Widget? _buildResultOverlay(StageData stage) {
    if (_resultState == GameResultState.clear) {
      return ClearResultOverlay(
        stageNum: stage.stageNum,
        maxMoves: stage.maxMoves,
        remainingMoves: _remainingMoves,
        earnedGold: _earnedGold,
        onNextStage: _goToNextStage,
        onRetry: _retryStage,
      );
    } else if (_resultState == GameResultState.gameOver) {
      return GameOverResultOverlay(
        stageNum: stage.stageNum,
        maxMoves: stage.maxMoves,
        remainingMoves: _remainingMoves,
        onHome: _backToHome,
        onRetry: _retryStage,
        onContinue: _continueGame,
      );
    }
    return null;
  }

  /// AppBar 아래, 게임 스크린 안으로 옮긴 상단 버튼들 (홈 / 설정 / 재시작)
  Widget _buildTopButtons() {
    return Positioned(
      top: 4,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 홈 버튼
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: _backToHome,
          ),
          // 설정 + 재시작
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () {
                  // TODO: 설정 팝업 (언어 변경 등)
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _retryStage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ⭐ 홈 버튼 아래에 띄우는 골드 표시 오버레이
  Widget _buildGoldIndicatorOverlay() {
    if (_userData == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 46, // 홈 버튼 바로 아래
      left: 16,
      child: buildGoldIndicator(
        gold: _userData!.gold,
        iconSize: 22,
        // 인게임에서는 로딩 스피너 없음 (isRefreshing 기본값 false)
      ),
    );
  }

  // -----------------------------
  // build
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF232323),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Text('데이터 로딩 중 오류 발생:\n$_errorMessage'),
        ),
      );
    }

    final stage = _stage!;
    final palette = _palette!;

    final resultOverlay = _buildResultOverlay(stage);
    final bool showAppBar = _resultState == GameResultState.none;

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: _buildAppBar(showAppBar),
      body: SafeArea(
        child: Stack(
          children: [
            // 실제 게임 내용
            Column(
              children: [
                _buildHeader(stage),
                _buildBoard(palette),
                _buildColorButtons(palette),
              ],
            ),

            // 상단 버튼들
            _buildTopButtons(),

            // 홈 버튼 아래 골드 표시
            _buildGoldIndicatorOverlay(),

            // 전면 결과 팝업 오버레이
            if (resultOverlay != null) resultOverlay,

            // 🎉 중앙에서 터지는 별 모양 컨페티
            ClearConfettiWidget(
              controller: _confettiController,
            ),
          ],
        ),
      ),
    );
  }
}
