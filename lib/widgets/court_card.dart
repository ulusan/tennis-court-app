import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/court.dart';
import '../screens/court_availability_screen.dart';
import '../providers/availability_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/court_provider.dart';
import '../providers/reservation_provider.dart';

class CourtCard extends StatefulWidget {
  final Court court;
  final Duration animationDelay;

  const CourtCard({
    super.key,
    required this.court,
    this.animationDelay = Duration.zero,
  });

  @override
  State<CourtCard> createState() => _CourtCardState();
}

class _CourtCardState extends State<CourtCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 32 : 28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/court-details',
                      arguments: widget.court,
                    );
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 32 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isTablet ? 20 : 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.sports_tennis,
                                color: Colors.white,
                                size: isTablet ? 28 : 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.court.name,
                                    style: TextStyle(
                                      fontSize: isTablet ? 28 : 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.court.location,
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.court.isAvailable 
                                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.court.isAvailable 
                                      ? const Color(0xFF4CAF50)
                                      : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.court.isAvailable ? 'Müsait' : 'Dolu',
                                style: TextStyle(
                                  color: widget.court.isAvailable 
                                      ? const Color(0xFF4CAF50)
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Court Details
                        Row(
                          children: [
                            _buildDetailItem(
                              Icons.terrain,
                              'Zemin',
                              'Beton',
                              const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 24),
                            _buildDetailItem(
                              Icons.people,
                              'Kapasite',
                              '4 kişi',
                              const Color(0xFF10B981),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: isTablet ? 64 : 56,
                                decoration: BoxDecoration(
                                  gradient: widget.court.isAvailable
                                      ? const LinearGradient(
                                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: widget.court.isAvailable ? [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ] : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: widget.court.isAvailable
                                        ? () {
                                            Navigator.pushNamed(
                                              context,
                                              '/court-details',
                                              arguments: widget.court,
                                            );
                                          }
                                        : null,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Center(
                                      child: Text(
                                        widget.court.isAvailable ? 'Rezervasyon Yap' : 'Müsait Değil',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: isTablet ? 64 : 56,
                              height: isTablet ? 64 : 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    print('Müsaitlik butonuna tıklandı!');
                                    print('Court ID: ${widget.court.id}');
                                    print('Court Name: ${widget.court.name}');
                                    
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MultiProvider(
                                          providers: [
                                            ChangeNotifierProvider(create: (_) => AuthProvider()),
                                            ChangeNotifierProvider(create: (_) => CourtProvider()),
                                            ChangeNotifierProvider(create: (_) => ReservationProvider()),
                                            ChangeNotifierProvider(create: (_) => AvailabilityProvider()),
                                          ],
                                          child: CourtAvailabilityScreen(court: widget.court),
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: Icon(
                                      Icons.schedule,
                                      color: const Color(0xFF10B981),
                                      size: isTablet ? 24 : 20,
                                    ),
                                  ),
                                ),
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
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

}