// lib/ingame/game_screen.dart

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/game_data_loader.dart';
import '../data/palette_model.dart';
import '../data/stage_model.dart';
import '../data/gold_reward_table.dart';
import '../data/user_data.dart';
import '../data/user_data_repository.dart';
import 'widgets/game_board.dart';
import 'widgets/color_buttons_row.dart';
import 'result/clear_result_overlay.dart';
import 'result/game_over_result_overlay.dart';

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
  bool _isLoading = true;
  String? _errorMessage;

  StageData? _stage;
  Palette? _palette;

  late List<List<int>> _board; // [row][col] 색 인덱스
  int _remainingMoves = 0;

  GameResultState _resultState = GameResultState.none;

  /// 이번 스테이지에서 획득한 골드 (클리어 시에만 사용)
  int _earnedGold = 0;

  /// Firestore 에서 로드한 유저 데이터
  UserData? _userData;

  final Random _random = Random();

  final _userRepo = UserDataRepository.instance;

  @override
  void initState() {
    super.initState();
    _initGame(initialStageNum: widget.stageNum);
  }

  /// 스테이지 / 팔레트 / 유저 데이터 로딩 및 초기화
  Future<void> _initGame({int? initialStageNum}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resultState = GameResultState.none;
      _earnedGold = 0;
    });

    try {
      // FirebaseAuth 에서 현재 유저 uid 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not signed in.');
      }
      final uid = user.uid;

      // 유저 데이터 Firestore 에서 로드 (없으면 생성)
      // TODO: 실제 앱 설정에서 선택한 언어 코드로 defaultLanguageCode 넘겨주면 됨.
      final userData = await _userRepo.loadOrCreateUser(
        uid: uid,
        defaultLanguageCode: 'en',
      );

      // 스테이지 / 팔레트 데이터 로딩
      await GameDataLoader.loadAll();

      final int stageNum =
          initialStageNum ?? _stage?.stageNum ?? widget.stageNum;

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

      _generateBoard(stage.boardSize, palette.colors.length);

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

  /// 임시로 랜덤 보드 생성
  /// (나중에 실제 퍼즐 데이터/규칙 기반으로 교체 가능)
  void _generateBoard(int size, int colorCount) {
    _board = List.generate(
      size,
          (_) => List.generate(
        size,
            (_) => _random.nextInt(colorCount),
      ),
    );
  }

  /// 색상 버튼을 눌렀을 때 Flood Fill 로직
  void _onColorSelected(int newColorIndex) {
    if (_palette == null || _stage == null) return;
    if (_remainingMoves <= 0) return;
    if (_resultState != GameResultState.none) return;

    final size = _board.length;
    if (size == 0) return;

    final currentColor = _board[0][0];
    if (currentColor == newColorIndex) {
      // 같은 색을 다시 선택해도 아무 일도 일어나지 않음
      return;
    }

    setState(() {
      _remainingMoves--;
    });

    _floodFill(0, 0, currentColor, newColorIndex);

    // 클리어 체크
    if (_isAllSameColor()) {
      _handleClear(); // async (await 안 해도 됨)
      return;
    }

    // 게임오버 체크
    if (_remainingMoves <= 0) {
      _handleGameOver();
    }
  }

  /// DFS 방식 Flood Fill
  void _floodFill(
      int row,
      int col,
      int targetColor,
      int newColor,
      ) {
    final size = _board.length;
    if (row < 0 || row >= size || col < 0 || col >= size) return;
    if (_board[row][col] != targetColor) return;
    if (targetColor == newColor) return;

    _board[row][col] = newColor;

    _floodFill(row - 1, col, targetColor, newColor);
    _floodFill(row + 1, col, targetColor, newColor);
    _floodFill(row, col - 1, targetColor, newColor);
    _floodFill(row, col + 1, targetColor, newColor);
  }

  bool _isAllSameColor() {
    final size = _board.length;
    if (size == 0) return false;
    final color = _board[0][0];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (_board[r][c] != color) return false;
      }
    }
    return true;
  }

  /// 스테이지 클리어 처리
  /// - 난이도 기반 골드 보상 계산
  /// - Firestore users/{uid} 에 clearedStage / gold 반영
  /// - 이번 스테이지에서 획득한 골드는 _earnedGold 에 저장
  Future<void> _handleClear() async {
    final stage = _stage;
    final userData = _userData;
    if (stage == null || userData == null) return;

    // 난이도 기반 골드 보상 계산
    final difficulty = stage.difficulty; // stage_data.json 의 difficulty 값
    final reward = GoldRewardTable.getRewardByDifficulty(difficulty);

    try {
      // Firestore 에 진행도 + 골드 반영
      final updated = await _userRepo.updateOnClear(
        current: userData,
        clearedStage: stage.stageNum,
        deltaGold: reward,
      );

      setState(() {
        _earnedGold = reward; // 이번 스테이지에서 얻은 골드
        _userData = updated;  // 전체 유저 데이터 갱신
        _resultState = GameResultState.clear;
      });
    } catch (e) {
      // 만약 Firestore 업데이트가 실패하면, 결과 팝업 대신 에러 표시
      setState(() {
        _errorMessage = '클리어 저장 중 오류 발생: $e';
        _resultState = GameResultState.none;
      });
    }
  }

  /// 게임오버 처리 (골드 지급 없음)
  void _handleGameOver() {
    setState(() {
      _earnedGold = 0;
      _resultState = GameResultState.gameOver;
    });
  }

  /// 결과 팝업에서 [다음 스테이지] 선택 시
  void _goToNextStage() {
    if (_stage == null) return;
    final nextStageNum = _stage!.stageNum + 1;
    _initGame(initialStageNum: nextStageNum);
  }

  /// 결과 팝업에서 [재도전] 선택 시
  void _retryStage() {
    if (_stage == null) return;
    _initGame(initialStageNum: _stage!.stageNum);
  }

  /// 결과 팝업에서 [홈으로] 선택 시
  void _backToHome() {
    Navigator.of(context).pop();
  }

  /// 결과 팝업에서 [계속하기] 선택 시
  /// - 추후 아이템 구매 / RV 연동 포인트
  void _continueGame() {
    // TODO: 아이템 구매 팝업 또는 RV 시청 유도 팝업 연동
    setState(() {
      _resultState = GameResultState.none;
    });
  }

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
          title: const Text('Error'),
        ),
        body: Center(
          child: Text('데이터 로딩 중 오류 발생:\n$_errorMessage'),
        ),
      );
    }

    final stage = _stage!;
    final palette = _palette!;

    // 어떤 팝업을 띄울지 결정
    Widget? resultOverlay;
    if (_resultState == GameResultState.clear) {
      resultOverlay = ClearResultOverlay(
        stageNum: stage.stageNum,
        maxMoves: stage.maxMoves,
        remainingMoves: _remainingMoves,
        earnedGold: _earnedGold,
        onNextStage: _goToNextStage,
        onRetry: _retryStage,
      );
    } else if (_resultState == GameResultState.gameOver) {
      resultOverlay = GameOverResultOverlay(
        stageNum: stage.stageNum,
        maxMoves: stage.maxMoves,
        remainingMoves: _remainingMoves,
        onHome: _backToHome,
        onRetry: _retryStage,
        onContinue: _continueGame,
      );
    }

    // 결과 팝업이 떠 있을 때는 AppBar 숨기기 (전면 가리개 느낌)
    final bool showAppBar = _resultState == GameResultState.none;

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: showAppBar
          ? AppBar(
        backgroundColor: const Color(0xFF232323),
        title: Text(
            'Stage ${stage.stageNum}',
            style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 설정 팝업 (여기서 언어 변경 + UserDataRepository.updateLanguage 호출 가능)
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            onPressed: () {
              // TODO: 재시작 확인 팝업과 연동 (지금은 바로 재시작)
              _retryStage();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            // 실제 게임 내용
            Column(
              children: [
                // 상단 정보 영역: 스테이지 + 남은 카운트
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stage ${stage.stageNum}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.bolt_outlined, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '$_remainingMoves / ${stage.maxMoves}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 보드
                Expanded(
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
                ),

                const SizedBox(height: 12),

                // 색상 버튼 행
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: ColorButtonsRow(
                    colors: palette.colors,
                    onColorSelected: _onColorSelected,
                  ),
                ),
              ],
            ),

            // 전면 결과 팝업 오버레이 (성공/실패)
            if (resultOverlay != null) resultOverlay,
          ],
        ),
      ),
    );
  }
}
