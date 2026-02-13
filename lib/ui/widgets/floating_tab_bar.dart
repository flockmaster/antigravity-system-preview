import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';

class FloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTap;

  const FloatingTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    // Bottom padding already handled by Positioned in parent, 
    // but we can add safe area here if needed or just assume parent handles it.
    // Prototype: bottom-8.

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.slate900.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.slate900.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Tab
              Expanded(
                child: _TabButton(
                  icon: LucideIcons.home,
                  isActive: currentIndex == 0,
                  onTap: () => onTabTap(0),
                  activeColor: AppColors.violet400,
                  shadowColor: const Color(0xFFA78BFA).withValues(alpha: 0.8), // violet-400
                ),
              ),
              
              // Vertical Divider
              Container(
                width: 1,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),

              // Calendar Tab (Settings/Calendar in prototype?)
              // Prototype uses CalendarIcon.
              Expanded(
                child: _TabButton(
                  icon: LucideIcons.calendar,
                  isActive: currentIndex == 1,
                  onTap: () => onTabTap(1),
                  activeColor: AppColors.orange400,
                  shadowColor: const Color(0xFFFB923C).withValues(alpha: 0.8), // orange-400
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color shadowColor;

  const _TabButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox( // Ensure hit target fits parent Expanded
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Active Background
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isActive ? 1.0 : 0.0,
              child: Container(
                margin: const EdgeInsets.all(8), // inset-2
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
            ),

            // Icon & Dot
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isActive ? 1.05 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 4), // visual adjustment
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
