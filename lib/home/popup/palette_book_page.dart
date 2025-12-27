import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/user_data.dart';

/// 팔레트 도감 (전면 팝업 화면)
///
/// - 다이얼로그가 아닌 전면 팝업(전체 화면 push)
/// - 상단: 팝업명 "팔레트" + [X] 닫기
/// - 중앙: 팔레트 리스트 (1열 1팔레트, 상하 스크롤)
///   - 썸네일: 6개의 직사각형 색상이 1줄(1x6)로 나열
///   - 썸네일 하단: 팔레트 이름 (en/ko/cn 번역 적용)
///   - 오픈된 팔레트만 색상 표시
///   - 미오픈 팔레트는 회색 + 중앙 자물쇠 + 해금 스테이지(예: 101 STAGE)
///
/// 추가 UX
/// - 스크롤로 상단 UI가 안 보이기 시작할 때(대략 10개 이상 내려갔을 때)
///   우측 하단에 ▲ 버튼 표시
/// - ▲ 버튼 탭 시 맨 위로 스크롤
class PaletteBookPage extends StatefulWidget {
  final UserData userData;

  const PaletteBookPage({
    super.key,
    required this.userData,
  });

  @override
  State<PaletteBookPage> createState() => _PaletteBookPageState();
}

class _PaletteBookPageState extends State<PaletteBookPage> {
  bool _loading = true;
  List<_PaletteEntry> _palettes = [];

  static const String _palettesAssetPath = 'assets/data/palettes.json';

  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  static const double _showButtonThresholdPx = 1200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadPalettesFromAsset();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShow = _scrollController.hasClients &&
        _scrollController.offset >= _showButtonThresholdPx;

    if (shouldShow != _showScrollToTop) {
      setState(() {
        _showScrollToTop = shouldShow;
      });
    }
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadPalettesFromAsset() async {
    try {
      final raw = await rootBundle.loadString(_palettesAssetPath);
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        throw Exception('palettes.json is not a List');
      }

      final palettes = decoded
          .map((e) => _PaletteEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      palettes.sort((a, b) => _extractPaletteNumber(a.paletteId)
          .compareTo(_extractPaletteNumber(b.paletteId)));

      if (!mounted) return;
      setState(() {
        _palettes = palettes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _palettes = [];
        _loading = false;
      });
    }
  }

  int _extractPaletteNumber(String paletteId) {
    final digits = RegExp(r'\d+').firstMatch(paletteId)?.group(0);
    return int.tryParse(digits ?? '') ?? 0;
  }

  /// 현재 언어 코드 결정 (cn 정책 반영)
  String _currentLangCode(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    if (code == 'zh') return 'cn';
    if (code == 'cn') return 'cn';
    if (code == 'ko') return 'ko';
    return 'en';
  }

  /// ✅ 팔레트 오픈 개수 계산 (100 스테이지마다 1개 오픈)
  ///
  /// - stageNum = 1   -> 1개 오픈
  /// - stageNum = 101 -> 2개 오픈
  /// - stageNum = 201 -> 3개 오픈
  int _unlockedPaletteCount() {
    final cleared = widget.userData.clearedStage;
    final currentStage = (cleared <= 0) ? 1 : (cleared + 1);

    final count = 1 + ((currentStage - 1) ~/ 100);
    final maxCount = _palettes.isEmpty ? 60 : _palettes.length;
    return count.clamp(1, maxCount);
  }

  bool _isUnlocked(int index) {
    final unlockedCount = _unlockedPaletteCount();
    return index < unlockedCount;
  }

  /// ✅ index 기반 해금 스테이지 계산
  /// - index 0 -> 1
  /// - index 1 -> 101
  /// - index 2 -> 201
  int _unlockStageForIndex(int index) {
    return 1 + (index * 100);
  }

