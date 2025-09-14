import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/court.dart';
import '../models/court_availability.dart';
import '../providers/availability_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/court_provider.dart';
import '../../reservation/providers/reservation_provider.dart';
import '../../reservation/screens/reservation_screen.dart';
import '../../../core/widgets/tennis_loading.dart';
import '../../../core/utils/name_blur.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/court_map_widget.dart';

class CourtAvailabilityScreen extends StatefulWidget {
  final Court court;

  const CourtAvailabilityScreen({super.key, required this.court});

  @override
  State<CourtAvailabilityScreen> createState() =>
      _CourtAvailabilityScreenState();
}

class _CourtAvailabilityScreenState extends State<CourtAvailabilityScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      // Müsaitlik verilerini yükle
      context.read<AvailabilityProvider>().loadCourtAvailability(
        widget.court.id,
        AppDateUtils.getToday(),
      );
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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer<AvailabilityProvider>(
        builder: (context, availabilityProvider, child) {
          return CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: isTablet ? 200 : 160,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF10B981),
                          Color(0xFF059669),
                          Color(0xFF047857),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 24 : 20,
                        MediaQuery.of(context).padding.top +
                            (isTablet ? 16 : 12),
                        isTablet ? 24 : 20,
                        isTablet ? 16 : 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isTablet ? 16 : 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.schedule,
                                  color: Colors.white,
                                  size: isTablet ? 32 : 28,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Müsaitlik Durumu',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 32 : 24,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.court.name,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: isTablet ? 18 : 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildContent(availabilityProvider, isTablet),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    AvailabilityProvider availabilityProvider,
    bool isTablet,
  ) {
    if (availabilityProvider.isLoading) {
      return const Center(child: TennisLoading());
    }

    if (availabilityProvider.error != null) {
      return _buildErrorWidget(availabilityProvider.error!);
    }

    final availability = availabilityProvider.currentAvailability;
    if (availability == null) {
      return _buildNoDataWidget(isTablet);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kort Detay Bilgileri
        _buildCourtDetailsSection(isTablet),
        const SizedBox(height: 16),

        // Tarih Seçici
        _buildDateSelector(availability, isTablet),
        const SizedBox(height: 16),

        // Özet Kartları
        _buildSummaryCards(availability, isTablet),
        const SizedBox(height: 16),

        // Müsaitlik Zamanları
        _buildTimeSlotsSection(availability, isTablet),
        const SizedBox(height: 16),

        // Rezervasyon Butonu
        _buildReservationButton(availability, isTablet),
      ],
    );
  }

  Widget _buildNoDataWidget(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 48 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            size: isTablet ? 80 : 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Müsaitlik Verisi Bulunamadı',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bu kort için henüz müsaitlik bilgisi mevcut değil.',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(CourtAvailability availability, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: const Color(0xFF10B981),
            size: isTablet ? 24 : 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Tarih: ${_formatDate(availability.date)}',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getDayName(availability.date),
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationButton(
    CourtAvailability availability,
    bool isTablet,
  ) {
    final availableSlots = availability.availableSlots;
    final hasAvailableSlots = availableSlots.isNotEmpty;

    return Container(
      width: double.infinity,
      height: isTablet ? 64 : 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Rezervasyon sayfasına yönlendir - her zaman tıklanabilir
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) => AuthProvider()),
                    ChangeNotifierProvider(create: (_) => CourtProvider()),
                    ChangeNotifierProvider(
                      create: (_) => ReservationProvider(),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => AvailabilityProvider(),
                    ),
                  ],
                  child: ReservationScreen(court: widget.court),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasAvailableSlots ? Icons.add_circle_outline : Icons.schedule,
                  color: Colors.white,
                  size: isTablet ? 24 : 20,
                ),
                const SizedBox(width: 8),
                Text(
                  hasAvailableSlots
                      ? 'Rezervasyon Yap (${availableSlots.length} müsait saat)'
                      : 'Rezervasyon Yap (Farklı tarih seçin)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = AppDateUtils.getToday();
    final today = now;
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Bugün (${date.day}/${date.month}/${date.year})';
    } else if (targetDate == tomorrow) {
      return 'Yarın (${date.day}/${date.month}/${date.year})';
    } else if (targetDate == yesterday) {
      return 'Dün (${date.day}/${date.month}/${date.year})';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getDayName(DateTime date) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days[date.weekday - 1];
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Hata Oluştu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(CourtAvailability availability, bool isTablet) {
    final availableCount = availability.availableSlots.length;
    final reservedCount = availability.reservedSlots.length;
    final totalCount = availability.timeSlots.length;
    final percentage = totalCount > 0
        ? (reservedCount / totalCount * 100).round()
        : 0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Müsait',
            availableCount.toString(),
            const Color(0xFF4CAF50),
            Icons.check_circle,
            isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Rezerve',
            reservedCount.toString(),
            const Color(0xFFF44336),
            Icons.person,
            isTablet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Doluluk',
            '%$percentage',
            const Color(0xFF10B981),
            Icons.pie_chart,
            isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isTablet ? 32 : 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsSection(CourtAvailability availability, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saatlik Müsaitlik Durumu',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availability.timeSlots.map((slot) {
                return _buildTimeSlotCard(slot, isTablet);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot, bool isTablet) {
    final color = _getStatusColor(slot.status);
    final isAvailable = slot.isAvailable;

    return Container(
      width: (MediaQuery.of(context).size.width - 72) / 2,
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isAvailable
            ? color.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? color : Colors.grey.shade300,
          width: isAvailable ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(slot.status),
                color: color,
                size: isTablet ? 20 : 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  slot.statusText,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${slot.startTime.format(context)} - ${slot.endTime.format(context)}',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),

          if (slot.notes != null) ...[
            const SizedBox(height: 4),
            Text(
              slot.notes!,
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return const Color(0xFF4CAF50);
      case AvailabilityStatus.reserved:
        return const Color(0xFFF44336);
      case AvailabilityStatus.maintenance:
        return const Color(0xFFFF9800);
      case AvailabilityStatus.closed:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getStatusIcon(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return Icons.check_circle;
      case AvailabilityStatus.reserved:
        return Icons.person;
      case AvailabilityStatus.maintenance:
        return Icons.build;
      case AvailabilityStatus.closed:
        return Icons.block;
    }
  }

  // Kort Detay Bilgileri Section
  Widget _buildCourtDetailsSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_tennis,
                color: const Color(0xFF10B981),
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.court.name,
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.court.location,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Kort Özellikleri
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip(
                'Zemin: ${_getSurfaceTypeText(widget.court.surfaceType)}',
                Icons.texture,
                isTablet,
              ),
              _buildFeatureChip(
                'Kapasite: ${widget.court.capacity} kişi',
                Icons.people,
                isTablet,
              ),
              _buildFeatureChip(
                'Puan: ${widget.court.rating.toStringAsFixed(1)}',
                Icons.star,
                isTablet,
              ),
              if (widget.court.hourlyRate > 0)
                _buildFeatureChip(
                  'Saatlik: ₺${widget.court.hourlyRate.toStringAsFixed(0)}',
                  Icons.attach_money,
                  isTablet,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Özellik Chip Widget
  Widget _buildFeatureChip(String label, IconData icon, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 16 : 14, color: const Color(0xFF10B981)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  // Zemin tipi metni
  String _getSurfaceTypeText(SurfaceType surfaceType) {
    switch (surfaceType) {
      case SurfaceType.clay:
        return 'Toprak';
      case SurfaceType.hard:
        return 'Sert';
      case SurfaceType.grass:
        return 'Çim';
    }
  }
}
