import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/layout_engine.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: LayoutEngine.scaleV(20, context), 
        right: LayoutEngine.scaleV(20, context), 
        top: LayoutEngine.scaleV(60, context), 
        bottom: LayoutEngine.scaleV(150, context)
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: LayoutEngine.scaleV(4, context)),
            child: Text("Configuration", style: TextStyle(
              fontSize: LayoutEngine.scaleF(34, context), 
              fontWeight: FontWeight.w900, 
              color: Colors.white, 
              letterSpacing: -0.5
            )),
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
          
          SizedBox(height: LayoutEngine.scaleV(30, context)),
          
          _buildSectionHeader("AESTHETICS & VISUALS", context),
          _buildSettingsCard([
            _buildInfoRow(LucideIcons.monitorSmartphone, Colors.cyan, "Display Engine", "Adaptive", context),
            _buildInfoRow(LucideIcons.type, AppTheme.accentNeon, "Typography", "Outfit GF", context),
            _buildSwitchRow(LucideIcons.maximize, Colors.deepPurpleAccent, "Immersive Full Screen", _isFullScreen, (v) {
              setState(() => _isFullScreen = v);
              if (v) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              } else {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              }
            }, context),
          ], context),

          _buildSectionHeader("HARDWARE INTEGRATION", context),
          _buildSettingsCard([
            _buildInfoRow(LucideIcons.flame, Colors.orange, "Firebase Bridge", "Online", context),
            _buildInfoRow(LucideIcons.layers, AppTheme.highlight, "IC Target Matrix", "WS2812B", context),
          ], context),

          _buildSectionHeader("IDENTITY & SUPPORT", context),
          _buildSettingsCard([
            _buildActionRow(LucideIcons.lifeBuoy, Colors.blueAccent, "Support Portal", context),
            _buildActionRow(LucideIcons.terminal, Colors.greenAccent, "Diagnostic Logs", context),
            _buildInfoRow(LucideIcons.fingerprint, Colors.white70, "Build Version", "V9.2.0 CORE", context, isLast: true),
          ], context),

          SizedBox(height: LayoutEngine.scaleV(50, context)),
          
          // Identity Watermark
          Center(
            child: Column(
              children: [
                Icon(LucideIcons.cpu, size: LayoutEngine.scaleV(32, context), color: AppTheme.highlight.withAlpha(50)),
                SizedBox(height: LayoutEngine.scaleV(16, context)),
                Text("PIXEL CONTROLLER", style: TextStyle(
                  fontSize: LayoutEngine.scaleF(14, context), 
                  fontWeight: FontWeight.w900, 
                  color: Colors.white54, 
                  letterSpacing: 4.0
                )),
                SizedBox(height: LayoutEngine.scaleV(8, context)),
                Text("C Y B E R G R I D   E D I T I O N", style: TextStyle(
                  fontSize: LayoutEngine.scaleF(9, context), 
                  fontWeight: FontWeight.w900, 
                  color: AppTheme.highlight.withAlpha(150), 
                  letterSpacing: 3.5
                )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: LayoutEngine.scaleV(8, context), bottom: LayoutEngine.scaleV(12, context), top: LayoutEngine.scaleV(24, context)),
      child: Text(title, style: TextStyle(
        fontSize: LayoutEngine.scaleF(12, context), 
        fontWeight: FontWeight.w900, 
        color: AppTheme.highlight.withAlpha(200), // Cyberpunk Section Header Glow
        letterSpacing: 1.5
      )),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBase, // Neo card base
        borderRadius: BorderRadius.circular(LayoutEngine.scaleV(32, context)),
        border: Border.all(color: AppTheme.neoBorder),
        boxShadow: [
          BoxShadow(color: AppTheme.highlight.withAlpha(5), blurRadius: 30, spreadRadius: -5)
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, Color iconColor, String label, String value, BuildContext context, {bool isLast = false}) {
    return _buildRowBase(icon, iconColor, label, context, isLast: isLast, trailing: Row(
      children: [
        Text(value.toUpperCase(), style: TextStyle(
          fontSize: LayoutEngine.scaleF(13, context), 
          fontWeight: FontWeight.w900, 
          color: Colors.white54,
          letterSpacing: 1.0
        )),
      ],
    ));
  }

  Widget _buildActionRow(IconData icon, Color iconColor, String label, BuildContext context) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: _buildRowBase(icon, iconColor, label, context, trailing: Icon(LucideIcons.chevronRight, color: AppTheme.highlight.withAlpha(128), size: LayoutEngine.scaleV(20, context))),
    );
  }

  Widget _buildSwitchRow(IconData icon, Color iconColor, String label, bool val, ValueChanged<bool> onChanged, BuildContext context) {
    return _buildRowBase(icon, iconColor, label, context, trailing: Switch(
      value: val,
      onChanged: onChanged,
      activeColor: AppTheme.highlight,
      activeTrackColor: AppTheme.highlight.withAlpha(50),
      inactiveThumbColor: Colors.white54,
      inactiveTrackColor: Colors.black26,
    ));
  }

  Widget _buildRowBase(IconData icon, Color iconColor, String label, BuildContext context, {required Widget trailing, bool isLast = false}) {
    return Container(
      height: LayoutEngine.scaleV(80, context),
      padding: EdgeInsets.symmetric(horizontal: LayoutEngine.scaleV(24, context)),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: AppTheme.dimBorder)),
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
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(LayoutEngine.scaleV(16, context)),
                  border: Border.all(color: AppTheme.dimBorder),
                ),
                child: Icon(icon, color: iconColor, size: LayoutEngine.scaleV(22, context)),
              ),
              SizedBox(width: LayoutEngine.scaleV(20, context)),
              Text(label, style: TextStyle(
                fontSize: LayoutEngine.scaleF(16, context), 
                fontWeight: FontWeight.w700, 
                color: Colors.white
              )),
            ],
          ),
          trailing
        ],
      ),
    );
  }
}
