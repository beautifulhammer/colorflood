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
  /// 각 버튼의 눌림 상태 (6개)
  final List<bool> _pressed = List.filled(6, false);

  /// 버튼 크기
  static const double _buttonSize = 46.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        // 버튼 개수
        final itemCount = widget.colors.length;

        // 버튼들 총 너비
        final totalButtonsWidth = itemCount * _buttonSize;

        // 버튼 사이 남는 공간 수 = itemCount + 1
        final gapCount = itemCount + 1;

        // 하나의 간격 값 계산
        final spacing = (totalWidth - totalButtonsWidth) / gapCount;

        // 최소값 보정 (너무 좁은 화면 대비)
        final gap = spacing.clamp(6.0, 40.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(itemCount, (index) {
            final color = widget.colors[index];
            final isPressed = _pressed[index];

            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? gap : gap / 2,
                right: index == itemCount - 1 ? gap : gap / 2,
              ),
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() => _pressed[index] = true);
                },
                onTapUp: (_) {
                  setState(() => _pressed[index] = false);
                },
                onTapCancel: () {
                  setState(() => _pressed[index] = false);
                },
                onTap: () {
                  widget.onColorSelected(index);
                },
                child: AnimatedScale(
                  scale: isPressed ? 0.90 : 1.0,
                  duration: const Duration(milliseconds: 70),
                  curve: Curves.easeOut,
                  child: Container(
                    width: _buttonSize,
                    height: _buttonSize,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
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
        );
      },
    );
  }
}
