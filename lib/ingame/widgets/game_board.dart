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
        final double cellSize =
        (maxSide / size).floorToDouble().clamp(1.0, double.infinity);

        // 실제 보드가 차지할 전체 길이: 정수 픽셀 단위
        final double boardSide = cellSize * size;

        // 테두리 설정
        const double _borderWidth = 2.0;
        const double _cornerRadius = 2.0;

        return Center(
          child: SizedBox(
            // CustomPaint의 size 자체가 "테두리 포함 전체 크기"가 되도록 확보
            width: boardSide + 2 * _borderWidth,
            height: boardSide + 2 * _borderWidth,
            child: CustomPaint(
              painter: _GameBoardPainter(
                board: board,
                colors: colors,
                cellSize: cellSize,
                borderWidth: _borderWidth,
                cornerRadius: _cornerRadius,
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
  final double borderWidth;
  final double cornerRadius;

  _GameBoardPainter({
    required this.board,
    required this.colors,
    required this.cellSize,
    required this.borderWidth,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int rows = board.length;
    if (rows == 0) return;
    final int cols = board[0].length;

    // 보드가 실제로 그려질 “테두리 안쪽 영역”
    final Rect innerRect = Rect.fromLTWH(
      borderWidth,
      borderWidth,
      size.width - 2 * borderWidth,
      size.height - 2 * borderWidth,
    );

    // 안쪽 라운드 반경(음수 방지)
    final double innerRadius =
    (cornerRadius - borderWidth).clamp(0.0, double.infinity);

    // 1) 셀은 라운드 영역 안에서만 보이도록 클립
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        innerRect,
        Radius.circular(innerRadius),
      ),
    );

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false; // 틈 방지 목적(픽셀 경계에서 흐려지는 현상 감소)

    // 2) 보드 셀 그리기 (borderWidth만큼 안쪽으로 오프셋)
    //    - +0.5로 살짝 겹쳐 그려 1px 틈을 덮음
    const double overlap = 0.5;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final int colorIndex = board[r][c];
        final Color tileColor = (colorIndex >= 0 && colorIndex < colors.length)
            ? colors[colorIndex]
            : Colors.black;

        fillPaint.color = tileColor;

        final double left = borderWidth + c * cellSize;
        final double top = borderWidth + r * cellSize;

        final Rect rect = Rect.fromLTWH(
          left,
          top,
          cellSize + overlap,
          cellSize + overlap,
        );

        canvas.drawRect(rect, fillPaint);
      }
    }

    canvas.restore();

    // 3) 마지막에 테두리(Stroke) 1번만 그려서 깔끔하게 마감
    final Paint borderPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..isAntiAlias = true;

    // stroke는 선 두께의 절반이 안/밖으로 퍼지므로,
    // Rect를 borderWidth/2 만큼 안쪽으로 넣어줘야 잘리지 않음
    final Rect borderRect = Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        borderRect,
        Radius.circular(cornerRadius),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GameBoardPainter oldDelegate) {
    // 보드 상태가 바뀔 때마다 항상 다시 그리도록 true
    return true;
  }
}
