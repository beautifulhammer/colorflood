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
  /// 각 버튼의 눌림 상태를 저장 (6개 색 버튼)
  final List<bool> _pressed = List.filled(6, false);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.colors.length, (index) {
        final color = widget.colors[index];

        return GestureDetector(
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
            scale: _pressed[index] ? 0.90 : 1.0,
            duration: const Duration(milliseconds: 70),
            curve: Curves.easeOut,

            child: Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey, width: 0.2),

                /// 그림자 그대로 유지
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),

              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
          ),
        );
      }),
    );
  }
}
