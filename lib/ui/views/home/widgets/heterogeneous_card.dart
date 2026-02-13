import 'package:flutter/material.dart';
import 'package:word_assistant/core/theme/app_colors.dart';


class HeterogeneousCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon; // Main Icon (e.g., Trophy/Alert)
  final IconData actionIcon; // Button Icon (e.g., Arrow/Plus)
  final bool isActive;
  final Color activeColor; // e.g., Red or Indigo
  final Color activeIconColor;
  final Color activeBackgroundColor; // Light color
  final VoidCallback? onTap;

  const HeterogeneousCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.actionIcon,
    this.isActive = false,
    required this.activeColor,
    required this.activeIconColor,
    required this.activeBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dimensions
    const double radius = 32.0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 208, // h-52 is 13rem = 208px
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Shape-Aware Shadow (replaces Rectangular Container)
            Positioned.fill(
              child: CustomPaint(
                painter: _ShadowPainter(
                  clipper: _CornerCutoutClipper(cutoutRadius: 30.0),
                  shadowColor: AppColors.slate900.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ),
            ),

            // 2. Main Card Content with Clipper
            Positioned.fill(
              child: ClipPath(
                clipper: _CornerCutoutClipper(cutoutRadius: 30.0), // 29px in CSS, rounded to 30 for smoothness
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(radius),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isActive
                          ? [
                              activeBackgroundColor,
                              Colors.white,
                              activeBackgroundColor.withValues(alpha: 0.3)
                            ]
                          : [AppColors.slate50, Colors.white],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon Circle
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isActive ? activeBackgroundColor : AppColors.emerald100, // Default green for perfect
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                size: 18,
                                color: isActive ? activeIconColor : AppColors.emerald600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Title
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.slate900,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Subtitle (Review Now / Perfect Score)
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive ? activeColor : AppColors.emerald500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),

                        // Bottom Section (Count)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.slate900,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '词',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // 3. Grey Overlay for Inactive state logic (Grayscale effect)
            if (!isActive)
              Positioned.fill(
                child: ClipPath(
                  clipper: _CornerCutoutClipper(cutoutRadius: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1), // Mild overlay
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                ),
              ),

            // 4. Floating Button
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? activeColor : AppColors.slate100,
                  border: Border.all(
                    color: AppColors.slate50, // Matches bg color
                    width: 4.0,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Icon(
                    actionIcon,
                    color: isActive ? Colors.white : AppColors.slate300,
                    size: 20,
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

class _CornerCutoutClipper extends CustomClipper<Path> {
  final double cutoutRadius;

  _CornerCutoutClipper({required this.cutoutRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    const r = 32.0; // Card Border Radius

    // Start from top-left
    path.moveTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);

    // Line to start of cutout
    // Cutout center is (w-16, 16). Radius is cutoutRadius (30).
    // We need to find the intersection of the top edge with the cutout circle.
    // The top edge is y=0.
    // Circle eq: (x - (w-16))^2 + (y-16)^2 = R^2
    // intersection at y=0 is complicated.
    // Simplifying: The cutout basically replaces the top-right corner.
    
    // Let's use Path.combine to subtract the circle.
    
    final cardPath = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(r)));
    
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: Offset(w - 16, 16), radius: cutoutRadius));
      
    final result = Path.combine(PathOperation.difference, cardPath, circlePath);
    return result;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ShadowPainter extends CustomPainter {
  final CustomClipper<Path> clipper;
  final Color shadowColor;
  final double blurRadius;
  final Offset offset;

  _ShadowPainter({
    required this.clipper,
    required this.shadowColor,
    required this.blurRadius,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size);
    // Shift path by offset
    final shiftedPath = path.shift(offset);
    
    final paint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    canvas.drawPath(shiftedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ShadowPainter oldDelegate) {
    return oldDelegate.shadowColor != shadowColor ||
           oldDelegate.blurRadius != blurRadius ||
           oldDelegate.offset != offset;
  }
}
