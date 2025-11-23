import 'package:flutter/material.dart';

/// 게임 오버 시 표시되는 전면 결과 오버레이
///
/// - 화면 전체 dim 처리
/// - 중앙에 텍스트 + 버튼만 배치 (카드 박스 없음)
/// - 실패 시에도 "화면 가리개" 느낌으로 전체를 덮음
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 상단 아이콘
              const Icon(
                Icons.close,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),

              // 타이틀
              const Text(
                '게임 오버', // TODO: l10n 적용
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // 서브 텍스트
              Text(
                '남은 횟수가 0이 되었어요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 32),

              // 스테이지 / 남은 횟수 정보
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InfoRow(
                    label: 'Stage',
                    value: '$stageNum',
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    label: 'Moves',
                    value: '$remainingMoves / $maxMoves',
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 버튼 3개: 홈, 재도전, 계속하기
              Column(
                children: [
                  // 홈으로
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onHome,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        '홈으로', // TODO: AppL10n.get('home_popup_title', lang) 등과 조합
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 재도전
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onRetry,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        '재도전', // TODO: AppL10n.get('game_result_button', lang)
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 계속하기 (아이템 구매 / RV 연동 포인트)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.deepOrangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        '계속하기', // TODO: AppL10n.get('game_over_button', lang)
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
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: valueStyle,
        ),
      ],
    );
  }
}
