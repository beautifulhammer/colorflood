import 'package:flutter/material.dart';

/// Color Flood의 컬러 보드 위젯
///
/// - [board]: 색 인덱스가 들어 있는 2차원 배열 [row][col]
/// - [colors]: 인덱스에 대응하는 실제 Color 리스트
///
/// 셀 사이의 **모든 1픽셀 선/틈이 느껴지지 않도록** 구성:
/// - GridView 대신 CustomPaint로 직접 사각형을 그림
/// - 보드 크기를 `size * cellSize` 꼴의 정수 단위로 맞춰 서브픽셀 방지
/// - 각 셀은 서로 **살짝 겹치게** 그려서 경계에 미세한 틈이 생길 여지를 없앰
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
        // 화면에서 쓸 수 있는 정사각형 영역의 최대 길이
        final double maxSide = constraints.biggest.shortestSide;

        // 한 칸의 크기를 "정수 픽셀"이 되도록 내림 처리
        // 예: maxSide = 327.8, size = 7 → cellSize = floor(46.8) = 46
        final double cellSize = (maxSide / size).floorToDouble().clamp(1.0, double.infinity);

        // 실제 보드가 차지할 전체 길이: 정수 픽셀 단위
        final double boardSide = cellSize * size;

        return Center(
          child: SizedBox(
            width: boardSide,
            height: boardSide,
            child: CustomPaint(
              painter: _GameBoardPainter(
                board: board,
                colors: colors,
                cellSize: cellSize,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 실제 보드를 그리는 CustomPainter
class _GameBoardPainter extends CustomPainter {
  final List<List<int>> board;
  final List<Color> colors;
  final double cellSize;

  _GameBoardPainter({
    required this.board,
    required this.colors,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final int rows = board.length;
    if (rows == 0) return;
    final int cols = board[0].length;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final int colorIndex = board[r][c];
        final Color tileColor = (colorIndex >= 0 && colorIndex < colors.length)
            ? colors[colorIndex]
            : Colors.black;

        paint.color = tileColor;

        // 셀의 좌측 상단 좌표
        final double left = c * cellSize;
        final double top = r * cellSize;

        // 🔥 핵심 포인트:
        // - 폭/높이에 +0.5 정도 덧붙여서 인접 셀과 살짝 겹치게 그림
        //   → 부동 소수점 연산 때문에 생길 수 있는 1픽셀 틈까지 덮어버림
        final Rect rect = Rect.fromLTWH(
          left,
          top,
          cellSize + 0.5,
          cellSize + 0.5,
        );

        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GameBoardPainter oldDelegate) {
    // 보드 상태가 바뀔 때마다 항상 다시 그리도록 true
    return true;
  }
}
