// lib/ingame/logic/board_utils.dart

import 'dart:math';

/// Color Flood 보드 관련 순수 유틸 함수 모음.
/// - 랜덤 보드 생성
/// - Flood Fill
/// - 모든 칸 같은 색인지 체크
class BoardUtils {
  /// size x size 크기의 랜덤 보드를 생성.
  /// 각 칸에는 [0 ~ colorCount-1] 사이의 색 인덱스가 들어감.
  static List<List<int>> generateRandomBoard({
    required int size,
    required int colorCount,
    Random? random,
  }) {
    final r = random ?? Random();
    return List.generate(
      size,
          (_) => List.generate(
        size,
            (_) => r.nextInt(colorCount),
      ),
    );
  }

  /// DFS 방식 Flood Fill
  /// - [board]: [row][col] 형태의 2차원 배열
  /// - [row], [col]: 시작 위치
  /// - [targetColor]: 기존 색
  /// - [newColor]: 바꿀 색
  static void floodFill({
    required List<List<int>> board,
    required int row,
    required int col,
    required int targetColor,
    required int newColor,
  }) {
    final size = board.length;
    if (size == 0) return;

    // target == new 면 더 볼 필요 없음
    if (targetColor == newColor) return;

    void dfs(int r, int c) {
      if (r < 0 || r >= size || c < 0 || c >= size) return;
      if (board[r][c] != targetColor) return;

      board[r][c] = newColor;

      dfs(r - 1, c);
      dfs(r + 1, c);
      dfs(r, c - 1);
      dfs(r, c + 1);
    }

    dfs(row, col);
  }

  /// 보드의 모든 칸이 동일한 색인지 체크.
  static bool isAllSameColor(List<List<int>> board) {
    final size = board.length;
    if (size == 0) return false;

    final color = board[0][0];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] != color) return false;
      }
    }
    return true;
  }
}
