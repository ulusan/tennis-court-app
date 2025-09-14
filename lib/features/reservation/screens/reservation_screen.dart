import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reservation.dart';
import '../../court/models/court.dart';
import '../providers/reservation_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../court/providers/availability_provider.dart';
import '../services/reservation_service.dart';
import '../../../core/widgets/tennis_loading.dart';
import '../../../core/utils/toast.dart';
import '../../../core/utils/date_utils.dart';

class ReservationScreen extends StatefulWidget {
  final Court court;

  const ReservationScreen({super.key, required this.court});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  List<TimeOfDay> _availableTimeSlots = [];
  Map<String, bool> _timeSlotAvailability = {}; // Saat slot durumları
  bool _isLoadingAvailability = false;
  final ReservationService _reservationService = ReservationService();

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
      _selectedDate = AppDateUtils.getToday();
      _generateTimeSlots();
      _checkTimeSlotAvailability(); // İlk yüklemede saat slotlarını kontrol et
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
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
                    MediaQuery.of(context).padding.top + (isTablet ? 16 : 12),
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
                              Icons.add_circle_outline,
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
                                  'Rezervasyon Yap',
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
                                    color: Colors.white.withValues(alpha: 0.9),
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
                      child: _buildContent(isTablet),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Court Info Card
        _buildCourtInfoCard(isTablet),
        const SizedBox(height: 24),

        // Date Selection
        _buildDateSelectionCard(isTablet),
        const SizedBox(height: 24),

        // Time Selection
        _buildTimeSelectionCard(isTablet),
        const SizedBox(height: 24),

        // Notes
        _buildNotesCard(isTablet),
        const SizedBox(height: 32),

