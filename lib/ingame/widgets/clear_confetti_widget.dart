// lib/ingame/widgets/clear_confetti_widget.dart

import 'dart:math';
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

    // 원하는 고정 크기
    const double outerRadius = 10;  // ⭐ 별 크기 (여기 값을 키우면 별 자체가 커짐)
    const double innerRadius = outerRadius * 0.45;

    const int points = 5;
    const double fullAngle = 2 * pi;
    final double step = fullAngle / (points * 2);

    double angle = -pi / 2;

    path.moveTo(
      outerRadius * cos(angle) + outerRadius,
      outerRadius * sin(angle) + outerRadius,
    );

    for (int i = 1; i < points * 2; i++) {
      angle += step;
      final bool isOuter = i.isEven;

      final double radius = isOuter ? outerRadius : innerRadius;
      path.lineTo(
        outerRadius + radius * cos(angle),
        outerRadius + radius * sin(angle),
      );
    }

    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      // 필요하면 Alignment.center 로 바꿔서 화면 중앙에서 쏠 수도 있음
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        emissionFrequency: 0.05,
        numberOfParticles: 15,
        maxBlastForce: 50,
        minBlastForce: 2,
        gravity: 0.1,
        createParticlePath: _drawStar, // ⭐ 별 모양 파티클
      ),
    );
  }
}
