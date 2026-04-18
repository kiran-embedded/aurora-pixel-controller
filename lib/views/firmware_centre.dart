import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../core/engine/display_engine.dart';
import '../logic/haptic_service.dart';

class FirmwareCentre extends StatelessWidget {
  const FirmwareCentre({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: UDE.sp(140, context),
            backgroundColor: Colors.black,
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: UDE.tpSafe("FIRMWARE CENTRE", TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
                color: themeColor,
              ), context, align: TextAlign.center),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [themeColor.withOpacity(0.15), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(UDE.sp(20, context)),
              child: Column(
                children: [
                   _buildInfoCard(context),
                   SizedBox(height: UDE.sp(30, context)),
                   _buildBoardItem(
                     "ESP32 WROOM", 
                     "Flagship Performance. Dual Core. BLE + Wi-Fi. (FIREBASE RTDB)", 
                     LucideIcons.cpu, 
                     "assets/firmwares/ESP32_Aurora.ino",
                     context
                   ),
                   _buildBoardItem(
                     "ESP8266 (NodeMCU)", 
                     "Standard Efficiency. IoT Optimized. Single Core. (FIREBASE RTDB)", 
                     LucideIcons.microscope, 
                     "assets/firmwares/ESP8266_Aurora.ino",
                     context
                   ),
                   SizedBox(height: UDE.sp(80, context)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UDE.sp(24, context)),
      decoration: BoxDecoration(
        color: const Color(0xFF020202),
        borderRadius: BorderRadius.circular(UDE.r(24, context)),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.shieldCheck, color: Theme.of(context).primaryColor, size: UDE.sp(40, context))
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 2000.ms),
          SizedBox(height: UDE.sp(16, context)),
          Text("CERTIFIED FIRMWARE", style: TextStyle(
            fontSize: UDE.tp(14, context),
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2.0
          )),
          SizedBox(height: UDE.sp(12, context)),
          Text(
            "All firmwares are non-blocking, interrupt-safe, and ready for 120FPS sync. Select your hardware to begin deployment.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: UDE.tp(11, context), color: Colors.white54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardItem(String title, String desc, IconData icon, String assetPath, BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    return Container(
      margin: EdgeInsets.only(bottom: UDE.sp(20, context)),
      decoration: BoxDecoration(
        color: const Color(0xFF020202),
        borderRadius: BorderRadius.circular(UDE.r(32, context)),
        border: Border.all(color: themeColor.withAlpha(30)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(UDE.sp(20, context)),
            leading: Container(
              padding: EdgeInsets.all(UDE.sp(12, context)),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: themeColor, size: UDE.sp(24, context)),
            ),
            title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: UDE.tp(16, context))),
            subtitle: Text(desc, style: TextStyle(color: Colors.white38, fontSize: UDE.tp(12, context))),
          ),
          Padding(
            padding: EdgeInsets.only(left: UDE.sp(20, context), right: UDE.sp(20, context), bottom: UDE.sp(20, context)),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    "COPY FULL FIRMWARE (.INO)", 
                    LucideIcons.copy, 
                    themeColor, 
                    () => _copyCode(assetPath, context), 
                    context
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionBtn(String label, IconData icon, Color color, VoidCallback onTap, BuildContext context) {
    bool isPrimary = color != Colors.white24;
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticType.selection);
        onTap();
      },
      child: Container(
        height: UDE.sp(45, context),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(UDE.r(16, context)),
          border: isPrimary ? null : Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: UDE.sp(16, context), color: isPrimary ? Colors.black : Colors.white70),
            SizedBox(width: UDE.sp(8, context)),
            Text(label, style: TextStyle(
              fontSize: UDE.tp(10, context), 
              fontWeight: FontWeight.w900, 
              color: isPrimary ? Colors.black : Colors.white70
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _launchDownload(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  void _copyCode(String assetPath, BuildContext context) async {
    final String data = await rootBundle.loadString(assetPath);
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text("FIRMWARE CODE COPIED TO CLIPBOARD", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
