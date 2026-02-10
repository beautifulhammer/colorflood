// lib/ingame/widgets/color_buttons_row.dart

import 'package:flutter/material.dart';

class ColorButtonsRow extends StatefulWidget {
  final List<Color> colors;
  final Function(int) onColorSelected;

  const ColorButtonsRow({
    super.key,
    required this.colors,
    required this.onColorSelected,
  });

  @override
  State<ColorButtonsRow> createState() => _ColorButtonsRowState();
}

class _ColorButtonsRowState extends State<ColorButtonsRow> {
  /// 각 버튼의 눌림 상태 (최대 6개 기준)
  final List<bool> _pressed = List.filled(6, false);

  /// 기본 버튼 크기
  static const double _baseButtonSize = 50.0;

  /// 버튼 최소 크기
  static const double _minButtonSize = 36.0;

  /// 버튼 간격 최소 / 최대
  static const double _minGap = 8.0;
  static const double _maxGap = 18.0;

  /// 좌우 안전 패딩
  static const double _horizontalPadding = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final itemCount = widget.colors.length.clamp(0, 6);

        if (itemCount == 0) {
          return const SizedBox.shrink();
        }

        // 좌우 패딩 제외한 실제 사용 가능 폭
        final usableWidth =
        (totalWidth - (_horizontalPadding * 2)).clamp(0.0, totalWidth);

        // 1️⃣ 버튼 크기 계산
        double buttonSize = _baseButtonSize;

        final neededAtBase =
            (itemCount * _baseButtonSize) + ((itemCount - 1) * _minGap);

        if (neededAtBase > usableWidth) {
          final availableForButtons =
              usableWidth - ((itemCount - 1) * _minGap);
          buttonSize =
              (availableForButtons / itemCount).clamp(_minButtonSize, _baseButtonSize);
        }

        // 2️⃣ 버튼 간격 계산 (min ~ max clamp)
        final totalButtonsWidth = itemCount * buttonSize;
        final remainingSpace = usableWidth - totalButtonsWidth;

        double gap = remainingSpace / (itemCount - 1);
        gap = gap.clamp(_minGap, _maxGap);

        // 실제 Row가 차지하는 너비
        final rowWidth =
            totalButtonsWidth + (gap * (itemCount - 1));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Center(
            child: SizedBox(
              width: rowWidth,
              child: Row(
                children: List.generate(itemCount, (index) {
                  final color = widget.colors[index];
                  final isPressed = _pressed[index];

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == itemCount - 1 ? 0 : gap,
                    ),
                    child: GestureDetector(
                      onTapDown: (_) =>
                          setState(() => _pressed[index] = true),
                      onTapUp: (_) =>
                          setState(() => _pressed[index] = false),
                      onTapCancel: () =>
                          setState(() => _pressed[index] = false),
                      onTap: () => widget.onColorSelected(index),
                      child: AnimatedScale(
                        scale: isPressed ? 0.90 : 1.0,
                        duration: const Duration(milliseconds: 70),
                        curve: Curves.easeOut,
                        child: Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: ShapeDecoration(
                            color: color,
                            shape: const CircleBorder(),
                            shadows: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
