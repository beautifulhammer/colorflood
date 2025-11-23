import 'package:flutter/material.dart';

/// 하단 색상 버튼 6개를 세로로 나란히 배치하는 위젯
/// [onColorSelected] 로 어떤 색 인덱스를 선택했는지 콜백
class ColorButtonsRow extends StatelessWidget {
  final List<Color> colors;
  final ValueChanged<int> onColorSelected;

  const ColorButtonsRow({
    super.key,
    required this.colors,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(colors.length, (index) {
        final color = colors[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: GestureDetector(
            onTap: () => onColorSelected(index),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
