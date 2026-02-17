import 'package:flutter/material.dart';

class StartButton extends StatefulWidget {
  final VoidCallback onTap;
  final String stageText;

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

  static const Color _mainColor = Color(0xFF14213D);
  static const Color _subColor = Color(0xFFFCA311);
  static const Color _lightGray = Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);
    final double depth = _isPressed ? 0.6 : 1.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      scale: _isPressed ? 0.975 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _isPressed ? 3.0 : 0.0,
          0,
        ),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _mainColor,
              _mainColor.withOpacity(0.92),
              _mainColor,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
          borderRadius: radius,
          border: Border.all(
            color: _subColor.withOpacity(0.75),
            width: 1.6,
          ),
          boxShadow: [
            // 바닥 깊이 그림자
            BoxShadow(
              color: Colors.black.withOpacity(0.55 * depth),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
            // 상단 은은한 하이라이트
            BoxShadow(
              color: _lightGray.withOpacity(0.10 * depth),
              blurRadius: 10,
              offset: const Offset(0, -6),
              spreadRadius: -6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (isDown) {
                if (!mounted) return;
                setState(() => _isPressed = isDown);
              },
              borderRadius: radius,
              splashColor: _subColor.withOpacity(0.18),
              highlightColor: _subColor.withOpacity(0.10),
              child: Stack(
                children: [
                  // 내측 엣지 라인
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          border: Border.all(
                            color: _lightGray.withOpacity(0.08 * depth),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 상단 글로시 효과
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: widget.height * 0.42,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: radius.topLeft,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _lightGray.withOpacity(0.08 * depth),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 텍스트 영역
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'START',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFCA311),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.stageText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFCA311),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
