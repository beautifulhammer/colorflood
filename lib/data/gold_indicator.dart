// lib/data/gold_indicator.dart

import 'package:flutter/material.dart';

/// 골드 표시 공용 위젯 빌더
///
/// - gold: 현재 골드 수치
/// - isRefreshing: true 이면 오른쪽에 작은 로딩 인디케이터 표시
/// - iconSize: 골드 아이콘 크기
/// - textStyle: 숫자 텍스트 스타일 (null 이면 기본 흰색 bold 16)
Widget buildGoldIndicator({
  required int gold,
  bool isRefreshing = false,
  double iconSize = 20,
  TextStyle? textStyle,
}) {
  final effectiveTextStyle = textStyle ??
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/image/gold.png',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      ),
      const SizedBox(width: 6),
      Text(
        '$gold',
        style: effectiveTextStyle,
      ),
      if (isRefreshing) ...[
        const SizedBox(width: 8),
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    ],
  );
}
