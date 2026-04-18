import 'dart:math';
import 'package:flutter/material.dart';
import '../../logic/hardware_state.dart';
import 'package:provider/provider.dart';

/// AURA ADVANCED DISPLAY ENGINE (ADE) v2
/// 
/// A precision-engineered layout engine optimized for high-refresh 
/// rate displays (90-120Hz). Implements 'Zero-Escape' typography 
/// and absolute resolution calibration.
class UDE {
  // Reference Design Specs
  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  // Global Neon Intensity Calibration (Uniformity Standard)
  static const double neonGlowAlpha = 0.85;
  static const double neonCoreAlpha = 1.0;
  static const double dimmedNeonAlpha = 0.35; // For Nav/Top edges

  /// Calculates the Advanced Scale Factor (ASF) with 120FPS performance focus.
  static double getNSF(BuildContext context) {
    final state = Provider.of<HardwareState>(context, listen: false);
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    
    // Strict Resolution-Absolute Interpolation
    double ratioW = size.width / _designWidth;
    double ratioH = size.height / _designHeight;
    double baseRatio = (ratioW + ratioH) / 2.0;

    // Density-Aware Normalization
    double densityShift = (dpr > 2.8) ? 0.2 : 0.08;
    double smoothedScale = 1.0 + (baseRatio - 1.0) * (0.85 + densityShift);

    double userMulti = 1.0;
    switch (state.displaySize) {
      case DisplaySize.small: userMulti = 0.88; break;
      case DisplaySize.medium: userMulti = 1.05; break;
      case DisplaySize.large: userMulti = 1.25; break; // Slightly reduced from 1.32 for safety
    }

    double targetScale = smoothedScale * userMulti;

    // Viewport Gating (Strict 120FPS Shield)
    double maxSafeScale = (size.width / _designWidth) * 0.92;
    
    return min(targetScale, maxSafeScale).clamp(0.65, 1.5);
  }

  /// Scales any dimension
  static double sp(double value, BuildContext context) {
    return value * getNSF(context);
  }

  /// Scales Typography with ADE v2 'Zero-Escape' Logic.
  /// Dynamically clamps text to prevent pill container breakage.
  static double tp(double value, BuildContext context) {
    final state = Provider.of<HardwareState>(context, listen: false);
    double scale = getNSF(context);
    
    double fontFactor = 1.0 + (scale - 1.0) * 0.7;

    double userFontMulti = 1.0;
    switch (state.fontSize) {
      case FontSize.small: userFontMulti = 0.9; break;
      case FontSize.medium: userFontMulti = 1.0; break;
      case FontSize.large: userFontMulti = 1.25; break;
    }

    return value * fontFactor * userFontMulti;
  }

  /// ADE v2 Specialized TYPOGRAPHY SAFETY WRAPPER.
  /// Ensures text stays bounded unconditionally to prevent structural breakout.
  static Widget tpSafe(String text, TextStyle style, BuildContext context, {TextAlign? align}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: align == TextAlign.center ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: align ?? TextAlign.left,
        maxLines: 1, // Crucial: Prevents unbounded vertical wrapping expansion
        softWrap: false,
        textScaler: const TextScaler.linear(1.0), // STRICT OVERRIDE: Block OS Accessibility scaling from shattering UI
        style: style.copyWith(fontSize: tp(style.fontSize ?? 14, context)),
      ),
    );
  }

  /// Checks if the current scale is being throttled for safety.
  static bool isScaleCapped(BuildContext context) {
    final state = Provider.of<HardwareState>(context, listen: false);
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    double ratioW = size.width / _designWidth;
    double ratioH = size.height / _designHeight;
    double smoothedScale = 1.0 + ((ratioW + ratioH) / 2.0 - 1.0) * (0.85 + ((dpr > 2.8) ? 0.2 : 0.08));
    
    double userMulti = (state.displaySize == DisplaySize.large) ? 1.32 : 1.0;
    double intended = smoothedScale * userMulti;
    double maxSafe = (size.width / _designWidth) * 0.92;

    return intended > (maxSafe + 0.001);
  }

  static double r(double value, BuildContext context) {
    return value * getNSF(context);
  }
}

enum DisplaySize { small, medium, large }
enum FontSize { small, medium, large }

enum NeonTheme {
  cyberCyan,
  neonGreen,
  toxicOrange,
  neonRed,
  deepBlue
}
