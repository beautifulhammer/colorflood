// lib/data/gold_indicator.dart

import 'package:flutter/material.dart';

Widget buildGoldIndicator({
  required int gold,
  bool isRefreshing = false,
  double iconSize = 20,
  TextStyle? textStyle,
  VoidCallback? onTapPlus,
}) {
  const Color _dark = Color(0xFF232323);
  const Color _ivory = Color(0xFFFFF8EA);

  // ✅ 외부에서 textStyle을 주더라도, '색상만'은 항상 _dark로 강제
  // (HomeScreen에서 흰색 스타일을 넘겨도 여기서 덮어씀)
  final baseTextStyle = textStyle ??
      const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
      );

  final effectiveTextStyle = baseTextStyle.copyWith(color: _dark);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: _ivory,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ gold.png 유지
        Image.asset(
          'assets/image/gold.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),

        const SizedBox(width: 8),

        // ✅ 숫자 (네모 박스 없음)
        Text(
          _formatGold(gold),
          style: effectiveTextStyle,
        ),

        if (isRefreshing) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_dark),
            ),
          ),
        ],

        const SizedBox(width: 10),

        // ✅ [+] 버튼 (미니멀 톤)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTapPlus,
            borderRadius: BorderRadius.circular(10),
            splashColor: _dark.withOpacity(0.08),
            highlightColor: _dark.withOpacity(0.05),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: _dark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                size: 16,
                color: _ivory,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// 12345 → 12,345
String _formatGold(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
      buf.write(',');
    }
  }
  return buf.toString();
}