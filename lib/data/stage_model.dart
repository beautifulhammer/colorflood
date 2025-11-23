/// 스테이지 한 개를 나타내는 메타 데이터
class StageData {
  final int stageNum;
  final String paletteId;
  final int boardSize; // N -> N x N
  final String difficulty;
  final int maxMoves;

  StageData({
    required this.stageNum,
    required this.paletteId,
    required this.boardSize,
    required this.difficulty,
    required this.maxMoves,
  });

  factory StageData.fromJson(Map<String, dynamic> json) {
    return StageData(
      stageNum: json['stageNum'] as int,
      paletteId: json['paletteId'].toString(),
      boardSize: json['boardSize'] as int,
      difficulty: json['difficulty'].toString(),
      maxMoves: json['maxMoves'] as int,
    );
  }
}
