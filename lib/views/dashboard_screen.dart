import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_tab.dart';
import 'studio_tab.dart';
import 'settings_tab.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/layout_engine.dart';

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
    return Scaffold(
      extendBody: true, // Let tabs slide under the floating nav
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
          
          // Full-Width Docked Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(LayoutEngine.scaleV(24, context))),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom), // Safe area support
                  height: LayoutEngine.scaleV(85, context) + MediaQuery.paddingOf(context).bottom,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A).withOpacity(0.85),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(LayoutEngine.scaleV(24, context))),
                  ),
                  child: Stack(
                    children: [
                      // Water Flow Neon Top Border Layer
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: AppTheme.highlight.withOpacity(0.8),
                            boxShadow: [BoxShadow(color: AppTheme.highlight.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, -5))]
                          ),
                        ).animate(onPlay: (c) => c.repeat()).shimmer(
                          duration: 2500.ms, 
                          color: Colors.white.withAlpha(200),
                          angle: 0.0,
                          size: 2.0
                        ),
                      ),
                      
                      // Icons Layer
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
    
    Widget iconBase = Icon(
      icon,
      size: LayoutEngine.scaleV(26, context),
      color: isActive ? AppTheme.highlight : Colors.white.withAlpha(100),
    );

    // Apply Cyber Neon dynamics and rotate active icon slightly 
    if (isActive) {
      iconBase = Transform.rotate(
        angle: -0.2, // Tilted left slightly like screenshot
        child: iconBase
          .animate(onPlay: (c) => c.repeat()) // Loop animation
          .elevation(
            end: 15,
            color: AppTheme.highlight,
            borderRadius: BorderRadius.circular(100),
          )
          .shake(hz: 3, rotation: 0.1, duration: 1500.ms) // Cyber jitter vibration
          .saturate(begin: 1.0, end: 2.5, duration: 1000.ms), // Sharp saturate, no blur
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: LayoutEngine.scaleV(80, context),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(
            key: ValueKey<bool>(isActive),
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()..scale(isActive ? 1.15 : 1.0),
                transformAlignment: Alignment.center,
                child: iconBase,
              ),
              if (isActive) ...[
                SizedBox(height: LayoutEngine.scaleV(4, context)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: LayoutEngine.scaleF(10, context),
                    fontWeight: FontWeight.w900,
                    color: AppTheme.highlight,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
