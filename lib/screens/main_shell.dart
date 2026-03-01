import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/services/clipboard_service.dart';
import '../core/services/notification_service.dart';
import 'dashboard/dashboard_screen.dart';
import 'rekap/rekap_screen.dart';
import 'investasi/investasi_screen.dart';
import 'profil/profil_screen.dart';
import 'input/input_transaction_screen.dart';
import 'scan_receipt/scan_receipt_screen.dart';
import 'clipboard_guardian/clipboard_guardian_dialog.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isFabExpanded = false;

  // Clipboard Guardian state
  String? _lastCheckedPhone;
  String? _detectedPhone;
  bool _showNotification = false;
  late final AnimationController _notifAnimController;
  late final Animation<Offset> _notifSlideAnim;

  late final AnimationController _fabAnimController;
  late final Animation<double> _fabScaleAnim;

  final _screens = const [
    DashboardScreen(),
    RekapScreen(),
    InvestasiScreen(),
    ProfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fabScaleAnim = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.easeOutBack,
    );

    _notifAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _notifSlideAnim =
        Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _notifAnimController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Set up notification tap handler
    NotificationService.onNotificationTap = _onRealNotificationTap;

    // Check clipboard on first launch too
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkClipboard());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fabAnimController.dispose();
    _notifAnimController.dispose();
    NotificationService.onNotificationTap = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    final phone = await ClipboardService.checkForPhoneNumber();
    if (phone != null && phone != _lastCheckedPhone && mounted) {
      _lastCheckedPhone = phone;
      setState(() {
        _detectedPhone = phone;
        _showNotification = true;
      });
      _notifAnimController.forward();

      // Also send a real Android notification
      await NotificationService.showGuardianAlert(phoneNumber: phone);

      // Auto-dismiss in-app banner after 6 seconds
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted && _showNotification && _detectedPhone == phone) {
          _dismissNotification();
        }
      });
    }
  }

  void _onRealNotificationTap(String? payload) {
    if (payload != null && mounted) {
      _dismissNotification();
      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (_) => ClipboardGuardianDialog(vaNumber: payload),
      );
    }
  }

  void _dismissNotification() {
    _notifAnimController.reverse().then((_) {
      if (mounted) setState(() => _showNotification = false);
    });
  }

  void _onNotificationTap() {
    final phone = _detectedPhone;
    _dismissNotification();
    if (phone != null) {
      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (_) => ClipboardGuardianDialog(vaNumber: phone),
      );
    }
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabAnimController.forward();
      } else {
        _fabAnimController.reverse();
      }
    });
  }

  void _collapseFab() {
    if (_isFabExpanded) {
      setState(() => _isFabExpanded = false);
      _fabAnimController.reverse();
    }
  }

  void _onNavTap(int index) {
    _collapseFab();
    setState(() => _currentIndex = index);
  }

  void _openInputManual() {
    _collapseFab();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const InputTransactionScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _openScanReceipt() {
    _collapseFab();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ScanReceiptScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),

          if (_isFabExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _collapseFab,
                child: AnimatedBuilder(
                  animation: _fabScaleAnim,
                  builder: (_, __) => Container(
                    color: Colors.black.withValues(
                      alpha: 0.4 * _fabScaleAnim.value,
                    ),
                  ),
                ),
              ),
            ),

          if (_isFabExpanded)
            Positioned(
              bottom: 90,
              left: 0,
              right: 0,
              child: ScaleTransition(
                scale: _fabScaleAnim,
                child: FadeTransition(
                  opacity: _fabScaleAnim,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FabOption(
                        icon: Icons.edit,
                        label: 'Manual',
                        onTap: _openInputManual,
                      ),
                      const SizedBox(width: 24),
                      _FabOption(
                        icon: Icons.qr_code_scanner,
                        label: 'Scan Struk',
                        onTap: _openScanReceipt,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // In-app notification banner
          if (_showNotification)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _notifSlideAnim,
                child: _buildNotificationBanner(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNotificationBanner() {
    final lastFour = _detectedPhone != null && _detectedPhone!.length >= 4
        ? _detectedPhone!.substring(_detectedPhone!.length - 4)
        : _detectedPhone ?? '';

    return SafeArea(
      bottom: false,
      child: GestureDetector(
        onTap: _onNotificationTap,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            _dismissNotification();
          }
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1644),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TAMPAR Guardian',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const Spacer(),
                        Text(
                          'baru saja',
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nomor ...$lastFour terdeteksi! Duit lu sisa tipis. Yakin mau checkout? 💀',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFFCBD5E1),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: _toggleFab,
      child: AnimatedBuilder(
        animation: _fabAnimController,
        builder: (_, __) {
          final rotation = _fabAnimController.value * 0.125;
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: RotationTransition(
              turns: AlwaysStoppedAnimation(rotation),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => _onNavTap(0),
                ),
                _NavItem(
                  icon: Icons.pie_chart_rounded,
                  label: 'Rekap',
                  isActive: _currentIndex == 1,
                  onTap: () => _onNavTap(1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 56),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Invest',
                  isActive: _currentIndex == 2,
                  onTap: () => _onNavTap(2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: _currentIndex == 3,
                  onTap: () => _onNavTap(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSub;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FabOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _FabOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
