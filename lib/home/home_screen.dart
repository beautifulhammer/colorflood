import 'package:flutter/material.dart';

import '../ingame/game_screen.dart';

/// Color Flood 홈 화면 UI 전용 위젯
/// - 현재는 기본 레이아웃 + START 버튼으로 인게임 진입만 구현
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 상단: 골드 표시 + 설정/도감/도움말 아이콘
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 좌측: 골드 표시 (더미 값)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 20,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '12345', // TODO: 실제 골드 값 연동 예정
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 우측: 설정, 도감, 도움말 아이콘
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: 설정 팝업 열기
                        },
                        icon: const Icon(Icons.settings_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: 팔레트 도감 팝업 열기
                        },
                        icon: const Icon(Icons.palette_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: 도움말 팝업 열기
                        },
                        icon: const Icon(Icons.help_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 중앙: 게임 타이틀 + START 버튼 + 팔레트 미리보기
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'COLOR FLOOD',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // START 버튼
                  SizedBox(
                    width: size.width * 0.6,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: SharedPreferences 에서 마지막 스테이지 불러오도록 개선
                        const nextStageNum = 1;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GameScreen(
                              stageNum: nextStageNum,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'START',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'STAGE 1', // TODO: 실제 다음 스테이지 번호로 교체
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 팔레트 미리보기 (임시 색상)
                  const Text(
                    'NEXT PALETTE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _PaletteColorBox(color: Colors.red),
                      _PaletteColorBox(color: Colors.green),
                      _PaletteColorBox(color: Colors.blue),
                      _PaletteColorBox(color: Colors.orange),
                      _PaletteColorBox(color: Colors.purple),
                      _PaletteColorBox(color: Colors.yellow),
                    ],
                  ),
                ],
              ),
            ),

            // 하단: 배너 광고 영역 (자리만 마련)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 56,
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
            ),
          ],
        ),
      ),
    );
  }
}

/// 팔레트 미리보기용 작은 색 네모 박스
class _PaletteColorBox extends StatelessWidget {
  final Color color;

  const _PaletteColorBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
