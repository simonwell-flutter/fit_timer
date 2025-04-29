import 'package:flutter/material.dart';
import 'dart:math' as Math;

class RippleAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final int rippleCount;
  final bool isActive;

  const RippleAnimation({
    Key? key,
    required this.size,
    required this.color,
    this.rippleCount = 5,
    this.isActive = false,
  }) : super(key: key);

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _vibrateController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _vibrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80), // 12.5Hz
    );
    if (widget.isActive) {
      _controller.repeat();
      _vibrateController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant RippleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
      _vibrateController.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.0;
      _vibrateController.stop();
      _vibrateController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _vibrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vibrateController,
      builder: (context, child) {
        // 震動 scale: 0.98~1.02 之間
        final scale =
            1 +
            0.02 *
                (0.5 -
                    (0.5 *
                        (1 +
                            (Math.sin(
                              _vibrateController.value * 2 * 3.1415926,
                            )))));
        return Transform.scale(scale: scale, child: child);
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _RipplePainter(
                progress: _controller.value,
                color: widget.color,
                rippleCount: widget.rippleCount,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int rippleCount;

  _RipplePainter({
    required this.progress,
    required this.color,
    required this.rippleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;
    for (int i = 0; i < rippleCount; i++) {
      final currentProgress = (progress + i / rippleCount) % 1.0;
      final radius = maxRadius * currentProgress;
      final opacity = (1.0 - currentProgress).clamp(0.0, 1.0);
      // Glow effect
      final glowPaint =
          Paint()
            ..color = Colors.white.withOpacity(opacity * 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 48.0 * (1 - currentProgress)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16);
      if (radius > 0) {
        canvas.drawCircle(center, radius, glowPaint);
      }
      // Main ripple
      final paint =
          Paint()
            ..color = Colors.white.withOpacity(opacity * 0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 24.0 * (1 - currentProgress);
      if (radius > 0) {
        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.rippleCount != rippleCount;
  }
}
