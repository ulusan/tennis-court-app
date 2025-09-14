import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/availability_provider.dart';
import '../models/reservation.dart';
import '../widgets/tennis_loading.dart';
import '../widgets/cancellation_dialog.dart';
import '../utils/toast.dart';
import '../utils/date_utils.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isLoggedIn && authProvider.user != null) {
        context.read<ReservationProvider>().loadUserReservations(authProvider.user!.id);
      }
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;
    final isSmallScreen = screenHeight < 700;

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
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
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
                                Icons.calendar_today,
                                color: Colors.white,
                                size: isTablet ? 32 : 28,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Rezervasyonlarım',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 40 : 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Geçmiş ve gelecek rezervasyonlarınız',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: isTablet ? 20 : 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  final authProvider = context.read<AuthProvider>();
                                  if (authProvider.isLoggedIn && authProvider.user != null) {
                                    context.read<ReservationProvider>().loadUserReservations(authProvider.user!.id);
                                  }
                                },
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 24,
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
            
            // Tab Bar
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  isTablet ? 32 : 24,
                  isTablet ? 24 : 16,
                  isTablet ? 32 : 24,
                  isTablet ? 16 : 12,
                ),
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
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.all(isTablet ? 8 : 6),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Aktif'),
                    Tab(text: 'Geçmiş'),
                    Tab(text: 'İptal'),
                  ],
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height - 400,
                margin: EdgeInsets.fromLTRB(
                  isTablet ? 32 : 24,
                  0,
                  isTablet ? 32 : 24,
                  isTablet ? 32 : 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReservationsList('active'),
                    _buildReservationsList('past'),
                    _buildReservationsList('cancelled'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(String type) {
    return Consumer<ReservationProvider>(
      builder: (context, reservationProvider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        
        List<Reservation> reservations = [];
        
        switch (type) {
          case 'active':
            // Aktif: Gelecek tarihli confirmed rezervasyonlar
            reservations = reservationProvider.reservations
                .where((r) => 
                  r.status == ReservationStatus.confirmed && 
                  r.dateTime.isAfter(AppDateUtils.getToday())
                )
                .toList();
            break;
          case 'past':
            // Geçmiş: Geçmiş tarihli confirmed rezervasyonlar
            reservations = reservationProvider.reservations
                .where((r) => 
                  r.status == ReservationStatus.confirmed && 
                  r.dateTime.isBefore(AppDateUtils.getToday())
                )
                .toList();
            break;
          case 'cancelled':
            // İptal: cancelled olanlar (tüm tarihler)
            reservations = reservationProvider.reservations
                .where((r) => r.status == ReservationStatus.cancelled)
                .toList();
            break;
        }

        if (reservationProvider.isLoading) {
          return const Center(
            child: TennisLoading(
              size: 50,
            ),
          );
        }

        if (reservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'active' ? Icons.event_available :
                  type == 'past' ? Icons.history : Icons.cancel_outlined,
                  size: isTablet ? 80 : 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  type == 'active' ? 'Aktif Rezervasyon Yok' :
                  type == 'past' ? 'Geçmiş Rezervasyon Yok' : 'İptal Edilen Rezervasyon Yok',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  type == 'active' ? 'Henüz aktif rezervasyonunuz bulunmuyor' :
                  type == 'past' ? 'Geçmiş rezervasyonunuz bulunmuyor' : 'İptal edilen rezervasyonunuz bulunmuyor',
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

        return ListView.builder(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final reservation = reservations[index];
            return _buildReservationCard(reservation, isTablet);
          },
        );
      },
    );
  }

  Widget _buildReservationCard(Reservation reservation, bool isTablet) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (reservation.status) {
      case ReservationStatus.confirmed:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        statusText = 'Onaylandı';
        break;
      case ReservationStatus.cancelled:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        statusText = 'İptal Edildi';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Bilinmiyor';
    }

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: isTablet ? 24 : 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.court.name,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      reservation.court.location,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.calendar_today,
                  'Tarih',
                  '${reservation.dateTime.day}/${reservation.dateTime.month}/${reservation.dateTime.year}',
                  isTablet,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.access_time,
                  'Saat',
                  '${reservation.dateTime.hour.toString().padLeft(2, '0')}:${reservation.dateTime.minute.toString().padLeft(2, '0')}',
                  isTablet,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.schedule,
                  'Süre',
                                  '${reservation.durationInMinutes} dk',
                  isTablet,
                ),
              ),
            ],
          ),
          
          // Notes
          if (reservation.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: isTablet ? 20 : 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reservation.notes ?? '',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Actions - Sadece confirmed olan gelecek tarihli rezervasyonlar iptal edilebilir
          if (reservation.status == ReservationStatus.confirmed && 
              reservation.dateTime.isAfter(AppDateUtils.getToday())) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showCancelDialog(reservation);
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Rezervasyonu İptal Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          
          // İptal sebebi gösterimi
          if (reservation.isCancelled && reservation.cancellationReason != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.red.shade600,
                        size: isTablet ? 20 : 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'İptal Sebebi',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reservation.cancellationReason!,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.red.shade600,
                    ),
                  ),
                  if (reservation.cancelledAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'İptal Tarihi: ${reservation.cancelledAt!.day}/${reservation.cancelledAt!.month}/${reservation.cancelledAt!.year} ${reservation.cancelledAt!.hour.toString().padLeft(2, '0')}:${reservation.cancelledAt!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: Colors.red.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, bool isTablet) {
    return Column(
      children: [
        Icon(
          icon,
          size: isTablet ? 20 : 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => CancellationDialog(
        reservationId: reservation.id,
        courtName: reservation.courtName,
        startTime: reservation.startTime,
      ),
    ).then((cancellationReason) async {
      if (cancellationReason != null) {
        final success = await context.read<ReservationProvider>().cancelReservation(
          reservation.id,
          cancellationReason: cancellationReason,
        );
        
        if (success) {
          Toast.success(context, 'Rezervasyon başarıyla iptal edildi');
          
          // Availability'yi yeniden yükle (eğer court availability screen açıksa)
          try {
            await context.read<AvailabilityProvider>().refreshAfterCancellation(
              reservation.court.id,
              DateTime(reservation.startTime.year, reservation.startTime.month, reservation.startTime.day),
            );
          } catch (e) {
            // Availability yüklenemezse sessizce devam et
            print('Availability yeniden yüklenemedi: $e');
          }
        } else {
          Toast.error(context, 'Rezervasyon iptal edilirken hata oluştu');
        }
      }
    });
  }
}