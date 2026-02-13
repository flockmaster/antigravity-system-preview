import 'package:flutter/material.dart';
import 'package:word_assistant/core/theme/app_colors.dart';

class MasteryRingPainter extends CustomPainter {
  final double masteredPercent;
  final double learningPercent;
  final double newPercent;

  MasteryRingPainter({
    required this.masteredPercent,
    required this.learningPercent,
    required this.newPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt; // Butt for continuous ring segments

    // 1. New (Base or Segment)
    // We draw segments: Mastered -> Learning -> New
    // Start from -90 deg (Top)

    double startAngle = -1.5708; // -90 deg

    // Mastered (Blue/Green?) PRD: Blue(Mastered)? PRD says:
    // 🔵 Mastered (3 stars)
    // 🟡 Learning (1-2 stars)
    // 🔴 New
    // Let's use:
    // Mastered: AppColors.blue500 or emerald500? PRD mentions Blue for Mastered in Ring, but Green for Safe in Smart Review.
    // Let's stick to PRD Ring colors: Blue=Mastered.
    
    // Mastered Segment
    paint.color = AppColors.blue500;
    double sweep = (masteredPercent / 100) * 2 * 3.14159;
    if (sweep > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    // Learning Segment
    paint.color = AppColors.amber400; // Yellow
    sweep = (learningPercent / 100) * 2 * 3.14159;
    if (sweep > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    // New Segment
    paint.color = AppColors.rose400; // Red
    sweep = (newPercent / 100) * 2 * 3.14159;
    // Fill the rest to close the loop if rounding errors? or just draw calc'd.
    // If total is < 100% (shouldn't be), it leaves gap.
    // Let's draw remaining.
    // Actually, recalculate remaining sweep to ensure full circle if total is 100.
    double remaining = (2 * 3.14159) - (startAngle - (-1.5708));
    if (remaining > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, remaining, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TrendChartPainter extends CustomPainter {
  final List<int> data;
  
  TrendChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) {
       // Not enough data to draw a line
       return; 
    }
    
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    final double xStep = size.width / (data.length - 1);
    
    // Safeguard reduce
    final int maxVal = data.reduce((curr, next) => curr > next ? curr : next);
    final int minVal = data.reduce((curr, next) => curr < next ? curr : next);
    final double range = (maxVal - minVal).toDouble();
    final double safeRange = range == 0 ? 1 : range;

    for (int i = 0; i < data.length; i++) {
        final double x = i * xStep;
        // Logic: specific value normalized to height. 
        // Higher value = Lower Y (Top is 0).
        // Let's say padding top 10%, bottom 10%.
        // Y = Height - ((Value - Min) / Range) * Height * 0.8 - Height * 0.1
        final double normalized = (data[i] - minVal) / safeRange;
        final double y = size.height - (normalized * size.height * 0.6) - (size.height * 0.2);
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          // Curveto for smooth line? Or simple LineTo? 
          // Simple LineTo for chart readability.
          path.lineTo(x, y);
        }
    }
    canvas.drawPath(path, paint);

    // Fill Gradient
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
         Colors.white.withValues(alpha: 0.3),
         Colors.white.withValues(alpha: 0.0),
      ],
    );
    
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
