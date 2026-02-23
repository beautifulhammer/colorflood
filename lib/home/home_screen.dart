import 'package:flutter/material.dart';

import '../data/user_data.dart';
import '../data/user_data_repository.dart';
import '../ingame/game_screen.dart';
import '../data/gold_indicator.dart';
import '../home/widgets/start_button.dart';
import '../home/popup/palette_book_page.dart';
import '../home/widgets/next_stage_palette_loader.dart';

class HomeScreen extends StatefulWidget {
  final UserData userData;

  const HomeScreen({
    super.key,
    required this.userData,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserData _userData;
  bool _isRefreshing = false;

  List<Color>? _nextPaletteColors;

  final _userRepo = UserDataRepository.instance;

  // 🎨 Global Color System
  static const Color _bgColor = Color(0xFF232323);
  static const Color _deepBlack = Color(0xFF0F0F0F);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _lightText = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _refreshUserData();
    _loadNextStagePalette(_nextStageToPlay);
  }

  Future<void> _refreshUserData() async {
    setState(() => _isRefreshing = true);

    try {
      final updated = await _userRepo.refresh(_userData.uid);
      setState(() => _userData = updated);
      await _loadNextStagePalette(_nextStageToPlay);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  int get _nextStageToPlay {
    final cleared = _userData.clearedStage;
    if (cleared <= 0) return 1;
    return cleared + 1;
  }

  Future<void> _loadNextStagePalette(int stageNum) async {
    final colors = await NextStagePaletteLoader.loadColors(stageNum);
    if (!mounted) return;
    setState(() => _nextPaletteColors = colors);
  }

  Future<void> _onTapStart() async {
    final nextStage = _nextStageToPlay;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(stageNum: nextStage),
      ),
    );

    await _refreshUserData();
  }

  Future<void> _onTapPaletteBook() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PaletteBookPage(userData: _userData),
      ),
    );
  }

  void _onTapHelp() {}
  void _onTapSettings() {}

  @override
  Widget build(BuildContext context) {
    final goldTextStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: _lightText,
    );

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 25,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단 영역
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildGoldIndicator(
                    gold: _userData.gold,
                    isRefreshing: _isRefreshing,
                    iconSize: 30,
                    textStyle: goldTextStyle,
                  ),

                  Row(
                    children: [
                      IconButton(
                        onPressed: _onTapPaletteBook,
                        icon: const Icon(
                          Icons.palette_outlined,
                          color: Color(0xFFFFF8EA),
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: _onTapHelp,
                        icon: const Icon(
                          Icons.help_outline,
                          color: Color(0xFFFFF8EA),
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: _onTapSettings,
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Color(0xFFFFF8EA),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 160),

            // 🔹 중앙
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StartButton(
                      onTap: _onTapStart,
                      stageText: 'STAGE $_nextStageToPlay',
                    ),

                    const SizedBox(height: 70),

                    // 🔹 팔레트 미리보기
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final color = (_nextPaletteColors != null &&
                            index < _nextPaletteColors!.length)
                            ? _nextPaletteColors![index]
                            : _deepBlack;

                        return Container(
                          width: 46,
                          height: 46,
                          margin:
                          const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _gold.withOpacity(0.4),
                              width: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 하단 배너 영역
            Container(
              height: 56,
              width: double.infinity,
              color: _deepBlack,
              alignment: Alignment.center,
              child: const Text(
                'Banner Ad Area',
                style: TextStyle(
                  fontSize: 12,
                  color: _lightText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}