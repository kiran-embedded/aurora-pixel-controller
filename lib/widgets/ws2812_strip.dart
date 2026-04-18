import 'dart:math';
import 'package:flutter/material.dart';
import '../core/engine/display_engine.dart';
import 'effect_engine.dart';

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
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(UDE.sp(10, context)),
      decoration: BoxDecoration(
        color: const Color(0xFF020202), // Deep AMOLED base
        borderRadius: BorderRadius.circular(UDE.r(24, context)),
        border: Border.all(color: Colors.white.withOpacity(0.015)),
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
    SimulatedLED sim = EffectEngine.simulate(
      index, widget.count, progress, widget.mode, widget.animation,
      widget.activeColor, widget.colorMode, widget.isPowered, _vuLevel,
    );

    double brightnessFactor = widget.brightness / 100.0;
    
    return RepaintBoundary( // Performance optimization
      child: CustomPaint(
        size: Size(UDE.sp(14, context), UDE.sp(22, context)),
        painter: SpecularIsolationPainter(
          ledColor: sim.color,
          blurRadius: sim.blurRadius * brightnessFactor,
          opacity: sim.opacity * brightnessFactor,
          scale: sim.scale,
        ),
      ),
    );
  }
}

class SpecularIsolationPainter extends CustomPainter {
  final Color ledColor;
  final double blurRadius;
  final double opacity;
  final double scale; // Now used for internal intensity, not housing size
  
  SpecularIsolationPainter({
    required this.ledColor,
    required this.blurRadius,
    required this.opacity,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    
    // 1. Die-Cast Housing (Solid, Non-scaling)
    final Paint housingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1F1F1F), Color(0xFF030303)],
      ).createShader(rect);
    
    canvas.drawRRect(rrect, housingPaint);
    
    // 2. ADVANCED BLEEDING PREVENTION: SaveLayer Masking
    // We use saveLayer to ensure that any blur effects are strictly bounded by the clip.
    canvas.saveLayer(rect, Paint());
    canvas.clipRRect(rrect);

    if (opacity > 0.01) {
      final double centerX = size.width / 2;
      final double centerY = size.height / 2;
      final double diodeSize = size.width * 0.6;

      // 3. Inner Diode Cavity
      canvas.drawCircle(Offset(centerX, centerY), diodeSize / 2, 
          Paint()..color = Colors.black..style = PaintingStyle.fill);

      // 4. CLEAN VIBRANT COLOR BASE
      final baseColorPaint = Paint()
        ..color = ledColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(centerX, centerY), diodeSize * 0.48, baseColorPaint);

      // 5. SPECULAR OVERDRIVE (The "Realistic" Glow)
      if (blurRadius > 0) {
        final glowPaint = Paint()
          ..color = ledColor.withOpacity(opacity * 1.0) // 100% glow color purity
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, (blurRadius + 4.0) * scale); // Expansive glow
        canvas.drawCircle(Offset(centerX, centerY), diodeSize * 0.48, glowPaint);
      }

      // 6. Specular Heart (Pure White Focus point)
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(centerX, centerY), scale * 2.5, corePaint);
      
      // 6. Internal Reflection Rim
      final reflectionPaint = Paint()
        ..color = ledColor.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawCircle(Offset(centerX, centerY), diodeSize / 2, reflectionPaint);
    }
    
    canvas.restore(); // Terminate clipping and bleeding

    // 7. Housing Rim Highlight (Fixed, Clean edge)
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(isSelected ? 40 : 15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRRect(rrect, highlightPaint);
  }

  bool get isSelected => opacity > 0.5;

  @override
  bool shouldRepaint(covariant SpecularIsolationPainter oldDelegate) => 
    oldDelegate.ledColor != ledColor || 
    oldDelegate.blurRadius != blurRadius || 
    oldDelegate.opacity != opacity ||
    oldDelegate.scale != scale;
}

