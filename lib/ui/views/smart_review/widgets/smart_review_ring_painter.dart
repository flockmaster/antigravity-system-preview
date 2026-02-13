import 'dart:math';
import 'package:flutter/material.dart';

class SmartReviewRingPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final List<Color> gradientColors;
  final Color backgroundColor;
  final double strokeWidth;

  SmartReviewRingPainter({
    required this.progress,
    required this.gradientColors,
    required this.backgroundColor,
    this.strokeWidth = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // 1. Draw Background Ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 2. Draw Gradient Progress Ring
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
      tileMode: TileMode.repeated,
      colors: gradientColors,
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc starting from top (-pi/2)
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );

    // 3. Optional: Add a subtle shadow/glow at the end of the arc
    if (progress > 0) {
      final endAngle = -pi / 2 + 2 * pi * progress;
      final endPoint = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      );

      final glowPaint = Paint()
        ..color = gradientColors.last.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(endPoint, strokeWidth / 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SmartReviewRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientColors != gradientColors;
  }
}
