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

  static const Color _dark = Color(0xFF232323);
  static const Color _ivory = Color(0xFFFFF8EA);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);

    return AnimatedScale(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      scale: _isPressed ? 0.97 : 1.0,
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
          color: _ivory,
          borderRadius: radius,
          border: Border.all(
            color: _dark,
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            onHighlightChanged: (isDown) {
              if (!mounted) return;
              setState(() => _isPressed = isDown);
            },
            splashColor: _dark.withOpacity(0.08),
            highlightColor: _dark.withOpacity(0.05),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'START',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _dark,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.stageText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _dark,
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