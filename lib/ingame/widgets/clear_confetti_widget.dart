// lib/ingame/widgets/clear_confetti_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

/// 스테이지 클리어 시 사용하는 별 모양 컨페티 위젯
/// - GameScreen 에서 ConfettiController 를 주입받아 사용
class ClearConfettiWidget extends StatelessWidget {
  final ConfettiController controller;

  const ClearConfettiWidget({
    super.key,
    required this.controller,
  });

  /// ⭐ 별 모양 파티클 Path
  ///
  /// - 중심을 기준으로 바깥 점(outer)과 안쪽 점(inner)을
  ///   번갈아 찍어서 5각별을 만든다.
  Path _drawStar(Size size) {
    final Path path = Path();

    // 별 크기 (조금 키워서 눈에 더 잘 띄게)
    const double outerRadius = 12.0;
    const double innerRadius = outerRadius * 0.45;

    const int points = 5;
    const double fullAngle = 2 * math.pi;
    final double step = fullAngle / (points * 2);

    double angle = -math.pi / 2;

    path.moveTo(
      outerRadius * math.cos(angle) + outerRadius,
      outerRadius * math.sin(angle) + outerRadius,
    );

    for (int i = 1; i < points * 2; i++) {
      angle += step;
      final bool isOuter = i.isEven;

      final double radius = isOuter ? outerRadius : innerRadius;
      path.lineTo(
        outerRadius + radius * math.cos(angle),
        outerRadius + radius * math.sin(angle),
      );
    }

    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 화면 전체 캔버스 확보 + 상단 중앙에서 확실히 분사
    return SizedBox.expand(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: controller,

          // 상단에서 "아래 방향"으로 기본 방향을 잡아줌 (explosive라도 체감이 커짐)
          blastDirection: math.pi / 2,
          blastDirectionality: BlastDirectionality.explosive,

          shouldLoop: false,

          // 조금 더 확실히 보이도록 조정
          emissionFrequency: 0.06,
          numberOfParticles: 25,
          maxBlastForce: 35,
          minBlastForce: 8,
          gravity: 0.18,

          createParticlePath: _drawStar,
        ),
      ),
    );
  }
}
