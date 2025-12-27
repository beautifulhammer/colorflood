import 'package:flutter/material.dart';

/// 홈 화면에서 사용하는 START 버튼 공용 위젯
///
/// - 커스텀 그라데이션 + 2중 그림자
/// - Material + InkWell
/// - 눌림 효과: 살짝 아래로 이동 + 살짝 축소
class StartButton extends StatefulWidget {
  final VoidCallback onTap;
  final String stageText;

  /// 버튼 크기 커스터마이즈 가능
  final double width;
  final double height;

  const StartButton({
    super.key,
    required this.onTap,
    required this.stageText,
    this.width = 200,
    this.height = 80,
  });

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(32);

    return AnimatedScale(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      scale: _isPressed ? 0.98 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isPressed ? 3.0 : 0.0, 0),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade400,
              Colors.grey.shade600,
              Colors.grey.shade800,
            ],
          ),
          borderRadius: radius,
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            // 아래 그림자 (깊은 그림자)
            BoxShadow(
              color: Colors.grey.shade900.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
            // 위 하이라이트 효과
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (isDown) {
              if (!mounted) return;
              setState(() => _isPressed = isDown);
            },
            borderRadius: radius,
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'START',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.stageText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