        // Create Reservation Button
        _buildCreateReservationButton(isTablet),
      ],
    );
  }

  Widget _buildCourtInfoCard(bool isTablet) {
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
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.court.location,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: Colors.grey.shade600,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                'Zemin: ${_getSurfaceTypeText(widget.court.surfaceType)}',
                Icons.texture,
                isTablet,
              ),
              _buildInfoChip(
                'Kapasite: ${widget.court.capacity} kişi',
                Icons.people,
                isTablet,
              ),
              if (widget.court.hourlyRate > 0)
                _buildInfoChip(
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

  Widget _buildInfoChip(String label, IconData icon, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 16 : 14, color: const Color(0xFF10B981)),
          const SizedBox(width: 4),
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

  Widget _buildDateSelectionCard(bool isTablet) {
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
          Text(
            'Tarih Seçin',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: const Color(0xFF10B981),
                    size: isTablet ? 20 : 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate != null
                        ? AppDateUtils.formatDate(_selectedDate!)
                        : 'Tarih seçin',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: _selectedDate != null
                          ? Colors.grey.shade800
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelectionCard(bool isTablet) {
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
          Text(
            'Saat Seçin',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          // Otomatik saat slotları
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableTimeSlots.map((timeSlot) {
              final isSelected = _selectedStartTime == timeSlot;
              return _buildTimeSlotChip(timeSlot, isSelected, isTablet);
            }).toList(),
          ),
          if (_selectedStartTime != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: const Color(0xFF10B981),
                    size: isTablet ? 20 : 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Seçilen Saat: ${_formatTime(_selectedStartTime!)} - ${_formatTime(_getEndTime(_selectedStartTime!))}',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlotChip(TimeOfDay timeSlot, bool isSelected, bool isTablet) {
    final endTime = _getEndTime(timeSlot);
    final timeKey = '${timeSlot.hour}:${timeSlot.minute.toString().padLeft(2, '0')}';
    final isAvailable = _timeSlotAvailability[timeKey] ?? true; // Varsayılan olarak müsait
    final isReserved = !isAvailable;
    
    return GestureDetector(
      onTap: isReserved || _isLoadingAvailability ? null : () {
        setState(() {
          _selectedStartTime = timeSlot;
          _selectedEndTime = endTime;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: isReserved 
              ? Colors.grey.shade100
              : isSelected 
                  ? const Color(0xFF10B981)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReserved 
                ? Colors.grey.shade300
                : isSelected 
                    ? const Color(0xFF10B981)
                    : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatTime(timeSlot)} - ${_formatTime(endTime)}',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: isReserved 
                          ? Colors.grey.shade600
                          : isSelected 
                              ? Colors.white
                              : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeOfDayLabel(timeSlot),
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w400,
                      color: isReserved 
                          ? Colors.grey.shade500
                          : isSelected 
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.grey.shade600,
                    ),
                  ),
                  if (isReserved) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Dolu',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                  if (_isLoadingAvailability) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Kontrol ediliyor...',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getTimeOfDayLabel(TimeOfDay time) {
    if (time.hour >= 6 && time.hour < 12) {
      return '(Sabah)';
    } else if (time.hour >= 12 && time.hour < 17) {
      return '(Öğleden Sonra)';
    } else {
      return '(Akşam)';
    }
  }

  Widget _buildNotesCard(bool isTablet) {
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
          Text(
            'Notlar (İsteğe bağlı)',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Rezervasyonunuz hakkında notlar...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
              ),
              contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
            ),
            style: TextStyle(fontSize: isTablet ? 16 : 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateReservationButton(bool isTablet) {
    return Consumer<ReservationProvider>(
      builder: (context, reservationProvider, child) {
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
              onTap: _canCreateReservation() && !reservationProvider.isLoading
                  ? _createReservation
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: reservationProvider.isLoading
                    ? const TennisLoading(
                        size: 24,
                        color: Colors.white,
                      )
                    : Text(
                        'Rezervasyon Oluştur',
                        style: TextStyle(
                          color: _canCreateReservation()
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _canCreateReservation() {
    return _selectedDate != null && _selectedStartTime != null;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? AppDateUtils.getToday(),
      firstDate: AppDateUtils.getToday(),
      lastDate: AppDateUtils.getToday().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedStartTime = null;
        _selectedEndTime = null;
        _timeSlotAvailability.clear();
      });
      // Tarih değiştiğinde saat slotlarını kontrol et
      _checkTimeSlotAvailability();
    }
  }

  void _generateTimeSlots() {
    _availableTimeSlots = [];
    
    // 08:00'dan başlayıp 23:00'a kadar 1.5 saatlik aralıklarla
    final startMinutes = 8 * 60; // 08:00 = 480 dakika
    final endMinutes = 23 * 60; // 23:00 = 1380 dakika
    const slotDuration = 90; // 1.5 saat = 90 dakika

    for (int minutes = startMinutes; minutes <= endMinutes; minutes += slotDuration) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      
      // 24:00'ı geçmemesi için kontrol
      if (hour < 24) {
        _availableTimeSlots.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
  }

  TimeOfDay _getEndTime(TimeOfDay startTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = startMinutes + 90; // 1.5 saat = 90 dakika
    final endHour = (endMinutes ~/ 60) % 24;
    final endMinute = endMinutes % 60;
    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  /// Seçilen tarih için saat slotlarının müsaitlik durumunu kontrol eder
  Future<void> _checkTimeSlotAvailability() async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoadingAvailability = true;
    });

    try {
      // Her saat slotu için müsaitlik kontrolü yap
      for (final timeSlot in _availableTimeSlots) {
        final startDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          timeSlot.hour,
          timeSlot.minute,
        );

        final endTime = _getEndTime(timeSlot);
        
        // Eğer bitiş saati başlangıç saatinden küçükse (ertesi güne geçiyorsa)
        // ertesi güne geçiş yap
        DateTime endDateTime;
        if (endTime.hour < timeSlot.hour || 
            (endTime.hour == timeSlot.hour && endTime.minute < timeSlot.minute)) {
          // Ertesi güne geç
          endDateTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day + 1,
            endTime.hour,
            endTime.minute,
          );
        } else {
          // Aynı gün içinde kal
          endDateTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            endTime.hour,
            endTime.minute,
          );
        }

        final isAvailable = await _reservationService.isTimeSlotAvailable(
          courtId: widget.court.id,
          startTime: startDateTime,
          endTime: endDateTime,
        );

        final timeKey = '${timeSlot.hour}:${timeSlot.minute.toString().padLeft(2, '0')}';
        _timeSlotAvailability[timeKey] = isAvailable;
      }
    } catch (e) {
      print('Error checking time slot availability: $e');
      // Hata durumunda tüm slotları müsait olarak işaretle
      for (final timeSlot in _availableTimeSlots) {
        final timeKey = '${timeSlot.hour}:${timeSlot.minute.toString().padLeft(2, '0')}';
        _timeSlotAvailability[timeKey] = true;
      }
    } finally {
      setState(() {
        _isLoadingAvailability = false;
      });
    }
  }

  Future<void> _createReservation() async {
    if (!_canCreateReservation()) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) {
      Toast.error(context, 'Kullanıcı bilgisi bulunamadı');
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );

    final endTime = _getEndTime(_selectedStartTime!);
    
    // Eğer bitiş saati başlangıç saatinden küçükse (ertesi güne geçiyorsa)
    // ertesi güne geçiş yap
    DateTime endDateTime;
    if (endTime.hour < _selectedStartTime!.hour || 
        (endTime.hour == _selectedStartTime!.hour && endTime.minute < _selectedStartTime!.minute)) {
      // Ertesi güne geç
      endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day + 1,
        endTime.hour,
        endTime.minute,
      );
    } else {
      // Aynı gün içinde kal
      endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        endTime.hour,
        endTime.minute,
      );
    }

    final success = await context.read<ReservationProvider>().createReservation(
      userId: authProvider.user!.id,
      courtId: widget.court.id,
      startTime: startDateTime,
      endTime: endDateTime,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (success) {
      Toast.success(context, 'Rezervasyon başarıyla oluşturuldu');
      Navigator.pop(context);
    } else {
      final error = context.read<ReservationProvider>().error;
      Toast.error(context, error ?? 'Rezervasyon oluşturulamadı');
    }
  }

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