  @override
  Widget build(BuildContext context) {
    final lang = _currentLangCode(context);

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 상단 헤더
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '팔레트',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 28),
                        tooltip: '닫기',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _palettes.isEmpty
                      ? const Center(
                    child: Text(
                      '팔레트를 불러올 수 없어요.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                      : ListView.builder(
                    controller: _scrollController,
                    padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _palettes.length,
                    itemBuilder: (context, index) {
                      final palette = _palettes[index];
                      final isUnlocked = _isUnlocked(index);
                      final unlockStage = _unlockStageForIndex(index);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _PaletteListTile(
                          palette: palette,
                          lang: lang,
                          isUnlocked: isUnlocked,
                          unlockStage: unlockStage,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // 우측 하단 ▲ 버튼
            Positioned(
              right: 16,
              bottom: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                opacity: _showScrollToTop ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_showScrollToTop,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    scale: _showScrollToTop ? 1.0 : 0.95,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _scrollToTop,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1열 1팔레트 구성: 썸네일(1x6) + 하단 이름
class _PaletteListTile extends StatelessWidget {
  final _PaletteEntry palette;
  final String lang;
  final bool isUnlocked;
  final int unlockStage;

  const _PaletteListTile({
    required this.palette,
    required this.lang,
    required this.isUnlocked,
    required this.unlockStage,
  });

  @override
  Widget build(BuildContext context) {
    final title = palette.nameByLang(lang);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        children: [
          _PaletteThumbBar(
            colors: palette.colors,
            isUnlocked: isUnlocked,
            unlockStage: unlockStage,
            height: 26,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUnlocked ? Colors.white : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 6개의 직사각형 색상이 1줄(1x6)로 나열되는 썸네일
///
/// - unlocked: 6색 표시
/// - locked: 회색 처리 + 중앙 자물쇠 + 해금 스테이지 텍스트
class _PaletteThumbBar extends StatelessWidget {
  final List<Color> colors;
  final bool isUnlocked;
  final int unlockStage;
  final double height;

  const _PaletteThumbBar({
    required this.colors,
    required this.isUnlocked,
    required this.unlockStage,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    final bar = ClipRRect(
      borderRadius: radius,
      child: isUnlocked
          ? Row(
        children: List.generate(6, (i) {
          final c = (i < colors.length) ? colors[i] : Colors.grey;
          return Expanded(child: Container(color: c));
        }),
      )
          : Container(color: Colors.grey.shade600),
    );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(child: bar),

          // 테두리
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: Colors.white12, width: 1),
              ),
            ),
          ),

          if (!isUnlocked)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$unlockStage STAGE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaletteEntry {
  final String paletteId;
  final Map<String, String> names; // en/ko/cn
  final List<Color> colors; // 6 colors

  _PaletteEntry({
    required this.paletteId,
    required this.names,
    required this.colors,
  });

  factory _PaletteEntry.fromJson(Map<String, dynamic> json) {
    final paletteId = (json['paletteId'] ?? '').toString();

    final nameMapRaw = json['paletteName'];
    final Map<String, String> names = {};
    if (nameMapRaw is Map) {
      for (final entry in nameMapRaw.entries) {
        names[entry.key.toString()] = entry.value.toString();
      }
    }

    final hexMapRaw = json['colorHex'];
    final Map<int, String> hexByIndex = {};
    if (hexMapRaw is Map) {
      for (final entry in hexMapRaw.entries) {
        final k = int.tryParse(entry.key.toString());
        final v = entry.value.toString();
        if (k != null) hexByIndex[k] = v;
      }
    }

    final ordered = List.generate(6, (i) => i + 1)
        .map((k) => hexByIndex[k])
        .toList();

    final colors = ordered.map((hex) {
      if (hex == null) return Colors.grey;
      return _hexToColor(hex);
    }).toList();

    return _PaletteEntry(
      paletteId: paletteId,
      names: names,
      colors: colors,
    );
  }

  String nameByLang(String lang) {
    return names[lang] ?? names['en'] ?? names['ko'] ?? names['cn'] ?? paletteId;
  }

  static Color _hexToColor(String raw) {
    var s = raw.trim().replaceAll('#', '').toUpperCase();
    if (s.length == 6) s = 'FF$s';
    if (s.length != 8) return Colors.grey;

    final value = int.tryParse(s, radix: 16);
    if (value == null) return Colors.grey;
    return Color(value);
  }
}
