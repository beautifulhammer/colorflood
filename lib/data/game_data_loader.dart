import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'palette_model.dart';
import 'stage_model.dart';

/// JSON 에셋에서 palettes / stage 데이터를 로딩하고 캐싱하는 헬퍼
class GameDataLoader {
  GameDataLoader._();

  static List<Palette>? _palettes;
  static List<StageData>? _stages;

  static bool get isLoaded => _palettes != null && _stages != null;

  /// palettes.json + stage_data.json 을 모두 로딩
  static Future<void> loadAll() async {
    if (isLoaded) return;

    // palettes.json 로딩
    final palettesJsonStr =
    await rootBundle.loadString('assets/data/palettes.json');
    final List<dynamic> palettesList = jsonDecode(palettesJsonStr);
    _palettes = palettesList
        .map((e) => Palette.fromJson(e as Map<String, dynamic>))
        .toList();

    // stage_data.json 로딩
    final stagesJsonStr =
    await rootBundle.loadString('assets/data/stage_data.json');
    final List<dynamic> stagesList = jsonDecode(stagesJsonStr);
    _stages = stagesList
        .map((e) => StageData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 스테이지 번호로 StageData 찾기
  static StageData? getStage(int stageNum) {
    if (!isLoaded) return null;
    return _stages!.firstWhere(
          (s) => s.stageNum == stageNum,
      orElse: () => _stages!.first,
    );
  }

  /// paletteId로 Palette 찾기
  static Palette? getPalette(String paletteId) {
    if (!isLoaded) return null;
    return _palettes!.firstWhere(
          (p) => p.id == paletteId,
      orElse: () => _palettes!.first,
    );
  }
}
