import 'package:flutter/material.dart';
import 'dart:math' as math;

class FlyingRacket extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final int index;

  const FlyingRacket({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.index,
  });

  @override
  State<FlyingRacket> createState() => _FlyingRacketState();
}

class _FlyingRacketState extends State<FlyingRacket>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Her raket için farklı süre ve gecikme
    final duration = Duration(seconds: 15 + (widget.index * 3));
    final delay = Duration(milliseconds: widget.index * 2000);
    
    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -100.0,
      end: widget.screenWidth + 100.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Gecikme ile animasyonu başlat
    Future.delayed(delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _animation.value;
        final rotation = _rotationAnimation.value;
        final scale = _scaleAnimation.value;
        
        // Y pozisyonunu hesapla (sinüs dalgası)
        final yOffset = math.sin(progress * 0.01) * 50;
        final yPosition = (widget.screenHeight * 0.3) + yOffset;
        
        return Positioned(
          left: progress,
          top: yPosition,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: 0.3,
                child: CustomPaint(
                  size: const Size(40, 40),
                  painter: TennisRacketPainter(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TennisRacketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Racket head (oval)
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.8,
      height: size.height * 0.6,
    );
    
    canvas.drawOval(rect, paint);
    canvas.drawOval(rect, strokePaint);

    // Racket handle
    final handleRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size.height * 0.3),
      width: size.width * 0.15,
      height: size.height * 0.4,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(2)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(2)),
      strokePaint,
    );

    // Strings
    final stringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Vertical strings
    for (int i = 0; i < 3; i++) {
      final x = rect.left + (rect.width / 4) * (i + 1);
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        stringPaint,
      );
    }

    // Horizontal strings
    for (int i = 0; i < 2; i++) {
      final y = rect.top + (rect.height / 3) * (i + 1);
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        stringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(TennisRacketPainter oldDelegate) => false;
}
