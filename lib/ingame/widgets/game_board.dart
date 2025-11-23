import 'package:flutter/material.dart';

/// Color Flood의 컬러 보드 위젯
///
/// - [board]: 색 인덱스가 들어 있는 2차원 배열 [row][col]
/// - [colors]: 인덱스에 대응하는 실제 Color 리스트
///
/// 셀 사이에 **틈(간격)이 전혀 없도록** 구성:
/// - GridView의 mainAxisSpacing / crossAxisSpacing = 0
/// - 셀 Container에 margin 없음
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
    if (board.isEmpty) {
      return const SizedBox.shrink();
    }

    final int size = board.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 가로/세로 중 더 짧은 쪽을 기준으로 정사각형 보드 생성
        final double boardSize =
            constraints.biggest.shortestSide; // 폭/높이 중 작은 값

        return Center(
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: size,
                mainAxisSpacing: 0, // ✅ 가로 간격 0
                crossAxisSpacing: 0, // ✅ 세로 간격 0
                childAspectRatio: 1, // 정사각형 유지
              ),
              itemCount: size * size,
              itemBuilder: (context, index) {
                final row = index ~/ size;
                final col = index % size;
                final colorIndex = board[row][col];

                final Color tileColor = (colorIndex >= 0 &&
                    colorIndex < colors.length)
                    ? colors[colorIndex]
                    : Colors.black;

                return Container(
                  // ✅ margin / padding 없이 바로 색만 채우기
                  color: tileColor,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
