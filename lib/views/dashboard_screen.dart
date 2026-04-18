import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_tab.dart';
import 'studio_tab.dart';
import 'settings_tab.dart';
import '../core/theme/app_theme.dart';
import '../core/engine/display_engine.dart';
import '../logic/haptic_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const StudioTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _tabs[_currentIndex],
            ),
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
                  height: UDE.sp(65, context) + MediaQuery.paddingOf(context).bottom, // Ergonomic Expansion
                  decoration: BoxDecoration(
                    color: const Color(0xFF020202).withOpacity(0.94), 
                    borderRadius: BorderRadius.vertical(top: Radius.circular(UDE.r(24, context))),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Advanced Pinpoint Neon Border
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CurvedNeonPainter(
                            color: themeColor.withOpacity(0.9),
                            radius: UDE.r(24, context),
                          ),
                        ),
                      ).animate(onPlay: (c) => c.repeat()).shimmer(
                        duration: 3500.ms,
                        color: Colors.white.withAlpha(30),
                        angle: 0.0,
                      ),
                      
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(LucideIcons.layoutGrid, 'CORE', 0),
                            _buildNavItem(LucideIcons.shield, 'STUDIO', 1),
                            _buildNavItem(LucideIcons.settings, 'SETUP', 2),
                          ],
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
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    final themeColor = Theme.of(context).primaryColor;
    
    Widget iconBase = Icon(
      icon,
      size: UDE.sp(22, context), // Ergonomic Expansion
      color: isActive ? themeColor : Colors.white24, // Optimized dimming
    );

    if (isActive) {
      iconBase = iconBase
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 2000.ms, color: Colors.white.withAlpha(80))
          .saturate(begin: 1.0, end: 1.8, duration: 1500.ms);
    }

    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticType.selection);
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: UDE.sp(80, context),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.identity()..scale(isActive ? 1.1 : 1.0),
              child: iconBase,
            ),
            if (isActive) ...[
              SizedBox(height: UDE.sp(4, context)),
              Text(
                label,
                style: TextStyle(
                  fontSize: UDE.tp(9, context),
                  fontWeight: FontWeight.w900,
                  color: themeColor.withOpacity(0.95),
                  letterSpacing: 1.8,
                ),
              ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.9, 0.9)),
            ]
          ],
        ),
      ),
    );
  }
}

class _CurvedNeonPainter extends CustomPainter {
  final Color color;
  final double radius;

  _CurvedNeonPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius), clockwise: true);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius), clockwise: true);
    path.lineTo(size.width, size.height);

    // Advanced Pinpoint Aesthetics
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
    
    final Paint corePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, corePaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedNeonPainter oldDelegate) => oldDelegate.color != color;
}
