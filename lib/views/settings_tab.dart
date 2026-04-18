import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../logic/hardware_state.dart';
import '../logic/haptic_service.dart';
import '../core/theme/app_theme.dart';
import '../core/engine/display_engine.dart';
import 'help_page.dart';

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
        left: UDE.sp(20, context), 
        right: UDE.sp(20, context), 
        top: UDE.sp(60, context), 
        bottom: UDE.sp(150, context)
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered Shimmering Title
          Center(
            child: Text("CONFIGURATION", style: TextStyle(
              fontSize: UDE.tp(28, context), 
              fontWeight: FontWeight.w900, 
              color: Colors.white, 
              letterSpacing: 8.0,
            )).animate(onPlay: (c) => c.repeat()).shimmer(
              duration: 3000.ms,
              color: Theme.of(context).primaryColor,
              size: 0.5,
            ),
          ),
          
          SizedBox(height: UDE.sp(40, context)),

          // Precision Top Border (Zero Bleed)
          CustomPaint(
            size: const Size(double.infinity, 2),
            painter: _CurvedNeonPainter(color: Theme.of(context).primaryColor.withOpacity(0.5)),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
            duration: 3000.ms, 
            color: Colors.white.withAlpha(50), 
            angle: 0.0,
          ),
          
          SizedBox(height: UDE.sp(30, context)),
          
          _buildSectionHeader("AESTHETICS & VISUALS", context),
          _buildSettingsCard([
            _buildThemeRow(context), // New Theme Selector
            _buildSelectionRow<DisplaySize>(
              LucideIcons.monitorSmartphone, Colors.cyan, "Display Size", 
              context.watch<HardwareState>().displaySize, 
              DisplaySize.values, (v) => context.read<HardwareState>().setDisplaySize(v), context,
              showLock: UDE.isScaleCapped(context) // Lock icon logic
            ),
            _buildSelectionRow<FontSize>(
              LucideIcons.type, Theme.of(context).primaryColor, "Font Size", 
              context.watch<HardwareState>().fontSize, 
              FontSize.values, (v) => context.read<HardwareState>().setFontSize(v), context
            ),
          ], context),

          _buildSectionHeader("HARDWARE INTEGRATION", context),
          Builder(builder: (ctx) {
            final hw = ctx.watch<HardwareState>();
            return _buildSettingsCard([
              _buildMatrixRow(context, hw),
            ], context);
          }),

          _buildSectionHeader("IDENTITY & SUPPORT", context),
          _buildSettingsCard([
            _buildActionRow(LucideIcons.lifeBuoy, Theme.of(context).primaryColor, "Support Portal", context, onTap: () {
              HapticService.trigger(HapticType.medium);
              _showSupportPopup(context);
            }),
            _buildActionRow(LucideIcons.helpCircle, Theme.of(context).colorScheme.secondary, "Features & Guide", context, onTap: () {
              HapticService.trigger(HapticType.light);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const HelpPage()));
            }),
            _buildActionRow(LucideIcons.terminal, Theme.of(context).primaryColor, "Diagnostic Logs", context, onTap: () {
              HapticService.trigger(HapticType.light);
              _showDiagnosticSheet(context, context.read<HardwareState>());
            }),
            _buildInfoRow(LucideIcons.fingerprint, Colors.white30, "Build Version", "v1.0.0 Stable", context, isLast: true),
          ], context),

          SizedBox(height: UDE.sp(50, context)),
          
          // Identity Watermark
          Center(
            child: Column(
              children: [
                Icon(LucideIcons.cpu, size: UDE.sp(32, context), color: Theme.of(context).primaryColor.withAlpha(50)),
                SizedBox(height: UDE.sp(16, context)),
                Text("PIXEL CONTROLLER", style: TextStyle(
                  fontSize: UDE.tp(14, context), 
                  fontWeight: FontWeight.w900, 
                  color: Colors.white54, 
                  letterSpacing: 4.0
                )),
                SizedBox(height: UDE.sp(8, context)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.github, size: UDE.sp(14, context), color: Theme.of(context).primaryColor),
                    SizedBox(width: UDE.sp(8, context)),
                    Text("K I R A N _ E M B E D D E D", style: TextStyle(
                      fontSize: UDE.tp(9, context), 
                      fontWeight: FontWeight.w900, 
                      color: Theme.of(context).primaryColor.withAlpha(200), 
                      letterSpacing: 3.5
                    )).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3000.ms, color: Colors.white),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: UDE.sp(8, context), bottom: UDE.sp(12, context), top: UDE.sp(24, context)),
      child: Center(
        child: Text(title, style: TextStyle(
          fontSize: UDE.tp(12, context), 
          fontWeight: FontWeight.w900, 
          color: Theme.of(context).primaryColor.withOpacity(0.8), 
          letterSpacing: 1.5
        )),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF020202), // Pure AMOLED Black
        borderRadius: BorderRadius.circular(UDE.sp(32, context)),
        border: Border.all(color: Theme.of(context).primaryColor.withAlpha(30)),
        boxShadow: [
          BoxShadow(color: Theme.of(context).primaryColor.withAlpha(5), blurRadius: 30, spreadRadius: -5)
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
          fontSize: UDE.tp(13, context), 
          fontWeight: FontWeight.w900, 
          color: Colors.white54,
          letterSpacing: 1.0
        )),
      ],
    ));
  }

  Widget _buildActionRow(IconData icon, Color iconColor, String label, BuildContext context, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _buildRowBase(icon, iconColor, label, context, trailing: Icon(LucideIcons.chevronRight, color: Theme.of(context).primaryColor.withAlpha(128), size: UDE.sp(20, context))),
    );
  }

  Widget _buildSwitchRow(IconData icon, Color iconColor, String label, bool val, ValueChanged<bool> onChanged, BuildContext context) {
    return _buildRowBase(icon, iconColor, label, context, trailing: Switch(
      value: val,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
      activeTrackColor: Theme.of(context).primaryColor.withAlpha(50),
      inactiveThumbColor: Colors.white54,
      inactiveTrackColor: Colors.black26,
    ));
  }

  Widget _buildRowBase(IconData icon, Color iconColor, String label, BuildContext context, {required Widget trailing, bool isLast = false}) {
    return Container(
      height: UDE.sp(70, context),
      padding: EdgeInsets.symmetric(horizontal: UDE.sp(20, context)),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: UDE.sp(18, context)),
              SizedBox(width: UDE.sp(16, context)),
              Text(label, style: TextStyle(
                fontSize: UDE.tp(14, context), 
                fontWeight: FontWeight.w600, 
                color: Colors.white.withOpacity(0.9)
              )),
            ],
          ),
          trailing
        ],
      ),
    );
  }

  Widget _buildThemeRow(BuildContext context) {
    final state = context.watch<HardwareState>();
    final accent = Theme.of(context).primaryColor;

    return _buildRowBase(LucideIcons.palette, accent, "System Aesthetic", context, trailing: Row(
      children: NeonTheme.values.map((t) {
        bool isSelected = state.activeTheme == t;
        Color themeColor = AppTheme.getHighlight(t);
        return GestureDetector(
          onTap: () {
            HapticService.trigger(HapticType.selection);
            state.setNeonTheme(t);
          },
          child: Container(
            margin: EdgeInsets.only(left: UDE.sp(8, context)),
            width: UDE.sp(20, context),
            height: UDE.sp(20, context),
            decoration: BoxDecoration(
              color: themeColor,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
              boxShadow: [
                if (isSelected) BoxShadow(color: themeColor.withOpacity(0.5), blurRadius: 10)
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildSelectionRow<T>(IconData icon, Color iconColor, String label, T current, List<T> values, ValueChanged<T> onChanged, BuildContext context, {bool showLock = false}) {
    return _buildRowBase(icon, iconColor, label, context, trailing: Row(
      children: [
        if (showLock) Icon(LucideIcons.lock, color: Colors.orangeAccent, size: UDE.sp(14, context)),
        SizedBox(width: UDE.sp(8, context)),
        ...values.map((v) {
          bool isSelected = v == current;
          return GestureDetector(
            onTap: () => onChanged(v),
            child: Container(
              margin: EdgeInsets.only(left: UDE.sp(8, context)),
              padding: EdgeInsets.symmetric(horizontal: UDE.sp(12, context), vertical: UDE.sp(6, context)),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(UDE.sp(12, context)),
                border: Border.all(color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.5) : Colors.white10),
              ),
              child: Text(v.toString().split('.').last.toUpperCase(), style: TextStyle(
                fontSize: UDE.tp(10, context),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                color: isSelected ? Theme.of(context).primaryColor : Colors.white38,
              )),
            ),
          );
        }).toList(),
      ],
    ));
  }

  Widget _buildMatrixRow(BuildContext context, HardwareState hw) {
    return _buildActionRow(LucideIcons.layers, Theme.of(context).primaryColor, "Matrix Density", context, onTap: () {
      _showMatrixDialog(context, hw);
    });
  }

  void _showMatrixDialog(BuildContext context, HardwareState hw) {
    final controller = TextEditingController(text: hw.numLeds.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF020202),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3))),
        title: Text("MATRIX CONFIG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: UDE.tp(18, context))),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Number of LEDs",
            labelStyle: const TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) hw.setNumLeds(val);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text("APPLY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSupportPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF020202).withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 1),
          ),
          padding: EdgeInsets.all(UDE.sp(24, context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              SizedBox(height: UDE.sp(30, context)),
              Icon(LucideIcons.lifeBuoy, size: UDE.sp(52, context), color: Theme.of(context).primaryColor),
              SizedBox(height: UDE.sp(20, context)),
              Text("AURORA SUPPORT", style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w900, 
                fontSize: UDE.tp(22, context), 
                letterSpacing: 2
              )),
              SizedBox(height: UDE.sp(8, context)),
              Text("HIGH-END HARDWARE ASSISTANCE", style: TextStyle(
                color: Theme.of(context).primaryColor.withOpacity(0.7), 
                fontWeight: FontWeight.w700, 
                fontSize: UDE.tp(9, context), 
                letterSpacing: 3
              )),
              SizedBox(height: UDE.sp(40, context)),
              _supportItem(LucideIcons.mail, "Official Email", "kiran.cybergrid@gmail.com", context),
              _supportItem(LucideIcons.github, "GitHub Repository", "kiran-embedded/aurora-pixel-controller", context),
              SizedBox(height: UDE.sp(20, context)),
              _supportItem(LucideIcons.messageSquare, "Community Help", "Join Discord Community", context),
              SizedBox(height: UDE.sp(40, context)),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("DISMISS PORTAL", style: TextStyle(
                  color: Colors.white54, 
                  fontWeight: FontWeight.w700, 
                  fontSize: UDE.tp(12, context), 
                  letterSpacing: 1.5
                )),
              ),
              SizedBox(height: UDE.sp(20, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supportItem(IconData icon, String title, String sub, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: UDE.sp(16, context)),
      padding: EdgeInsets.all(UDE.sp(20, context)),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(UDE.sp(24, context)),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: UDE.sp(24, context)),
          SizedBox(width: UDE.sp(20, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text("SPECTRAL HUB", style: TextStyle(
                    fontSize: UDE.tp(12, context), 
                    fontWeight: FontWeight.w900, 
                    color: Theme.of(context).primaryColor.withOpacity(0.8), 
                    letterSpacing: 1.5
                  )),
                ),
                SizedBox(height: UDE.sp(24, context)),
                Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: UDE.tp(14, context))),
                SizedBox(height: UDE.sp(4, context)),
                Text(sub, style: TextStyle(color: Colors.white54, fontSize: UDE.tp(11, context))),
              ],
            ),
          ),
          Icon(LucideIcons.externalLink, color: Colors.white24, size: UDE.sp(14, context)),
        ],
      ),
    );
  }

  void _showDiagnosticSheet(BuildContext context, HardwareState hw) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: const Color(0xFF020202),
            borderRadius: BorderRadius.vertical(top: Radius.circular(UDE.sp(40, context))),
            border: Border(top: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.5)),
          ),
          child: Column(
            children: [
              SizedBox(height: UDE.sp(24, context)),
              Container(width: UDE.sp(64, context), height: 6, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              Padding(
                padding: EdgeInsets.all(UDE.sp(32, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("DIAGNOSTIC LOG", style: TextStyle(fontSize: UDE.tp(20, context), fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(UDE.sp(10, context)),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.05))),
                        child: Icon(LucideIcons.x, color: Colors.white, size: UDE.sp(24, context)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: UDE.sp(32, context)),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _diagRow("Firebase", hw.isFirebaseReady ? (hw.isConnected ? "CONNECTED" : "DISCONNECTED") : "NOT INIT", hw.isConnected ? Colors.greenAccent : Colors.orange, context),
                    _diagRow("Power State", hw.isPowered ? "ON" : "OFF", hw.isPowered ? Colors.greenAccent : Colors.redAccent, context),
                    _diagRow("Mode", hw.mode.toUpperCase(), Theme.of(ctx).primaryColor, context),
                    _diagRow("Algorithm", hw.activeAnimation, Theme.of(ctx).primaryColor, context),
                    _diagRow("Brightness", '${hw.brightness}%', Colors.white, context),
                    _diagRow("Color Mode", hw.colorMode.toUpperCase(), Colors.white, context),
                    _diagRow("Active Color", '#${hw.activeColor.value.toRadixString(16).substring(2, 8).toUpperCase()}', Colors.white, context),
                    _diagRow("DB Path", 'devices/esp32_pixel_controller/state', Colors.white54, context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _diagRow(String label, String value, Color valueColor, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: UDE.sp(14, context)),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.dimBorder))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: UDE.tp(14, context), fontWeight: FontWeight.w700, color: Colors.white54)),
          Text(value, style: TextStyle(fontSize: UDE.tp(13, context), fontWeight: FontWeight.w900, color: valueColor, fontFamily: 'monospace', letterSpacing: 1.0)),
        ],
      ),
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
