import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../logic/hardware_state.dart';
import '../logic/haptic_service.dart';
import '../core/theme/app_theme.dart';
import '../core/engine/display_engine.dart';
import '../widgets/ws2812_strip.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<HardwareState>();
    final themeColor = Theme.of(context).primaryColor;
    Color glow = state.isPowered ? (state.colorMode == 'single' ? state.activeColor : themeColor) : Colors.transparent;

    return Padding(
      padding: EdgeInsets.only(
        left: UDE.sp(20, context), 
        right: UDE.sp(20, context), 
        top: UDE.sp(60, context), 
        // Removing massive bottom padding because scroll boundaries are killed
        bottom: UDE.sp(20, context)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _GlitchTypingText(
              text: "AURORA PIXEL\nCONTROLLER",
              style: TextStyle(
                fontSize: UDE.tp(28, context), 
                fontWeight: FontWeight.w900, 
                color: Colors.white, 
                letterSpacing: -1.0,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(height: UDE.sp(16, context)),

          // Precision Top Border (Zero Bleed)
          CustomPaint(
            size: const Size(double.infinity, 2),
            painter: _CurvedNeonPainter(color: themeColor.withOpacity(UDE.dimmedNeonAlpha), radius: 0),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
            duration: 3000.ms, 
            color: Colors.white.withAlpha(50), 
            angle: 0.0,
          ),
          
          SizedBox(height: UDE.sp(40, context)),

          // Main Action Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Rigid Lock
            mainAxisSpacing: UDE.sp(72, context), // Large vertical gap for luxury lock
            crossAxisSpacing: UDE.sp(20, context),
            childAspectRatio: (MediaQuery.sizeOf(context).width / 2) / UDE.sp(145, context), 
            children: [
              _ControlButton(
                icon: LucideIcons.power,
                label: "Master Power",
                statusText: state.isPowered ? "ACTIVE" : "OFF",
                isActive: state.isPowered,
                glowColor: themeColor,
                onTap: () => context.read<HardwareState>().togglePower(),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
              _ControlButton(
                icon: LucideIcons.palette,
                label: "Color Mode",
                statusText: state.colorMode == 'multi' ? "MULTI" : "SINGLE",
                isActive: state.colorMode == 'multi',
                glowColor: Colors.purpleAccent,
                onTap: () => context.read<HardwareState>().setColorMode(state.colorMode == 'single' ? 'multi' : 'single'),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
              _ControlButton(
                icon: state.mode == 'pixel' ? LucideIcons.sparkles : LucideIcons.activity,
                label: state.mode == 'pixel' ? "Pixel FX" : "Audio React",
                statusText: state.mode == 'pixel' ? "ACTIVE" : "LISTENING",
                isActive: true, // Always active
                glowColor: state.mode == 'pixel' ? Colors.blueAccent : Colors.orangeAccent,
                onTap: () => context.read<HardwareState>().setMode(state.mode == 'pixel' ? 'vu' : 'pixel'),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
              _ControlButton(
                icon: LucideIcons.sun,
                label: "Brightness",
                statusText: "${state.brightness}%", 
                isActive: state.brightness > 50,
                glowColor: Colors.redAccent, 
                onTap: () {
                  int next = state.brightness >= 100 ? 25 : state.brightness + 25;
                  context.read<HardwareState>().setBrightness(next);
                },
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
          
          // Use Spacer to push the studio preview dynamically to the bottom without scrolling
          const Spacer(),
          
          Center(
            child: UDE.tpSafe("STUDIO PREVIEW", TextStyle(
              fontWeight: FontWeight.bold, 
              color: themeColor, 
              letterSpacing: 3.0
            ), context),
          ),
          SizedBox(height: UDE.sp(8, context)), // Reduced to move it closer to the strip
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: EdgeInsets.all(UDE.sp(20, context)),
            margin: EdgeInsets.only(bottom: UDE.sp(85, context)), // Leave space for extreme bottom dock
            decoration: BoxDecoration(
              color: const Color(0xFF020202), // Absolute Black
              borderRadius: BorderRadius.circular(UDE.sp(32, context)),
              border: Border.all(color: themeColor.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: UDE.sp(10, context),
                          height: UDE.sp(10, context),
                          decoration: BoxDecoration(
                            color: glow,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: UDE.sp(10, context)),
                        UDE.tpSafe(state.activeAnimation.toUpperCase(), const TextStyle(
                          fontWeight: FontWeight.w900, 
                          color: Colors.white
                        ), context),
                      ],
                    ),
                    UDE.tpSafe("${state.brightness}%", const TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.white54
                    ), context),
                  ],
                ),
                SizedBox(height: UDE.sp(24, context)),
                WS2812Strip(
                  count: 16,
                  mode: state.mode,
                  animation: state.activeAnimation,
                  activeColor: state.activeColor,
                  colorMode: state.colorMode,
                  isPowered: state.isPowered,
                  brightness: state.brightness,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Inline luxury typing text widget updated to smooth wipe mask
class _GlitchTypingText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _GlitchTypingText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style)
        .animate()
        .custom(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: child,
              ),
            );
          },
        )
        .then()
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 3000.ms, color: Theme.of(context).primaryColor.withAlpha(200));
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String statusText;
  final bool isActive;
  final Color glowColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.statusText,
    required this.isActive,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.isActive ? const Color(0xFF18181C) : const Color(0xFF141417),
        borderRadius: BorderRadius.circular(UDE.sp(28, context)),
        border: Border.all(
          color: widget.isActive ? widget.glowColor.withAlpha(128) : AppTheme.dimBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: UDE.sp(42, context),
            height: UDE.sp(42, context),
            decoration: BoxDecoration(
              color: widget.isActive ? widget.glowColor : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(UDE.sp(14, context)),
            ),
            child: Icon(widget.icon, size: UDE.sp(20, context), color: widget.isActive ? Colors.white : Colors.white54),
          ),
          SizedBox(height: UDE.sp(8, context)),
          UDE.tpSafe(widget.label.toUpperCase(), const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5), context),
          SizedBox(height: UDE.sp(4, context)),
          UDE.tpSafe(widget.statusText, TextStyle(
            fontWeight: FontWeight.w900, 
            color: widget.isActive ? Colors.white : Colors.white54,
            letterSpacing: -0.5
          ), context),
        ],
      ),
    );

    if (widget.isActive) {
      container = container.animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 2000.ms, color: widget.glowColor.withAlpha(50)) // Smooth shimmer sweep
          .elevation(end: 5, color: widget.glowColor.withAlpha(50), borderRadius: BorderRadius.circular(UDE.sp(28, context))) // Floating glow
          .scaleXY(end: 1.02, duration: 1500.ms, curve: Curves.easeInOutSine); // Slow organical breathe
    }

    return GestureDetector(
      onTapDown: (_) {
        HapticService.trigger(HapticType.light);
        _controller.forward();
      },
      onTapUp: (_) {
        HapticService.trigger(HapticType.medium);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: container,
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
    final Paint corePaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), glowPaint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), corePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
