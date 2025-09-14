import 'package:flutter/material.dart';

class TennisLoading extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const TennisLoading({
    super.key,
    this.size = 50.0,
    this.color,
    this.strokeWidth = 3.0,
  });

  @override
  State<TennisLoading> createState() => _TennisLoadingState();
}

class _TennisLoadingState extends State<TennisLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
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
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: TennisBallPainter(
            progress: _animation.value,
            color: widget.color ?? const Color(0xFF10B981),
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class TennisBallPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  TennisBallPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    // Tennis ball outline
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw tennis ball circle
    canvas.drawCircle(center, radius, paint);

    // Draw tennis ball curve
    final path = Path();
    final curveOffset = radius * 0.3 * (1 - progress);
    
    path.moveTo(center.dx - radius, center.dy);
    path.quadraticBezierTo(
      center.dx,
      center.dy - curveOffset,
      center.dx + radius,
      center.dy,
    );
    
    canvas.drawPath(path, paint);

    // Draw bouncing effect
    final bounceOffset = radius * 0.1 * (1 - (progress * 2 - 1).abs());
    final bounceCenter = Offset(center.dx, center.dy - bounceOffset);
    
    canvas.drawCircle(bounceCenter, radius * 0.1, paint);
  }

  @override
  bool shouldRepaint(TennisBallPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
