// lib/palettes/palette_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'palette.dart';

/// 자산(JSON)에서 팔레트 리스트를 읽어오는 리포지토리.
/// - 기본 경로: assets/data/palettes.json
class PaletteRepository {
  final String assetPath;
  const PaletteRepository({this.assetPath = 'assets/data/palettes.json'});

  /// 자산 JSON을 읽어 Palette 리스트로 반환.
  /// - 숫자/공백/소문자/해시 포함 같은 불량 데이터도 Palette.fromJson 내부에서 정규화됨.
  Future<List<Palette>> loadAll() async {
    final raw = await rootBundle.loadString(assetPath);
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    final palettes = list
        .map((e) => Palette.fromJson(e as Map<String, dynamic>))
        .toList();
    return palettes;
  }

  /// id로 특정 팔레트 찾기 (없으면 null)
  Future<Palette?> findById(String id) async {
    final all = await loadAll();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
