import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../logic/hardware_state.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/layout_engine.dart';
import '../widgets/ws2812_strip.dart';

class StudioTab extends StatelessWidget {
  const StudioTab({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<HardwareState>();
    Color glow = state.isPowered ? (state.colorMode == 'single' ? state.activeColor : AppTheme.highlight) : Colors.transparent;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: LayoutEngine.scaleV(20, context), 
        right: LayoutEngine.scaleV(20, context), 
        top: LayoutEngine.scaleV(60, context), 
        bottom: LayoutEngine.scaleV(120, context) // Preserved scrolling for tab 2 since it has sliders
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: LayoutEngine.scaleV(4, context)),
            child: Text("STUDIO", style: TextStyle(
              fontSize: LayoutEngine.scaleF(30, context), 
              fontWeight: FontWeight.w900, 
              color: Colors.white, 
              letterSpacing: -0.5
            )).animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 3000.ms, color: AppTheme.highlight),
          ),
          SizedBox(height: LayoutEngine.scaleV(16, context)),

          // Top Border Water Flow Guard
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

          SizedBox(height: LayoutEngine.scaleV(40, context)),

          // Segmented Control (AMOLED Cleaned Update)
          Container(
            padding: EdgeInsets.all(LayoutEngine.scaleV(4, context)),
            decoration: BoxDecoration(
              color: const Color(0xFF000000), // Pure AMOLED black core
              borderRadius: BorderRadius.circular(LayoutEngine.scaleV(20, context)), // Tighter circle
              border: Border.all(color: AppTheme.neoBorder.withAlpha(50)), // Dimmed boundary
            ),
            child: Row(
              children: [
                Expanded(child: _SegmentButton(label: "Visual Effects", isSelected: state.mode == 'pixel', onTap: () => context.read<HardwareState>().setMode('pixel'), context: context)),
                Expanded(child: _SegmentButton(label: "Audio React", isSelected: state.mode == 'vu', onTap: () => context.read<HardwareState>().setMode('vu'), context: context)),
              ],
            ),
          ),
          SizedBox(height: LayoutEngine.scaleV(32, context)),

          // Algorithm Vault Button (AMOLED Luxe Mode)
          GestureDetector(
            onTap: () => _showAlgorithmVault(context, state),
            child: Container(
              padding: EdgeInsets.all(LayoutEngine.scaleV(20, context)),
              decoration: BoxDecoration(
                color: const Color(0xFF030303), // Zero muddy bleeding
                borderRadius: BorderRadius.circular(LayoutEngine.scaleV(24, context)),
                border: Border.all(color: AppTheme.highlight.withOpacity(0.3), width: 1.5),
                boxShadow: [BoxShadow(color: AppTheme.highlight.withOpacity(0.05), blurRadius: 20)], // Clean tight glow
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: LayoutEngine.scaleV(44, context), 
                        height: LayoutEngine.scaleV(44, context),
                        decoration: BoxDecoration(
                          color: AppTheme.highlight.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(LayoutEngine.scaleV(12, context)),
                        ),
                        child: Icon(state.mode == 'pixel' ? LucideIcons.sparkles : LucideIcons.activity, color: AppTheme.highlight, size: LayoutEngine.scaleV(22, context)),
                      ),
                      SizedBox(width: LayoutEngine.scaleV(16, context)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ALGORITHM", style: TextStyle(fontSize: LayoutEngine.scaleF(9, context), fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 2.0)),
                          SizedBox(height: LayoutEngine.scaleV(2, context)),
                          Text(state.activeAnimation, style: TextStyle(fontSize: LayoutEngine.scaleF(16, context), fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                        ],
                      )
                    ],
                  ),
                  Icon(LucideIcons.chevronRight, color: AppTheme.highlight.withOpacity(0.5), size: LayoutEngine.scaleV(24, context)), // Right arrow looks more luxury
                ],
              ),
            ),
          ),
          SizedBox(height: LayoutEngine.scaleV(32, context)),

          // Strip Display
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            padding: EdgeInsets.all(LayoutEngine.scaleV(24, context)),
            decoration: BoxDecoration(
              color: const Color(0xFF08080A),
              borderRadius: BorderRadius.circular(LayoutEngine.scaleV(32, context)),
              border: Border.all(color: AppTheme.neoBorder),
              boxShadow: state.isPowered 
                  ? [BoxShadow(color: glow.withOpacity(0.1), offset: Offset(0, LayoutEngine.scaleV(25, context)), blurRadius: 60)]
                  : [],
            ),
            child: WS2812Strip(
              count: 24, // Expanded to look more luxury
              mode: state.mode,
              animation: state.activeAnimation,
              activeColor: state.activeColor,
              colorMode: state.colorMode,
              isPowered: state.isPowered,
              brightness: state.brightness,
            ),
          ),
          SizedBox(height: LayoutEngine.scaleV(40, context)),

          // Spectral Hub
          Container(
            padding: EdgeInsets.all(LayoutEngine.scaleV(24, context)),
            decoration: BoxDecoration(
              color: const Color(0xFF030303), // Pushed to AMOLED depths
              borderRadius: BorderRadius.circular(LayoutEngine.scaleV(36, context)),
              border: Border.all(color: AppTheme.neoBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("SPECTRAL HUB", style: TextStyle(fontSize: LayoutEngine.scaleF(12, context), fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1.5)),
                    Container(
                      padding: EdgeInsets.all(LayoutEngine.scaleV(4, context)),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(LayoutEngine.scaleV(16, context)),
                        border: Border.all(color: AppTheme.neoBorder.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          _SpectralModeBtn("Auto", state.colorMode == 'multi', () => context.read<HardwareState>().setColorMode('multi'), context),
                          _SpectralModeBtn("Custom", state.colorMode == 'single', () => context.read<HardwareState>().setColorMode('single'), context),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: LayoutEngine.scaleV(28, context)),
                
                // Active Color Info
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: state.colorMode == 'single' ? 1.0 : 0.2,
                  child: IgnorePointer(
                    ignoring: state.colorMode != 'single',
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(LayoutEngine.scaleV(16, context)),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(LayoutEngine.scaleV(24, context)),
                            border: Border.all(color: AppTheme.neoBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("PRECISE HEX", style: TextStyle(fontSize: LayoutEngine.scaleF(10, context), fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1.5)),
                                  SizedBox(height: LayoutEngine.scaleV(4, context)),
                                  Text('#${state.activeColor.value.toRadixString(16).substring(2, 8).toUpperCase()}', 
                                       style: TextStyle(fontSize: LayoutEngine.scaleF(20, context), fontWeight: FontWeight.w900, fontFamily: 'monospace', color: Colors.white, letterSpacing: 2.0)),
                                ],
                              ),
                              Container(
                                width: LayoutEngine.scaleV(56, context), 
                                height: LayoutEngine.scaleV(56, context),
                                decoration: BoxDecoration(
                                  color: state.activeColor,
                                  borderRadius: BorderRadius.circular(LayoutEngine.scaleV(20, context)),
                                  border: Border.all(color: Colors.black, width: LayoutEngine.scaleV(4, context)),
                                  boxShadow: [BoxShadow(color: state.activeColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: LayoutEngine.scaleV(28, context)),
                        
                        // Hue Slider Replica
                        Container(
                          height: LayoutEngine.scaleV(56, context),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(LayoutEngine.scaleV(32, context)),
                            border: Border.all(color: Colors.black, width: LayoutEngine.scaleV(5, context)),
                            gradient: const LinearGradient(
                              colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 10)],
                          ),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                              thumbColor: state.activeColor,
                              overlayColor: state.activeColor.withOpacity(0.2),
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: LayoutEngine.scaleV(20, context), elevation: 10),
                            ),
                            child: Slider(
                              value: HSVColor.fromColor(state.activeColor).hue,
                              min: 0,
                              max: 360,
                              onChanged: (val) {
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
          )
        ],
      ),
    );
  }

  Widget _SegmentButton({required String label, required bool isSelected, required VoidCallback onTap, required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: LayoutEngine.scaleV(12, context)),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.highlight.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(LayoutEngine.scaleV(16, context)),
          border: Border.all(color: isSelected ? AppTheme.highlight.withOpacity(0.5) : Colors.transparent),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: LayoutEngine.scaleF(12, context),
              fontWeight: FontWeight.bold,
              color: isSelected ? AppTheme.highlight : Colors.white54,
              letterSpacing: 0.5,
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
        padding: EdgeInsets.symmetric(horizontal: LayoutEngine.scaleV(16, context), vertical: LayoutEngine.scaleV(8, context)),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.highlight : Colors.transparent,
          borderRadius: BorderRadius.circular(LayoutEngine.scaleV(12, context)),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: LayoutEngine.scaleF(10, context),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isSelected ? Colors.black : Colors.white54,
          ),
        ),
      ),
    );
  }

  void _showAlgorithmVault(BuildContext context, HardwareState state) {
    List<String> pixelAnims = ["Meteor Shower", "Rainbow Flow", "Aurora Borealis", "Solid Custom", "Cyber Sweep", "Galaxy Spin", "Starlight", "Fire Flicker", "Pulse Wave", "Comet Chase", "Neon Breath", "Ghost Fade"];
    List<String> vuAnims = ["Classic Left-Right", "Gravity Drop", "Center Out", "Split Edges", "Resonance", "Beat Flash", "Digital Wave", "Stereo Pulse"];
    List<String> currentList = state.mode == 'pixel' ? pixelAnims : vuAnims;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: const Color(0xFF030303), // AMOLED bottom sheet
            borderRadius: BorderRadius.vertical(top: Radius.circular(LayoutEngine.scaleV(40, context))),
            border: Border(top: BorderSide(color: AppTheme.highlight.withOpacity(0.5), width: 1.5)),
            boxShadow: [BoxShadow(color: AppTheme.highlight.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, -10))],
          ),
          child: Column(
            children: [
              SizedBox(height: LayoutEngine.scaleV(24, context)),
              Container(width: LayoutEngine.scaleV(64, context), height: LayoutEngine.scaleV(6, context), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              Padding(
                padding: EdgeInsets.all(LayoutEngine.scaleV(32, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ALGORITHM VAULT", style: TextStyle(fontSize: LayoutEngine.scaleF(20, context), fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(LayoutEngine.scaleV(10, context)),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.05))),
                        child: Icon(LucideIcons.x, color: Colors.white, size: LayoutEngine.scaleV(24, context)),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: LayoutEngine.scaleV(24, context), vertical: LayoutEngine.scaleV(8, context)),
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
                        height: LayoutEngine.scaleV(64, context),
                        margin: EdgeInsets.only(bottom: LayoutEngine.scaleV(12, context)),
                        padding: EdgeInsets.symmetric(horizontal: LayoutEngine.scaleV(24, context)),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.highlight.withOpacity(0.1) : const Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular(LayoutEngine.scaleV(24, context)),
                          border: Border.all(color: isActive ? AppTheme.highlight.withOpacity(0.5) : Colors.transparent),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currentList[i], style: TextStyle(fontSize: LayoutEngine.scaleF(15, context), fontWeight: FontWeight.w900, color: isActive ? AppTheme.highlight : Colors.white54, letterSpacing: -0.5)),
                            if (isActive) Icon(LucideIcons.zap, color: AppTheme.highlight, size: LayoutEngine.scaleV(20, context)),
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
