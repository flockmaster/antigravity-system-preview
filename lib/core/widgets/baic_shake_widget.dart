import 'dart:math';
import 'package:flutter/material.dart';

class BaicShakeWidget extends StatefulWidget {
  final Widget child;
  final bool isShake;
  final double offset;
  final Duration duration;

  const BaicShakeWidget({
    super.key,
    required this.child,
    required this.isShake,
    this.offset = 10.0,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<BaicShakeWidget> createState() => _BaicShakeWidgetState();
}

class _BaicShakeWidgetState extends State<BaicShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void didUpdateWidget(covariant BaicShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShake && !oldWidget.isShake) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final sineValue = sin(4 * pi * _animation.value);
        return Transform.translate(
          offset: Offset(sineValue * widget.offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
