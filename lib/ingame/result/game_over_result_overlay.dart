import 'package:flutter/material.dart';

/// 게임 오버 시 표시되는 전면 결과 오버레이
///
/// - 중앙 영역: Stage, Moves, 재도전/계속하기 버튼
/// - 그 아래 홈 아이콘 노출
/// - 전체는 화면 중앙에 자연스럽게 정렬
class GameOverResultOverlay extends StatelessWidget {
  final int stageNum;
  final int maxMoves;
  final int remainingMoves;

  final VoidCallback onHome;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  const GameOverResultOverlay({
    super.key,
    required this.stageNum,
    required this.maxMoves,
    required this.remainingMoves,
    required this.onHome,
    required this.onRetry,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------------------------
                // 상단 아이콘 + 타이틀
                // ---------------------------
                const Icon(
                  Icons.close,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),

                const Text(
                  '게임 오버',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  '남은 횟수가 0이 되었어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),

                // ---------------------------
                // 중앙 정보: Stage / Moves
                // ---------------------------
                Text(
                  'Stage $stageNum',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Moves $remainingMoves / $maxMoves',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 60),

                // ---------------------------
                // 버튼 가로 정렬
                // ---------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 재도전
                    SizedBox(
                      width: 130,
                      child: OutlinedButton(
                        onPressed: onRetry,
                        style: OutlinedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(vertical: 20), // 기억된 규칙
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          '재도전',
                          style: TextStyle(
                            fontSize: 16, // 기억된 규칙
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // 계속하기
                    SizedBox(
                      width: 130,
                      child: ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(vertical: 20), // 기억된 규칙
                          backgroundColor: Colors.deepOrangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          '계속하기',
                          style: TextStyle(
                            fontSize: 16, // 기억된 규칙
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ---------------------------
                // 버튼 아래 약간의 공간 + 홈 버튼
                // ---------------------------
                const SizedBox(height: 24),

                IconButton(
                  onPressed: onHome,
                  icon: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
