import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CancellationDialog extends StatefulWidget {
  final String reservationId;
  final String courtName;
  final DateTime startTime;

  const CancellationDialog({
    super.key,
    required this.reservationId,
    required this.courtName,
    required this.startTime,
  });

  @override
  State<CancellationDialog> createState() => _CancellationDialogState();
}

class _CancellationDialogState extends State<CancellationDialog>
    with TickerProviderStateMixin {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  // Default iptal sebepleri
  final List<String> _defaultReasons = [
    'Hastalık',
    'İş durumu',
    'Hava durumu',
    'Acil durum',
    'Plan değişikliği',
    'Ulaşım sorunu',
    'Diğer',
  ];
  
  String? _selectedReason;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
              ),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                  color: Colors.white,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isTablet),
                      const SizedBox(height: 24),
                      _buildReservationInfo(isTablet),
                      const SizedBox(height: 24),
                      _buildReasonField(isTablet),
                      const SizedBox(height: 32),
                      _buildActionButtons(isTablet),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
          child: Icon(
            Icons.cancel_outlined,
            color: const Color(0xFFEF4444),
            size: isTablet ? 32 : 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rezervasyonu İptal Et',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bu işlem geri alınamaz',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReservationInfo(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rezervasyon Detayları',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.sports_tennis,
                color: const Color(0xFF10B981),
                size: isTablet ? 20 : 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.courtName,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: const Color(0xFF10B981),
                size: isTablet ? 20 : 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.startTime.day}/${widget.startTime.month}/${widget.startTime.year} ${widget.startTime.hour.toString().padLeft(2, '0')}:${widget.startTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasonField(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İptal Sebebi',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        
        // Default sebepler
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _defaultReasons.map((reason) {
            final isSelected = _selectedReason == reason;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedReason = reason;
                  if (reason != 'Diğer') {
                    _reasonController.text = reason;
                  } else {
                    _reasonController.clear();
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF10B981)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF10B981)
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  reason,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Özel sebep alanı (sadece "Diğer" seçildiğinde görünür)
        if (_selectedReason == 'Diğer') ...[
          Text(
            'Özel Sebep',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _reasonController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'İptal sebebinizi belirtin...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
              ),
              contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
            ),
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Text(
              'İptal',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _confirmCancellation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
              elevation: 0,
            ),
            child: Text(
              'İptal Et',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmCancellation() {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    String cancellationReason;
    
    if (_selectedReason != null && _selectedReason != 'Diğer') {
      // Default sebep seçildi
      cancellationReason = _selectedReason!;
    } else if (_selectedReason == 'Diğer' && _reasonController.text.trim().isNotEmpty) {
      // Özel sebep yazıldı
      cancellationReason = _reasonController.text.trim();
    } else {
      // Hiçbir sebep seçilmedi
      cancellationReason = 'Kullanıcı tarafından iptal edildi';
    }
    
    // Dialog'u kapat ve sebebi döndür
    Navigator.pop(context, cancellationReason);
  }
}
