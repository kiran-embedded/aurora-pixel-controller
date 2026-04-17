import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/layout_engine.dart';

class WS2812Strip extends StatefulWidget {
  final int count;
  final String mode;
  final String animation;
  final Color activeColor;
  final String colorMode;
  final bool isPowered;
  final int brightness;

  const WS2812Strip({
    super.key,
    this.count = 14,
    required this.mode,
    required this.animation,
    required this.activeColor,
    required this.colorMode,
    required this.isPowered,
    required this.brightness,
  });

  @override
  State<WS2812Strip> createState() => _WS2812StripState();
}

class _WS2812StripState extends State<WS2812Strip> with TickerProviderStateMixin {
  late final AnimationController _animController;
  double _vuLevel = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
        
    _startVuSimulation();
  }

  void _startVuSimulation() {
    Future.doWhile(() async {
      if (mounted) {
        if (widget.mode == 'vu' && widget.isPowered) {
          setState(() {
            _vuLevel = Random().nextDouble() * widget.count;
          });
        }
      }
      await Future.delayed(const Duration(milliseconds: 130));
      return mounted;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge, // Prevent bleeding overlap
      padding: EdgeInsets.all(LayoutEngine.scaleV(10, context)), // Scaled
      decoration: BoxDecoration(
        color: const Color(0xFF030303), // Make it almost pure black for infinite depth
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.02)), // Dimmer border
        boxShadow: const [], // Zero background bleeding
      ),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.count, (i) {
              return _buildPixel(i, _animController.value, context);
            }),
          );
        },
      ),
    );
  }

  Widget _buildPixel(int index, double progress, BuildContext context) {
    String name = widget.animation.toLowerCase();
    Color ledColor = widget.activeColor;
    double scale = 1.0;
    double opacity = widget.isPowered ? (widget.brightness / 100.0) : 0.0;
    double blurRadius = 12.0;

    if (widget.mode == 'pixel') {
      if (name.contains('meteor') || name.contains('flow') || name.contains('chase')) {
        ledColor = widget.colorMode == 'single' 
            ? widget.activeColor 
            : HSVColor.fromAHSV(1.0, (index / widget.count) * 360, 1.0, 1.0).toColor();
        
        // Meteor cascade math
        double delay = index * 0.1;
        double localProgress = (progress - delay) % 1.0;
        if (localProgress < 0) localProgress += 1.0;
        
        if (localProgress < 0.1) {
          opacity = widget.isPowered ? 1.0 : 0;
          scale = 1.1;
          blurRadius = 15.0; // Restrict blur
        } else if (localProgress < 0.3) {
          opacity = widget.isPowered ? 0.4 : 0;
          scale = 1.0;
          blurRadius = 6.0;
        } else {
          opacity = widget.isPowered ? 0.1 : 0;
          scale = 0.8;
          blurRadius = 0.0;
        }
      } else if (name.contains('strobe') || name.contains('flash')) {
        // Sharp strobe math
        if (progress > 0.5 && progress < 0.52) {
          opacity = widget.isPowered ? 1.0 : 0;
          blurRadius = 20.0;
        } else {
          opacity = 0;
        }
      } else if (name.contains('breathe')) {
        double val = (sin(progress * 2 * pi) + 1) / 2; // 0 to 1
        opacity = widget.isPowered ? (0.3 + (0.7 * val)) : 0.0;
        scale = 0.95 + (0.05 * val);
        blurRadius = 10.0 * val;
      } else {
        // Solid
        ledColor = widget.colorMode == 'single' 
            ? widget.activeColor 
            : HSVColor.fromAHSV(1.0, (index / widget.count) * 360, 1.0, 1.0).toColor();
      }
    } else {
      // VU Mode logic
      bool isPeak = index == _vuLevel.floor();
      bool isAtOrBelow = index <= _vuLevel;

      if (name.contains('gravity') || name.contains('peak')) {
        ledColor = isPeak 
            ? Colors.white 
            : (widget.colorMode == 'single' 
                ? widget.activeColor 
                : (index < widget.count * 0.6 ? const Color(0xFF00E676) : const Color(0xFFFFEA00)));
        if (isPeak) {
          scale = 1.25;
          blurRadius = 16.0;
        }
      } else {
        double pos = index / widget.count;
        ledColor = widget.colorMode == 'single' 
            ? widget.activeColor 
            : (pos < 0.6 ? const Color(0xFF00E676) : pos < 0.85 ? const Color(0xFFFFEA00) : const Color(0xFFFF1744));
      }

      if (!isAtOrBelow) {
        opacity = widget.isPowered ? 0.05 : 0;
        blurRadius = 0;
      }
    }
    
    // Apply brightness master offset
    opacity = opacity * (widget.brightness / 100.0);

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: LayoutEngine.scaleV(12, context), // Narrower physical footprint for realism
          height: LayoutEngine.scaleV(20, context), // Rectangular SMD housing
          margin: EdgeInsets.symmetric(horizontal: LayoutEngine.scaleV(1, context)),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A), // Glossy black housing bottom
            border: Border.all(color: Colors.white.withAlpha(10), width: 0.5),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2, spreadRadius: 0)],
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle, // Circular diode core housing
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // The Glow Base
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: ledColor,
                      shape: BoxShape.circle,
                      boxShadow: blurRadius > 0 ? [
                        BoxShadow(
                          color: ledColor.withOpacity(0.95), // Ultra intense center
                          blurRadius: blurRadius * 1.5,
                          spreadRadius: blurRadius * 0.15, // Controlled bloom
                        )
                      ] : [],
                    ),
                  ),
                  // The AMOLED Specular Highlight Overdrive
                  if (blurRadius > 0)
                    Container(
                      width: 1.5,
                      height: 1.5,
                      decoration: const BoxDecoration(
                        color: Colors.white, // Ultra bright diode wire element
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.white, blurRadius: 3)],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
