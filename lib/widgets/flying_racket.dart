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
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  late double _startX;
  late double _startY;
  late double _endX;
  late double _endY;
  late double _rotationSpeed;
  late double _scale;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _initializeRacket();
    _setupAnimations();
  }

  void _initializeRacket() {
    final random = math.Random(widget.index * 1000);
    
    // Rastgele başlangıç ve bitiş pozisyonları
    _startX = random.nextDouble() * widget.screenWidth;
    _startY = random.nextDouble() * widget.screenHeight;
    _endX = random.nextDouble() * widget.screenWidth;
    _endY = random.nextDouble() * widget.screenHeight;
    
    // Rastgele rotasyon hızı ve ölçek
    _rotationSpeed = (random.nextDouble() * 2 - 1) * 0.02; // -0.02 ile 0.02 arası
    _scale = 0.3 + random.nextDouble() * 0.4; // 0.3 ile 0.7 arası
    _duration = Duration(
      milliseconds: 8000 + random.nextInt(4000), // 8-12 saniye arası
    );
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: _duration,
      vsync: this,
    );

    // Pozisyon animasyonu (bezier curve ile doğal hareket)
    _positionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Rotasyon animasyonu
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    // Ölçek animasyonu (hafif büyüyüp küçülme efekti)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: _scale, end: _scale * 1.2),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: _scale * 1.2, end: _scale),
        weight: 0.4,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: _scale, end: _scale * 0.8),
        weight: 0.3,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animasyonu başlat
    _animationController.forward().then((_) {
      // Animasyon bittiğinde yeniden başlat
      _resetAndRestart();
    });
  }

  void _resetAndRestart() {
    if (mounted) {
      _initializeRacket();
      _animationController.reset();
      _setupAnimations();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Bezier curve ile doğal hareket hesapla
        final t = _positionAnimation.value;
        final x = _bezierInterpolation(
          _startX,
          _startX + (widget.screenWidth * 0.3),
          _endX - (widget.screenWidth * 0.3),
          _endX,
          t,
        );
        final y = _bezierInterpolation(
          _startY,
          _startY - (widget.screenHeight * 0.2),
          _endY + (widget.screenHeight * 0.2),
          _endY,
          t,
        );

        return Positioned(
          left: x,
          top: y,
          child: Transform.rotate(
            angle: _rotationAnimation.value * _rotationSpeed,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildRacket(),
            ),
          ),
        );
      },
    );
  }

  // Bezier curve interpolation
  double _bezierInterpolation(double p0, double p1, double p2, double p3, double t) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    return uuu * p0 + 3 * uu * t * p1 + 3 * u * tt * p2 + ttt * p3;
  }

  Widget _buildRacket() {
    return Container(
      width: 60,
      height: 80,
      child: CustomPaint(
        painter: RacketPainter(),
      ),
    );
  }
}

class RacketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF10B981).withValues(alpha: 0.6);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF059669).withValues(alpha: 0.8)
      ..strokeWidth = 2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Raket kafası (oval)
    final headRect = Rect.fromCenter(
      center: Offset(centerX, centerY - 10),
      width: 45,
      height: 35,
    );
    canvas.drawOval(headRect, paint);
    canvas.drawOval(headRect, strokePaint);

    // Raket telleri
    final stringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1;

    // Dikey teller
    for (int i = 0; i < 5; i++) {
      final x = headRect.left + (headRect.width / 4) * (i + 1);
      canvas.drawLine(
        Offset(x, headRect.top),
        Offset(x, headRect.bottom),
        stringPaint,
      );
    }

    // Yatay teller
    for (int i = 0; i < 4; i++) {
      final y = headRect.top + (headRect.height / 3) * (i + 1);
      canvas.drawLine(
        Offset(headRect.left, y),
        Offset(headRect.right, y),
        stringPaint,
      );
    }

    // Raket sapı
    final handleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 15),
        width: 8,
        height: 25,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(handleRect, paint);
    canvas.drawRRect(handleRect, strokePaint);

    // Sap bandı
    final bandPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF047857).withValues(alpha: 0.8);

    final bandRect = Rect.fromCenter(
      center: Offset(centerX, centerY + 20),
      width: 10,
      height: 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bandRect, const Radius.circular(2)),
      bandPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
