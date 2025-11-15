import 'package:flutter/material.dart';
import 'palettes/palette_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repo = const PaletteRepository();
  final palettes = await repo.loadAll();

  // 첫 번째 팔레트 확인
  final first = palettes.first;
  debugPrint('✅ Loaded ${palettes.length} palettes');
  debugPrint('🎨 First Palette: ${first.name}');
  debugPrint('🖌️ Colors: ${first.colors}');

  runApp(const ColorFloodApp());
}

class ColorFloodApp extends StatelessWidget {
  const ColorFloodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Color Flood Ready!'),
        ),
      ),
    );
  }
}
