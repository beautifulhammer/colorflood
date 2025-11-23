import 'package:flutter/material.dart';

/// Color Flood 보드 그리기 전용 위젯
/// [board] 는 [row][col] 형식의 2차원 배열, 값은 색 인덱스(0~5)
/// [colors] 는 팔레트에서 가져온 6개의 Color 리스트
class GameBoard extends StatelessWidget {
  final List<List<int>> board;
  final List<Color> colors;

  const GameBoard({
    super.key,
    required this.board,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final int size = board.length;
    if (size == 0) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 1.0, // 정사각형 보드
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
        ),
        itemCount: size * size,
        itemBuilder: (context, index) {
          final row = index ~/ size;
          final col = index % size;
          final colorIndex = board[row][col].clamp(0, colors.length - 1);
          final cellColor = colors[colorIndex];

          return Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(2.0),
            ),
          );
        },
      ),
    );
  }
}
