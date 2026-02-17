import 'package:flutter/material.dart';

import '../../data/game_data_loader.dart';
import '../../data/palette_model.dart';
import '../../data/stage_model.dart';

/// 다음 스테이지에서 사용할 팔레트(6색) 로딩 전용 유틸
///
/// - GameDataLoader.loadAll() 포함
/// - stageNum에 해당하는 StageData / Palette를 찾아 colors 반환
/// - 실패하거나 데이터가 없으면 null 반환
class NextStagePaletteLoader {
  static Future<List<Color>?> loadColors(int stageNum) async {
    try {
      await GameDataLoader.loadAll();

      final StageData? stage = GameDataLoader.getStage(stageNum);
      if (stage == null) return null;

      final Palette? palette = GameDataLoader.getPalette(stage.paletteId);
      if (palette == null) return null;

      return palette.colors;
    } catch (_) {
      return null;
    }
  }
}
