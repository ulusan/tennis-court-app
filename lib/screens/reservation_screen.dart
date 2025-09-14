import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/court_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/availability_provider.dart';
import '../providers/auth_provider.dart';
import '../models/court.dart';
import '../models/court_availability.dart';
import '../utils/toast.dart';
import '../utils/time_slot_generator.dart' as time_slots;
import '../utils/date_utils.dart';

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

  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _selectedDate = AppDateUtils.getToday();
  time_slots.TimeSlot? _selectedTimeSlot;

  // Zaman slot'ları
  List<time_slots.TimeSlot> _availableTimeSlots = [];
  bool _isLoadingTimeSlots = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _loadTimeSlots();
      
      // Debug tarih bilgisi
      AppDateUtils.debugDate(_selectedDate, 'Selected date on init');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Zaman slot'larını yükle
  void _loadTimeSlots() {
    setState(() {
      _isLoadingTimeSlots = true;
    });
    
    // Availability provider'dan müsaitlik durumunu yükle
    context.read<AvailabilityProvider>().loadCourtAvailability(
      widget.court.id,
      _selectedDate,
    ).then((_) {
      if (mounted) {
        setState(() {
          _isLoadingTimeSlots = false;
        });
      }
    });
  }

  // Tarih değiştiğinde zaman slot'larını yenile
  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _selectedTimeSlot = null; // Seçili zaman slot'unu temizle
    });
    _loadTimeSlots();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Consumer<AvailabilityProvider>(
      builder: (context, availabilityProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFF1F5F9),
                  Color(0xFFE2E8F0),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  expandedHeight: isTablet ? 180 : 140,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  toolbarHeight: 0,
                  leading: Container(
                    margin: EdgeInsets.all(isTablet ? 12 : 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.sports_tennis,
                                    color: Colors.white,
                                    size: isTablet ? 32 : 28,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                          child: _buildContent(availabilityProvider, isTablet),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    AvailabilityProvider availabilityProvider,
    bool isTablet,
  ) {
    if (availabilityProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (availabilityProvider.error != null) {
      return _buildErrorWidget(availabilityProvider.error!);
    }

    final availability = availabilityProvider.currentAvailability;
    if (availability == null) {
      return _buildNoDataWidget(isTablet);
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Court Info Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.sports_tennis,
                        color: Color(0xFF10B981),
                        size: 24,
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
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.court.location,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
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
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '90 dakika tenis oyunu',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Date Selection
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rezervasyon Tarihi',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sadece bugün rezervasyon yapabilirsiniz',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tıklanamaz tarih gösterimi
                      Container(
                        padding: EdgeInsets.all(isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: const Color(0xFF10B981),
                              size: isTablet ? 20 : 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppDateUtils.formatDateTurkish(_selectedDate),
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bugün rezervasyon yapabilirsiniz',
                                    style: TextStyle(
                                      fontSize: isTablet ? 12 : 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'BUGÜN',
                                style: TextStyle(
                                  fontSize: isTablet ? 12 : 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Time Slot Selection
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: const Color(0xFF10B981),
                            size: isTablet ? 20 : 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Zaman Slot Seçimi (1.5 saat)',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_isLoadingTimeSlots)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Consumer<AvailabilityProvider>(
                          builder: (context, availabilityProvider, child) {
                            final timeSlots = availabilityProvider.currentAvailability?.timeSlots ?? [];
                            
                            if (timeSlots.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('Müsaitlik bilgisi bulunamadı'),
                                ),
                              );
                            }

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final screenWidth = constraints.maxWidth;
                                final crossAxisCount = screenWidth > 600 ? 2 : 1;

                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: timeSlots.map((slot) {
                                    final isSelected = _selectedTimeSlot?.startTime == slot.startTime && 
                                                      _selectedTimeSlot?.endTime == slot.endTime;
                                    final isAvailable = slot.isAvailable;

                                    return SizedBox(
                                      width: (screenWidth - 48) / crossAxisCount,
                                      height: 80,
                                      child: InkWell(
                                        onTap: isAvailable ? () {
                                          // TimeSlotGenerator'dan slot oluştur
                                          final timeSlot = time_slots.TimeSlot(
                                            startTime: slot.startTime,
                                            endTime: slot.endTime,
                                            displayText: _formatTimeSlot(slot.startTime, slot.endTime),
                                          );
                                          setState(() {
                                            _selectedTimeSlot = timeSlot;
                                          });
                                        } : null,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF10B981)
                                                : isAvailable
                                                    ? Colors.white
                                                    : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF10B981)
                                                  : isAvailable
                                                      ? Colors.grey.shade300
                                                      : Colors.grey.shade400,
                                              width: isSelected ? 2 : 1,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFF10B981,
                                                      ).withValues(alpha: 0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 12,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _formatTimeSlot(slot.startTime, slot.endTime),
                                                  style: TextStyle(
                                                    fontSize: screenWidth > 600
                                                        ? 16
                                                        : 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : isAvailable
                                                            ? Colors.grey.shade900
                                                            : Colors.grey.shade500,
                                                    letterSpacing: 0.5,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  slot.endTime.format(context),
                                                  style: TextStyle(
                                                    fontSize: screenWidth > 600
                                                        ? 12
                                                        : 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: isSelected
                                                        ? Colors.white.withValues(
                                                            alpha: 0.95,
                                                          )
                                                        : isAvailable
                                                            ? Colors.grey.shade700
                                                            : Colors.grey.shade500,
                                                    letterSpacing: 0.3,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 1,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.white.withValues(
                                                            alpha: 0.25,
                                                          )
                                                        : isAvailable
                                                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                                            : Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Colors.white.withValues(
                                                              alpha: 0.4,
                                                            )
                                                          : isAvailable
                                                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                                              : Colors.grey.shade400,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    isAvailable ? 'Müsait' : (slot.reservedBy != null ? 'Rezerve: ${slot.reservedBy}' : 'Dolu'),
                                                    style: TextStyle(
                                                      fontSize: screenWidth > 600
                                                          ? 9
                                                          : 8,
                                                      fontWeight: FontWeight.w700,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : isAvailable
                                                              ? const Color(0xFF10B981)
                                                              : Colors.grey.shade600,
                                                      letterSpacing: 0.2,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Notes Section
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notlar (İsteğe Bağlı)',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Rezervasyon ile ilgili notlarınızı yazın...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF10B981),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: isTablet ? 64 : 56,
                  decoration: BoxDecoration(
                    gradient: _selectedTimeSlot != null
                        ? const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade400,
                              Colors.grey.shade500,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _selectedTimeSlot != null
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _selectedTimeSlot != null
                          ? _submitReservation
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedTimeSlot != null
                                  ? Icons.check_circle_outline
                                  : Icons.schedule,
                              color: Colors.white,
                              size: isTablet ? 24 : 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTimeSlot != null
                                  ? 'Rezervasyonu Onayla'
                                  : 'Önce bir zaman slot\'u seçin',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  // Tarih seçimi artık gerekli değil - sadece bugün kullanılıyor

  // Time slot'u formatla
  String _formatTimeSlot(TimeOfDay startTime, TimeOfDay endTime) {
    final startStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    
    // Saat aralığına göre etiket
    if (startTime.hour < 12) {
      return '$startStr - $endStr (Sabah)';
    } else if (startTime.hour < 18) {
      return '$startStr - $endStr (Öğleden Sonra)';
    } else {
      return '$startStr - $endStr (Akşam)';
    }
  }

  void _submitReservation() async {
    if (_formKey.currentState!.validate() && _selectedTimeSlot != null) {
      final reservationProvider = context.read<ReservationProvider>();
      final authProvider = context.read<AuthProvider>();

      // Kullanıcı giriş yapmış mı kontrol et
      if (!authProvider.isLoggedIn || authProvider.user == null) {
        Toast.error(context, 'Rezervasyon yapmak için giriş yapmanız gerekiyor');
        return;
      }

      // Kullanıcı ID'sini al
      final userId = authProvider.user!.id;

      // Seçili zaman slot'undan rezervasyon verilerini oluştur
      final reservationData =
          time_slots.TimeSlotGenerator.createReservationData(
            selectedSlot: _selectedTimeSlot!,
            selectedDate: _selectedDate,
            courtId: widget.court.id,
            notes: _notesController.text.trim(),
          );

      final success = await reservationProvider.createReservation(
        userId: userId,
        courtId: widget.court.id,
        startTime: _selectedTimeSlot!.getStartDateTime(_selectedDate),
        endTime: _selectedTimeSlot!.getEndDateTime(_selectedDate),
        notes: _notesController.text.trim(),
      );

      if (success) {
        Toast.success(context, 'Rezervasyon başarıyla oluşturuldu!');
        _loadTimeSlots();
        Navigator.pop(context);
      } else {
        // Provider'dan gelen hata mesajını göster
        final errorMessage = reservationProvider.error ?? 'Rezervasyon oluşturulurken hata oluştu';
        Toast.error(context, errorMessage);
      }
    } else if (_selectedTimeSlot == null) {
      Toast.error(context, 'Lütfen bir zaman slot\'u seçin.');
    }
  }
}