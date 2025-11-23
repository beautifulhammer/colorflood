import 'package:flutter/material.dart';

/// 게임 클리어 시 표시되는 전면 결과 오버레이
///
/// - 화면 전체 dim 처리
/// - 중앙에 텍스트 + 버튼만 배치 (카드 박스 없음)
/// - 배경 위에 반투명 가리개 + 정보/버튼이 직접 노출되는 느낌
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
              // 상단 아이콘
              const Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 16),

              // 타이틀
              const Text(
                '스테이지 클리어', // TODO: AppL10n.get('...', lang)
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
                '모든 칸을 하나의 색으로 물들였어요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 32),

              // 스테이지 / 남은 횟수 / 골드 정보
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
                  const SizedBox(height: 6),
                  _InfoRow(
                    label: 'Gold',
                    value: '+$earnedGold',
                    highlight: true,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 버튼 영역
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNextStage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        '다음 스테이지', // TODO: AppL10n.get('game_clear_button', lang)
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 결과 요약 표시용 한 줄 (클리어 전용)
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      fontSize: 18,
      fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
      color: highlight ? Colors.yellowAccent : Colors.white,
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
