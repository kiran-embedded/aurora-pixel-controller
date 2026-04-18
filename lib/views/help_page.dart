import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../core/engine/display_engine.dart';
import 'firmware_centre.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
              title: UDE.tpSafe("AURORA BOOKLET", TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
                color: themeColor,
              ), context, align: TextAlign.center),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(UDE.sp(20, context)),
              child: Column(
                children: [
                   _buildFirmwareBridge(context),
                   SizedBox(height: UDE.sp(30, context)),
                   _buildSectionTitle("HARDWARE DEPLOYMENT", themeColor, context),
                   _buildFeatureCard(
                     "ESP32 Pinout (Recommended)", 
                     "• LED Data: Pin 13\n• MIC Input: Pin 34 (Analog)\n• Power: 5V / GND\nSupports 120FPS via I2S.", 
                     LucideIcons.cpu, 
                     context
                   ),
                   _buildFeatureCard(
                     "ESP8266 Pinout", 
                     "• LED Data: Pin D4 (GPIO2)\n• 100uF Capacitor recommended between VCC and GND for stability.", 
                     LucideIcons.microscope, 
                     context
                   ),
                   SizedBox(height: UDE.sp(20, context)),
                   _buildSectionTitle("SIGNAL OPTIMIZATION", themeColor, context),
                   _buildFeatureCard(
                     "Noise Reduction Logic", 
                     "The firmware uses an Exponential Moving Average (EMA) to filter background hum. Adjust sensitivity in the Studio tab.", 
                     LucideIcons.activity, 
                     context
                   ),
                   _buildFeatureCard(
                     "MIC Sensitivity Tuning", 
                     "Position MIC away from noisy fans. Use shielded cables for high-density LED strips to prevent EMI interference.", 
                     LucideIcons.mic2, 
                     context
                   ),

                   SizedBox(height: UDE.sp(40, context)),
                   _buildSupportLinks(context),
                   SizedBox(height: UDE.sp(100, context)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: UDE.sp(16, context)),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          SizedBox(width: 12),
          Text(title, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: UDE.tp(11, context), letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildFirmwareBridge(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FirmwareCentre())),
      child: Container(
        padding: EdgeInsets.all(UDE.sp(24, context)),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [themeColor.withOpacity(0.2), Colors.transparent]),
          borderRadius: BorderRadius.circular(UDE.r(24, context)),
          border: Border.all(color: themeColor.withAlpha(50)),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.downloadCloud, color: themeColor, size: UDE.sp(32, context)),
            SizedBox(width: UDE.sp(20, context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("FIRMWARE HUB", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: UDE.tp(16, context))),
                  Text("Download stable binaries for ESP32 & Arduino.", style: TextStyle(color: Colors.white54, fontSize: UDE.tp(11, context))),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: themeColor, size: UDE.sp(20, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportLinks(BuildContext context) {
    return Column(
      children: [
        _buildSupportItem(LucideIcons.github, "Official GitHub", "View Code & Releases", "https://github.com/kiran-embedded/aurora-pixel-controller", context),
        _buildSupportItem(LucideIcons.mail, "Technical Email", "kiran.cybergrid@gmail.com", "mailto:kiran.cybergrid@gmail.com", context),
      ],
    );
  }

  Widget _buildSupportItem(IconData icon, String title, String sub, String url, BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        margin: EdgeInsets.only(bottom: UDE.sp(12, context)),
        padding: EdgeInsets.symmetric(horizontal: UDE.sp(20, context), vertical: UDE.sp(16, context)),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: UDE.sp(20, context)),
            SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: UDE.tp(13, context))),
                Text(sub, style: TextStyle(color: Colors.white38, fontSize: UDE.tp(11, context))),
              ],
            )),
            Icon(LucideIcons.externalLink, color: Colors.white24, size: UDE.sp(14, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String desc, IconData icon, BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    return Container(
      margin: EdgeInsets.only(bottom: UDE.sp(16, context)),
      padding: EdgeInsets.all(UDE.sp(20, context)),
      decoration: BoxDecoration(
        color: const Color(0xFF020202),
        borderRadius: BorderRadius.circular(UDE.r(24, context)),
        border: Border.all(color: themeColor.withAlpha(20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: themeColor, size: UDE.sp(22, context)),
          SizedBox(width: UDE.sp(16, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: TextStyle(
                  fontSize: UDE.tp(13, context),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5
                )),
                SizedBox(height: UDE.sp(6, context)),
                Text(desc, style: TextStyle(
                  fontSize: UDE.tp(11, context),
                  color: Colors.white54,
                  height: 1.5
                )),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }
}
