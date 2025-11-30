import 'package:flutter/material.dart';

/// 게임 클리어 시 표시되는 전면 결과 오버레이
///
/// - 화면 전체 dim 처리
/// - 요약 정보는 세로 중앙
/// - 재도전/다음 스테이지 버튼은 가로로 나란히 (너비 축소 + 크기 증가 + 여백 증가)
class ClearResultOverlay extends StatelessWidget {
  final int stageNum;
  final int maxMoves;
  final int remainingMoves;
  final int earnedGold;

  final VoidCallback onNextStage;
  final VoidCallback onRetry;

  const ClearResultOverlay({
    super.key,
    required this.stageNum,
    required this.maxMoves,
    required this.remainingMoves,
    required this.earnedGold,
    required this.onNextStage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ---------------------------
              // 상단: 아이콘 + 타이틀
              // ---------------------------
              const Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 16),

              const Text(
                '스테이지 클리어',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '모든 칸을 하나의 색으로 물들였어요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              // ---------------------------
              // 중앙 정보 (세로 정렬)
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
              const SizedBox(height: 12),

              Text(
                'Gold +$earnedGold',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent,
                ),
              ),

              const SizedBox(height: 60),

              // ---------------------------
              // 버튼 가로 정렬 (여백 증가 + 개별 사이즈 명시)
              // ---------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 여백 늘림
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 재도전 버튼 (좌측)
                    SizedBox(
                      width: 130, // 버튼 너비 ↓ (Expanded 제거)
                      child: OutlinedButton(
                        onPressed: onRetry,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20), // 버튼 높이 ↑
                          side: BorderSide(
                            color: Colors.white70,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          '재도전',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20), // 버튼 간 간격 증가

                    // 다음 스테이지 버튼 (우측)
                    SizedBox(
                      width: 130, // 동일한 너비
                      child: ElevatedButton(
                        onPressed: onNextStage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20), // 버튼 높이 ↑
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          '다음 스테이지',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
