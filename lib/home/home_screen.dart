import 'package:flutter/material.dart';

import '../data/user_data.dart';
import '../data/user_data_repository.dart';
import '../data/game_data_loader.dart';
import '../data/palette_model.dart';
import '../data/stage_model.dart';
import '../ingame/game_screen.dart';
import '../data/gold_indicator.dart'; // ✅ 골드 표시 공용 함수

/// Color Flood 메인 홈 화면
///
/// - (빈 AppBar: 노치 영역 확보용)
/// - body 상단: 골드 / 도감 / 도움말 / 설정 버튼
/// - 중앙: START 버튼 (다음 스테이지로 게임 시작)
/// - START 하단: 다음 스테이지에서 사용할 팔레트 미리보기
/// - 하단: 배너 광고 영역(플레이스홀더)
class HomeScreen extends StatefulWidget {
  final UserData userData;

  const HomeScreen({
    super.key,
    required this.userData,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserData _userData;
  bool _isRefreshing = false;

  /// 다음에 플레이할 스테이지의 팔레트 색상 목록 (6개)
  List<Color>? _nextPaletteColors;

  final _userRepo = UserDataRepository.instance;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;

    // 앱 실행 직후 서버 기준 최신값으로 한 번 동기화
    _refreshUserData();

    // 초기 상태에서도 팔레트 로딩 시도
    _loadNextStagePalette(_nextStageToPlay);
  }

  /// 서버 기준 유저 데이터 새로고침
  Future<void> _refreshUserData() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      final updated = await _userRepo.refresh(_userData.uid);
      setState(() {
        _userData = updated;
      });

      // 유저 데이터가 갱신되면, 다음 스테이지 팔레트도 다시 로드
      await _loadNextStagePalette(_nextStageToPlay);
    } catch (_) {
      // 에러는 조용히 무시 (오프라인 등)
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  /// 다음 스테이지 번호 계산
  /// - 클리어한 최고 스테이지가 0이면 → 1부터 시작
  int get _nextStageToPlay {
    final cleared = _userData.clearedStage;
    if (cleared <= 0) return 1;
    return cleared + 1;
  }

  /// 다음에 플레이할 스테이지의 팔레트 색상 불러오기
  Future<void> _loadNextStagePalette(int stageNum) async {
    try {
      await GameDataLoader.loadAll();

      final StageData? stage = GameDataLoader.getStage(stageNum);
      if (stage == null) {
        setState(() {
          _nextPaletteColors = null;
        });
        return;
      }

      final Palette? palette = GameDataLoader.getPalette(stage.paletteId);
      if (palette == null) {
        setState(() {
          _nextPaletteColors = null;
          return;
        });
      }

      setState(() {
        _nextPaletteColors = palette!.colors;
      });
    } catch (_) {
      setState(() {
        _nextPaletteColors = null;
      });
    }
  }

  Future<void> _onTapStart() async {
    final nextStage = _nextStageToPlay;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(stageNum: nextStage),
      ),
    );

    // 게임을 하고 돌아오면 유저 데이터 다시 갱신
    await _refreshUserData();
  }

  void _onTapPaletteBook() {
    // TODO: 팔레트 도감 팝업/페이지 열기
  }

  void _onTapHelp() {
    // TODO: 도움말 팝업 열기
  }

  void _onTapSettings() {
    // TODO: 설정 팝업 (언어 변경 + UserDataRepository.updateLanguage 등)
  }

  @override
  Widget build(BuildContext context) {
    final goldTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      // ✅ 빈 AppBar: 노치/상단 영역 확보용
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 골드 + 아이콘 영역
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 좌측: 골드 표시 (공용 함수 사용)
                  buildGoldIndicator(
                    gold: _userData.gold,
                    isRefreshing: _isRefreshing,
                    iconSize: 20,
                    textStyle: goldTextStyle,
                  ),

                  // 우측: 도감 / 도움말 / 설정 아이콘
                  Row(
                    children: [
                      IconButton(
                        onPressed: _onTapPaletteBook,
                        icon: const Icon(
                          Icons.palette_outlined,
                          color: Colors.white,
                        ),
                        tooltip: '팔레트 도감',
                      ),
                      IconButton(
                        onPressed: _onTapHelp,
                        icon: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                        ),
                        tooltip: '도움말',
                      ),
                      IconButton(
                        onPressed: _onTapSettings,
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                        ),
                        tooltip: '설정',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 180),

            // 중앙 컨텐츠
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // START 버튼
                    SizedBox(
                      width: 220,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _onTapStart,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'START',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'STAGE $_nextStageToPlay',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    // 팔레트 미리보기
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final color =
                            (_nextPaletteColors != null &&
                                index < _nextPaletteColors!.length)
                                ? _nextPaletteColors![index]
                                : Colors.grey.shade300;
                            return Container(
                              width: 40,
                              height: 40,
                              margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.black12,
                                  width: 0.5,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 하단 배너 영역 (플레이스홀더)
            Container(
              height: 56,
              width: double.infinity,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Text(
                'Banner Ad Area',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
