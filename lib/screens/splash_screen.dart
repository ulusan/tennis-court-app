import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _tennisBallController;
  late AnimationController _racketController;
  
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _tennisBallAnimation;
  late Animation<double> _racketAnimation;
  late Animation<Offset> _tennisBallPosition;
  late Animation<Offset> _racketPosition;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSplashSequence();
  }

  void _setupAnimations() {
    // Logo animasyonu
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Text animasyonu
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Tenis topu animasyonu
    _tennisBallController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _tennisBallAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tennisBallController,
      curve: Curves.bounceOut,
    ));
    _tennisBallPosition = Tween<Offset>(
      begin: const Offset(-0.3, 0.0),
      end: const Offset(0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: _tennisBallController,
      curve: Curves.easeInOut,
    ));

    // Raket animasyonu
    _racketController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _racketAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _racketController,
      curve: Curves.easeOut,
    ));
    _racketPosition = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: _racketController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Logo animasyonunu başlat
    await _logoController.forward();
    
    // Text animasyonunu başlat
    await _textController.forward();
    
    // Tenis topu ve raket animasyonlarını başlat
    _tennisBallController.forward();
    _racketController.forward();
    
    // Auth durumunu kontrol et
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.initialize();
      
      if (mounted) {
        if (authProvider.isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _tennisBallController.dispose();
    _racketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981), // Tennis green
              Color(0xFF059669), // Darker green
              Color(0xFF047857), // Forest green
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Arka plan tenis kortu çizgileri
            _buildTennisCourtBackground(),
            
            // Ana içerik
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ve animasyonlar
                  SizedBox(
                    height: screenHeight * 0.4,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Tenis topu
                        AnimatedBuilder(
                          animation: _tennisBallController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                _tennisBallPosition.value.dx * screenWidth * 0.3,
                                _tennisBallPosition.value.dy * screenHeight * 0.1,
                              ),
                              child: Transform.scale(
                                scale: _tennisBallAnimation.value,
                                child: _buildTennisBall(),
                              ),
                            );
                          },
                        ),
                        
                        // Raket
                        AnimatedBuilder(
                          animation: _racketController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                _racketPosition.value.dx * screenWidth * 0.3,
                                _racketPosition.value.dy * screenHeight * 0.1,
                              ),
                              child: Transform.scale(
                                scale: _racketAnimation.value,
                                child: _buildTennisRacket(),
                              ),
                            );
                          },
                        ),
                        
                        // Ana logo
                        AnimatedBuilder(
                          animation: _logoAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoAnimation.value,
                              child: Container(
                                width: isTablet ? 120 : 100,
                                height: isTablet ? 120 : 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.sports_tennis,
                                  size: isTablet ? 60 : 50,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Uygulama adı
                  AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - _textAnimation.value)),
                        child: Opacity(
                          opacity: _textAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                'TENIS KORTU',
                                style: TextStyle(
                                  fontSize: isTablet ? 36 : 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rezervasyon Sistemi',
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textAnimation.value,
                        child: Column(
                          children: [
                            SizedBox(
                              width: isTablet ? 40 : 30,
                              height: isTablet ? 40 : 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Yükleniyor...',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTennisCourtBackground() {
    return CustomPaint(
      painter: TennisCourtPainter(),
      size: Size.infinite,
    );
  }

  Widget _buildTennisBall() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: TennisBallPainter(),
      ),
    );
  }

  Widget _buildTennisRacket() {
    return Container(
      width: 40,
      height: 50,
      child: CustomPaint(
        painter: TennisRacketPainter(),
      ),
    );
  }
}

class TennisCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Kort çizgileri
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final courtWidth = size.width * 0.6;
    final courtHeight = size.height * 0.4;

    // Ana kort çerçevesi
    final courtRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: courtWidth,
      height: courtHeight,
    );
    canvas.drawRect(courtRect, paint);

    // Orta çizgi
    canvas.drawLine(
      Offset(centerX, courtRect.top),
      Offset(centerX, courtRect.bottom),
      paint,
    );

    // Servis çizgileri
    final serviceLineY = centerY;
    canvas.drawLine(
      Offset(courtRect.left, serviceLineY),
      Offset(courtRect.right, serviceLineY),
      paint,
    );

    // Servis kutuları
    final serviceBoxWidth = courtWidth / 4;
    final serviceBoxHeight = courtHeight / 2;

    // Sol üst servis kutusu
    canvas.drawRect(
      Rect.fromLTWH(
        courtRect.left,
        courtRect.top,
        serviceBoxWidth,
        serviceBoxHeight,
      ),
      paint,
    );

    // Sağ üst servis kutusu
    canvas.drawRect(
      Rect.fromLTWH(
        courtRect.right - serviceBoxWidth,
        courtRect.top,
        serviceBoxWidth,
        serviceBoxHeight,
      ),
      paint,
    );

    // Sol alt servis kutusu
    canvas.drawRect(
      Rect.fromLTWH(
        courtRect.left,
        courtRect.top + serviceBoxHeight,
        serviceBoxWidth,
        serviceBoxHeight,
      ),
      paint,
    );

    // Sağ alt servis kutusu
    canvas.drawRect(
      Rect.fromLTWH(
        courtRect.right - serviceBoxWidth,
        courtRect.top + serviceBoxHeight,
        serviceBoxWidth,
        serviceBoxHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TennisBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade600
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Tenis topu çizgileri
    canvas.drawCircle(center, radius, paint);
    
    // Tenis topu eğrisi
    final path = Path();
    path.moveTo(center.dx - radius * 0.7, center.dy);
    path.quadraticBezierTo(
      center.dx,
      center.dy - radius * 0.3,
      center.dx + radius * 0.7,
      center.dy,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TennisRacketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Raket kafası
    final headRect = Rect.fromCenter(
      center: Offset(centerX, centerY - 5),
      width: 25,
      height: 20,
    );
    canvas.drawOval(headRect, paint);
    canvas.drawOval(headRect, strokePaint);

    // Raket telleri
    final stringPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 0.5;

    // Dikey teller
    for (int i = 0; i < 3; i++) {
      final x = headRect.left + (headRect.width / 3) * (i + 1);
      canvas.drawLine(
        Offset(x, headRect.top),
        Offset(x, headRect.bottom),
        stringPaint,
      );
    }

    // Yatay teller
    for (int i = 0; i < 2; i++) {
      final y = headRect.top + (headRect.height / 2) * (i + 1);
      canvas.drawLine(
        Offset(headRect.left, y),
        Offset(headRect.right, y),
        stringPaint,
      );
    }

    // Raket sapı
    final handleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 8),
        width: 4,
        height: 15,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(handleRect, paint);
    canvas.drawRRect(handleRect, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
