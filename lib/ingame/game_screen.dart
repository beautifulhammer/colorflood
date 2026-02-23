// lib/ingame/game_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import 'controller/game_controller.dart';
import 'widgets/game_board.dart';
import 'widgets/color_buttons_row.dart';
import 'result/clear_result_overlay.dart';
import 'result/game_over_result_overlay.dart';
import 'widgets/clear_confetti_widget.dart';

class GameScreen extends StatefulWidget {
  final int stageNum;

  const GameScreen({
    super.key,
    required this.stageNum,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  late final ConfettiController _confettiController;

  bool _playedConfettiForClear = false;

  // 🎨 2 Color System
  static const Color _dark = Color(0xFF232323);
  static const Color _ivory = Color(0xFFFFF8EA);

  @override
  void initState() {
    super.initState();

    _controller = GameController();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _controller.addListener(_onControllerChanged);
    _controller.init(stageNum: widget.stageNum);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final state = _controller.state;

    if (state.resultState != GameResultState.clear) {
      _playedConfettiForClear = false;
    }

    if (state.resultState == GameResultState.clear &&
        !_playedConfettiForClear) {
      _playedConfettiForClear = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _confettiController.play();
      });
    }

    if (mounted) setState(() {});
  }

  PreferredSizeWidget _buildThinEmptyAppBar() {
    return AppBar(
      backgroundColor: _dark,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 25,
    );
  }

  Widget _buildBannerArea(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: _dark,
      alignment: Alignment.center,
      child: const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: _dark,
        body: Center(
          child: CircularProgressIndicator(
            color: _ivory,
          ),
        ),
      );
    }

    if (state.errorMessage != null) {
      return Scaffold(
        backgroundColor: _dark,
        appBar: _buildThinEmptyAppBar(),
        body: Center(
          child: Text(
            '데이터 로딩 중 오류 발생:\n${state.errorMessage}',
            style: const TextStyle(color: _ivory),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final stage = state.stage;
    final palette = state.palette;

    if (stage == null || palette == null || state.board.isEmpty) {
      return const Scaffold(
        backgroundColor: _dark,
        body: Center(
          child: CircularProgressIndicator(
            color: _ivory,
          ),
        ),
      );
    }

    final stageLabel =
        'STAGE ${stage.stageNum.toString().padLeft(2, '0')}';

    return Stack(
      children: [
        Scaffold(
          backgroundColor: _dark,
          appBar: _buildThinEmptyAppBar(),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double horizontalPadding = 16.0;
                final h = constraints.maxHeight;

                final double topPadding =
                (h * 0.012).clamp(4.0, 8.0);
                const double stageTextHeight = 32.0;
                final double titleToCardGap =
                (h * 0.018).clamp(10.0, 18.0);
                const double cardHeight = 72.0;
                final double afterCardGap =
                (h * 0.012).clamp(6.0, 10.0);

                final double boardToButtonsGap =
                (h * 0.035).clamp(12.0, 30.0);
                final double buttonsAreaHeight =
                (h * 0.16).clamp(72.0, 96.0);
                final double bannerHeight =
                (h * 0.10).clamp(44.0, 56.0);

                final double topSectionHeight =
                    topPadding +
                        stageTextHeight +
                        titleToCardGap +
                        cardHeight +
                        afterCardGap;

                final double availableHeightForBoard =
                (constraints.maxHeight -
                    topSectionHeight -
                    boardToButtonsGap -
                    buttonsAreaHeight -
                    bannerHeight)
                    .clamp(0.0, constraints.maxHeight);

                final double availableWidthForBoard =
                (constraints.maxWidth -
                    (horizontalPadding * 2))
                    .clamp(0.0, constraints.maxWidth);

                final double boardSide = math
                    .min(availableWidthForBoard,
                    availableHeightForBoard)
                    .clamp(1.0, double.infinity);

                final double cardWidth = boardSide;

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: topPadding),
                      child: Center(
                        child: SizedBox(
                          width: cardWidth,
                          height: stageTextHeight,
                          child: Stack(
                            children: [
                              Align(
                                alignment:
                                Alignment.centerLeft,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints:
                                  const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.home,
                                    color: _ivory,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context)
                                          .pop(),
                                ),
                              ),
                              Center(
                                child: Text(
                                  stageLabel,
                                  style:
                                  const TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                    FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: _ivory,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: titleToCardGap),
                    Center(
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: _TopInfoCard(
                          remaining:
                          state.remainingMoves,
                          maxMoves: stage.maxMoves,
                          boardSize:
                          stage.boardSize,
                          onRetry:
                          _controller.retry,
                        ),
                      ),
                    ),
                    SizedBox(height: afterCardGap),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: boardSide,
                          height: boardSide,
                          child: GameBoard(
                            board: state.board,
                            colors:
                            palette.colors,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: boardToButtonsGap),
                    SizedBox(
                      height: buttonsAreaHeight,
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal:
                            horizontalPadding),
                        child: ColorButtonsRow(
                          colors:
                          palette.colors,
                          onColorSelected:
                          _controller
                              .applyMove,
                        ),
                      ),
                    ),
                    _buildBannerArea(bannerHeight),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ClearConfettiWidget(
              controller: _confettiController,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopInfoCard extends StatelessWidget {
  final int remaining;
  final int maxMoves;
  final int boardSize;
  final VoidCallback onRetry;

  const _TopInfoCard({
    required this.remaining,
    required this.maxMoves,
    required this.boardSize,
    required this.onRetry,
  });

  static const Color _dark = Color(0xFF232323);
  static const Color _ivory = Color(0xFFFFF8EA);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _ivory.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Text(
                '남은 카운트',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _ivory,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$remaining/$maxMoves',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _ivory,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${boardSize}x$boardSize',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _ivory,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: _ivory,
            ),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}