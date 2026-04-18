import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../logic/hardware_state.dart';
import '../logic/haptic_service.dart';
import '../core/theme/app_theme.dart';
import '../core/engine/display_engine.dart';
import '../widgets/ws2812_strip.dart';

class StudioTab extends StatelessWidget {
  const StudioTab({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<HardwareState>();
    final themeColor = Theme.of(context).primaryColor;
    Color glow = state.isPowered ? (state.colorMode == 'single' ? state.activeColor : themeColor) : Colors.transparent;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: UDE.sp(20, context), 
        right: UDE.sp(20, context), 
        top: UDE.sp(55, context), // Moved down from 40 for visual balance
        bottom: UDE.sp(120, context) // Preserved scrolling 
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Centered Shimmering Title
          Center(
            child: UDE.tpSafe("STUDIO", TextStyle(
              fontSize: UDE.tp(28, context), // Restored for high-end feel
              fontWeight: FontWeight.w900, 
              color: Colors.white, 
              letterSpacing: 10.0
            ), context, align: TextAlign.center).animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 3000.ms, color: Theme.of(context).primaryColor),
          ),
          SizedBox(height: UDE.sp(40, context)),

          // Precision Top Border (Zero Bleed)
          CustomPaint(
            size: const Size(double.infinity, 2),
            painter: _CurvedNeonPainter(color: themeColor.withOpacity(UDE.dimmedNeonAlpha)),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
            duration: 3000.ms, 
            color: Colors.white.withAlpha(50), 
            angle: 0.0,
          ),

          SizedBox(height: UDE.sp(40, context)),

          // Segmented Control (AMOLED Cleaned Update)
          Container(
            padding: EdgeInsets.all(UDE.sp(4, context)),
            decoration: BoxDecoration(
              color: const Color(0xFF000000), // Pure AMOLED black core
              borderRadius: BorderRadius.circular(UDE.sp(12, context)),
              border: Border.all(color: themeColor.withAlpha(40)),
            ),
            child: Row(
              children: [
                Expanded(child: _SegmentButton(label: "Visual Effects", isSelected: state.mode == 'pixel', onTap: () => context.read<HardwareState>().setMode('pixel'), context: context)),
                Expanded(child: _SegmentButton(label: "Audio React", isSelected: state.mode == 'vu', onTap: () => context.read<HardwareState>().setMode('vu'), context: context)),
              ],
            ),
          ),
          SizedBox(height: UDE.sp(32, context)),

          // Algorithm Vault Button (AMOLED Luxe Mode)
          GestureDetector(
            onTap: () => _showAlgorithmVault(context, state),
            child: Container(
              padding: EdgeInsets.all(UDE.sp(20, context)),
              decoration: BoxDecoration(
                color: const Color(0xFF020202), // Unified Absolute Black
                borderRadius: BorderRadius.circular(UDE.sp(24, context)),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.4), width: 1.5),
                // Shadow removed for zero-bleed
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: UDE.sp(44, context), 
                        height: UDE.sp(44, context),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(UDE.sp(12, context)),
                        ),
                        child: Icon(state.mode == 'pixel' ? LucideIcons.sparkles : LucideIcons.activity, color: Theme.of(context).primaryColor, size: UDE.sp(22, context)),
                      ),
                      SizedBox(width: UDE.sp(16, context)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UDE.tpSafe("ALGORITHM", const TextStyle(fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 2.0), context),
                          SizedBox(height: UDE.sp(2, context)),
                          UDE.tpSafe(state.activeAnimation, const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5), context),
                        ],
                      )
                    ],
                  ),
                  Icon(LucideIcons.chevronRight, color: Theme.of(context).primaryColor.withOpacity(0.5), size: UDE.sp(24, context)),
                ],
              ),
            ),
          ),
          SizedBox(height: UDE.sp(32, context)),

          // Strip Display (Centered)
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: double.infinity,
              padding: EdgeInsets.all(UDE.sp(24, context)),
              decoration: BoxDecoration(
                color: const Color(0xFF020202),
                borderRadius: BorderRadius.circular(UDE.sp(24, context)),
                border: Border.all(color: themeColor.withAlpha(40)),
                // Shadow removed for zero-bleed
              ),
              child: WS2812Strip(
                count: context.watch<HardwareState>().numLeds > 32 ? 32 : context.watch<HardwareState>().numLeds, // Clamp for preview
                mode: state.mode,
                animation: state.activeAnimation,
                activeColor: state.activeColor,
                colorMode: state.colorMode,
                isPowered: state.isPowered,
                brightness: state.brightness,
              ),
            ),
          ),
          SizedBox(height: UDE.sp(40, context)),

          // Spectral Hub
          Center(
            child: UDE.tpSafe("SPECTRAL HUB", TextStyle(
              fontWeight: FontWeight.w900, 
              color: themeColor.withOpacity(UDE.neonGlowAlpha), 
              letterSpacing: 1.5
            ), context, align: TextAlign.center).animate(onPlay: (c) => c.repeat()).shimmer(
              duration: 4000.ms,
              color: Colors.white.withAlpha(50)
            ),
          ),
          SizedBox(height: UDE.sp(20, context)),
          Center(
            child: Container(
              padding: EdgeInsets.all(UDE.sp(24, context)),
              decoration: BoxDecoration(
                color: const Color(0xFF020202),
                borderRadius: BorderRadius.circular(UDE.sp(24, context)),
                border: Border.all(color: themeColor.withAlpha(40)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("SPECTRAL HUB", style: TextStyle(fontSize: UDE.tp(10, context), fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 3.0)),
                      Container(
                        padding: EdgeInsets.all(UDE.sp(4, context)),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(UDE.sp(12, context)),
                          border: Border.all(color: themeColor.withAlpha(40)),
                        ),
                        child: Row(
                          children: [
                            _SpectralModeBtn("Auto", state.colorMode == 'multi', () {
                              HapticService.trigger(HapticType.selection);
                              context.read<HardwareState>().setColorMode('multi');
                            }, context),
                            _SpectralModeBtn("Custom", state.colorMode == 'single', () {
                              HapticService.trigger(HapticType.selection);
                              context.read<HardwareState>().setColorMode('single');
                            }, context),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: UDE.sp(28, context)),
                  
                  // Active Color Info
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: state.colorMode == 'single' ? 1.0 : 0.2,
                    child: IgnorePointer(
                      ignoring: state.colorMode != 'single',
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(UDE.sp(16, context)),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(UDE.sp(20, context)),
                              border: Border.all(color: themeColor.withAlpha(40)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("PRECISE HEX", style: TextStyle(fontSize: UDE.tp(9, context), fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 2.0)),
                                    SizedBox(height: UDE.sp(4, context)),
                                    Text('#${state.activeColor.value.toRadixString(16).substring(2, 8).toUpperCase()}', 
                                         style: TextStyle(fontSize: UDE.tp(20, context), fontWeight: FontWeight.w900, fontFamily: 'monospace', color: Colors.white, letterSpacing: 2.0)),
                                  ],
                                ),
                                Container(
                                  width: UDE.sp(50, context), 
                                  height: UDE.sp(50, context),
                                  decoration: BoxDecoration(
                                    color: state.activeColor,
                                    borderRadius: BorderRadius.circular(UDE.sp(16, context)),
                                    border: Border.all(color: Colors.black, width: 3),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: UDE.sp(28, context)),
                          
                          // Immersive Hue Slider
                          Container(
                            height: UDE.sp(40, context),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(UDE.sp(20, context)),
                              border: Border.all(color: Colors.black, width: 4),
                              gradient: const LinearGradient(
                                colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.transparent,
                                inactiveTrackColor: Colors.transparent,
                                thumbColor: state.activeColor,
                                overlayColor: state.activeColor.withOpacity(0.2),
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: UDE.sp(16, context), elevation: 8),
                              ),
                              child: Slider(
                                value: HSVColor.fromColor(state.activeColor).hue,
                                min: 0,
                                max: 360,
                                onChanged: (val) {
                                  HapticService.trigger(HapticType.immersive); // Pulse haptic
                                  context.read<HardwareState>().setActiveColorLocal(HSVColor.fromAHSV(1.0, val, 1.0, 1.0).toColor());
                                },
                                onChangeEnd: (val) {
                                  HapticService.trigger(HapticType.success);
                                  context.read<HardwareState>().setActiveColor(HSVColor.fromAHSV(1.0, val, 1.0, 1.0).toColor());
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _SegmentButton({required String label, required bool isSelected, required VoidCallback onTap, required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticType.selection);
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: UDE.sp(12, context)),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(UDE.sp(12, context)),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.4) : Colors.transparent),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: UDE.tp(11, context),
              fontWeight: FontWeight.w900,
              color: isSelected ? Theme.of(context).primaryColor : Colors.white24,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _SpectralModeBtn(String label, bool isSelected, VoidCallback onTap, BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: UDE.sp(16, context), vertical: UDE.sp(8, context)),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(UDE.sp(12, context)),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: UDE.tp(10, context),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isSelected ? Colors.black : Colors.white54,
          ),
        ),
      ),
    );
  }

  void _showAlgorithmVault(BuildContext context, HardwareState state) {
    List<String> pixelAnims = [
      "Solid Custom", "Meteor Shower", "Rainbow Flow", "Aurora Borealis", 
      "Cyber Sweep", "Galaxy Spin", "Starlight", "Fire Flicker", 
      "Pulse Wave", "Comet Chase", "Neon Breath", "Ghost Fade", 
      "Scanner", "Plasma Flow", "Matrix Rain", "Color Wipe", 
      "Theater Chase", "Twinkle Fox", "Sparkle", "Bouncing Balls", 
      "Sine Wave", "Popcorn", "Hyper Jump", "Water Ripple", "Candy Cane"
    ];
    List<String> vuAnims = [
      "Classic Left-Right", "Gravity Drop", "Center Out", "Split Edges", 
      "Resonance", "Beat Flash", "Digital Wave", "Stereo Pulse", 
      "Fire EQ", "Peak Hold", "Sound Ripple", "Bass Bounce", 
      "Symmetric Fill", "Color Shift EQ", "Flash Pulse"
    ];
    List<String> currentList = state.mode == 'pixel' ? pixelAnims : vuAnims;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final themeColor = Theme.of(ctx).primaryColor;
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: const Color(0xFF020202), 
            borderRadius: BorderRadius.vertical(top: Radius.circular(UDE.sp(40, context))),
            border: Border(top: BorderSide(color: themeColor.withOpacity(0.5), width: 1.5)),
          ),
          child: Column(
            children: [
              SizedBox(height: UDE.sp(24, context)),
              Container(width: UDE.sp(64, context), height: UDE.sp(6, context), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              Padding(
                padding: EdgeInsets.all(UDE.sp(32, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UDE.tpSafe("ALGORITHM VAULT", const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5), context),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(UDE.sp(10, context)),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.05))),
                        child: Icon(LucideIcons.x, color: Colors.white, size: UDE.sp(24, context)),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: UDE.sp(24, context), vertical: UDE.sp(8, context)),
                  physics: const BouncingScrollPhysics(),
                  itemCount: currentList.length,
                  itemBuilder: (c, i) {
                    bool isActive = state.activeAnimation == currentList[i];
                    return GestureDetector(
                      onTap: () {
                        context.read<HardwareState>().setActiveAnimation(currentList[i]);
                        Navigator.pop(ctx);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: UDE.sp(64, context),
                        margin: EdgeInsets.only(bottom: UDE.sp(12, context)),
                        padding: EdgeInsets.symmetric(horizontal: UDE.sp(24, context)),
                        decoration: BoxDecoration(
                          color: isActive ? Theme.of(context).primaryColor.withOpacity(0.12) : const Color(0xFF080808),
                          borderRadius: BorderRadius.circular(UDE.sp(24, context)),
                          border: Border.all(color: isActive ? Theme.of(context).primaryColor.withOpacity(0.6) : Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currentList[i], style: TextStyle(fontSize: UDE.tp(15, context), fontWeight: FontWeight.w900, color: isActive ? Theme.of(context).primaryColor : Colors.white54, letterSpacing: -0.5)),
                            if (isActive) Icon(LucideIcons.zap, color: Theme.of(context).primaryColor, size: UDE.sp(20, context)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _CurvedNeonPainter extends CustomPainter {
  final Color color;

  _CurvedNeonPainter({required this.color});

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
