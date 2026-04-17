import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../logic/hardware_state.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/layout_engine.dart';
import '../widgets/ws2812_strip.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<HardwareState>();
    Color glow = state.isPowered ? (state.colorMode == 'single' ? state.activeColor : AppTheme.highlight) : Colors.transparent;

    return Padding(
      padding: EdgeInsets.only(
        left: LayoutEngine.scaleV(20, context), 
        right: LayoutEngine.scaleV(20, context), 
        top: LayoutEngine.scaleV(60, context), 
        // Removing massive bottom padding because scroll boundaries are killed
        bottom: LayoutEngine.scaleV(20, context)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _GlitchTypingText(
            text: "AURORA PIXEL\nCONTROLLER",
            style: TextStyle(
              fontSize: LayoutEngine.scaleF(28, context), // Large, elegant
              fontWeight: FontWeight.w900, 
              color: Colors.white, 
              letterSpacing: -1.0,
              height: 1.1,
            ),
          ),
          SizedBox(height: LayoutEngine.scaleV(16, context)),

          // The Under-Header Neon Border Setup
          Container(
            height: 1.5, // Razor thin
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.highlight.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.highlight.withOpacity(0.4), 
                  blurRadius: 15, 
                  spreadRadius: 2, 
                  offset: const Offset(0, 5) // Soft downward glow
                )
              ],
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
            duration: 2500.ms, 
            color: Colors.white.withAlpha(200), // Intense flowing highlight
            angle: 0.0, // Strict horizontal flow
            size: 2.0 // Wide band
          ),
          
          SizedBox(height: LayoutEngine.scaleV(40, context)), // Margin under the border

          // Main Action Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Rigid Lock
            mainAxisSpacing: LayoutEngine.scaleV(72, context), // Large vertical gap for luxury lock
            crossAxisSpacing: LayoutEngine.scaleV(20, context),
            childAspectRatio: (MediaQuery.sizeOf(context).width / 2) / LayoutEngine.scaleV(145, context), 
            children: [
              _ControlButton(
                icon: LucideIcons.power,
                label: "Master Power",
                statusText: state.isPowered ? "ACTIVE" : "OFF",
                isActive: state.isPowered,
                glowColor: AppTheme.highlight,
                onTap: () => context.read<HardwareState>().togglePower(),
              ),
              _ControlButton(
                icon: LucideIcons.palette,
                label: "Color Mode",
                statusText: state.colorMode == 'multi' ? "MULTI" : "SINGLE",
                isActive: state.colorMode == 'multi',
                glowColor: Colors.purpleAccent,
                onTap: () => context.read<HardwareState>().setColorMode(state.colorMode == 'single' ? 'multi' : 'single'),
              ),
              _ControlButton(
                icon: state.mode == 'pixel' ? LucideIcons.sparkles : LucideIcons.activity,
                label: state.mode == 'pixel' ? "Pixel FX" : "Audio React",
                statusText: state.mode == 'pixel' ? "ACTIVE" : "LISTENING",
                isActive: true, // Always active
                glowColor: state.mode == 'pixel' ? Colors.blueAccent : Colors.orangeAccent,
                onTap: () => context.read<HardwareState>().setMode(state.mode == 'pixel' ? 'vu' : 'pixel'),
              ),
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
              ),
            ],
          ),
          
          // Use Spacer to push the studio preview dynamically to the bottom without scrolling
          const Spacer(),
          
          Text("STUDIO PREVIEW", style: TextStyle(
            fontSize: LayoutEngine.scaleF(12, context), 
            fontWeight: FontWeight.bold, 
            color: Colors.white54, 
            letterSpacing: 2.0
          )),
          SizedBox(height: LayoutEngine.scaleV(12, context)),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: EdgeInsets.all(LayoutEngine.scaleV(20, context)),
            margin: EdgeInsets.only(bottom: LayoutEngine.scaleV(85, context)), // Leave space for extreme bottom dock
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0C),
              borderRadius: BorderRadius.circular(LayoutEngine.scaleV(32, context)),
              border: Border.all(color: AppTheme.neoBorder),
              boxShadow: state.isPowered 
                  ? [BoxShadow(color: glow.withOpacity(0.15), offset: Offset(0, LayoutEngine.scaleV(20, context)), blurRadius: 50, spreadRadius: -5)]
                  : [],
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
                          width: LayoutEngine.scaleV(10, context),
                          height: LayoutEngine.scaleV(10, context),
                          decoration: BoxDecoration(
                            color: glow,
                            shape: BoxShape.circle,
                            boxShadow: state.isPowered ? [BoxShadow(color: glow, blurRadius: 10)] : [],
                          ),
                        ),
                        SizedBox(width: LayoutEngine.scaleV(10, context)),
                        Text(state.activeAnimation.toUpperCase(), style: TextStyle(
                          fontSize: LayoutEngine.scaleF(12, context), 
                          fontWeight: FontWeight.w900, 
                          color: Colors.white
                        )),
                      ],
                    ),
                    Text("${state.brightness}%", style: TextStyle(
                      fontSize: LayoutEngine.scaleF(12, context), 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white54
                    )),
                  ],
                ),
                SizedBox(height: LayoutEngine.scaleV(24, context)),
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
        .shimmer(duration: 3000.ms, color: AppTheme.highlight.withAlpha(200));
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
        borderRadius: BorderRadius.circular(LayoutEngine.scaleV(28, context)),
        border: Border.all(
          color: widget.isActive ? widget.glowColor.withAlpha(128) : AppTheme.dimBorder,
        ),
        boxShadow: widget.isActive 
            ? [BoxShadow(color: widget.glowColor.withOpacity(0.05), blurRadius: 20, spreadRadius: 0)]
            : [const BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 0)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: LayoutEngine.scaleV(42, context),
            height: LayoutEngine.scaleV(42, context),
            decoration: BoxDecoration(
              color: widget.isActive ? widget.glowColor : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(LayoutEngine.scaleV(14, context)),
              boxShadow: widget.isActive 
                  ? [BoxShadow(color: widget.glowColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 0)]
                  : [],
            ),
            child: Icon(widget.icon, size: LayoutEngine.scaleV(20, context), color: widget.isActive ? Colors.white : Colors.white54),
          ),
          SizedBox(height: LayoutEngine.scaleV(8, context)),
          Text(widget.label.toUpperCase(), style: TextStyle(fontSize: LayoutEngine.scaleF(9, context), fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
          SizedBox(height: LayoutEngine.scaleV(4, context)),
          Text(widget.statusText, style: TextStyle(
            fontSize: LayoutEngine.scaleF(14, context), 
            fontWeight: FontWeight.w900, 
            color: widget.isActive ? Colors.white : Colors.white54,
            letterSpacing: -0.5
          )),
        ],
      ),
    );

    if (widget.isActive) {
      container = container.animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 2000.ms, color: widget.glowColor.withAlpha(50)) // Smooth shimmer sweep
          .elevation(end: 5, color: widget.glowColor.withAlpha(50), borderRadius: BorderRadius.circular(LayoutEngine.scaleV(28, context))) // Floating glow
          .scaleXY(end: 1.02, duration: 1500.ms, curve: Curves.easeInOutSine); // Slow organical breathe
    }

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
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
