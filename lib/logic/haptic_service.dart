import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

enum HapticGrade {
  legacy,   // Samsung/Budget motors (Vibrate Fallback)
  midrange, // Crisp impacts
  flagship  // Ultra-realistic 3D immersive feel
}

class HapticService {
  static HapticGrade _currentGrade = HapticGrade.midrange;

  static void setGrade(HapticGrade grade) {
    _currentGrade = grade;
  }

  /// Trigger a haptic feedback event based on device capability
  static Future<void> trigger(HapticType type) async {
    if (kIsWeb) return;

    switch (_currentGrade) {
      case HapticGrade.legacy:
        await _triggerLegacy(type);
        break;
      case HapticGrade.midrange:
        await _triggerMidrange(type);
        break;
      case HapticGrade.flagship:
        await _triggerFlagship(type);
        break;
    }
  }

  static Future<void> _triggerLegacy(HapticType type) async {
    // UNIVERSAL FALLBACK (Samsung A-series, Budget Android)
    // Removed 'vibration' plugin dependency here as certain OEMs fail to initialize it.
    // HapticFeedback.heavyImpact() strictly routes to Android HapticFeedbackConstants.LONG_PRESS which cannot fail.
    try {
      switch (type) {
        case HapticType.selection:
        case HapticType.light:
          await HapticFeedback.selectionClick();
          break;
        case HapticType.medium:
        case HapticType.success:
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
        case HapticType.immersive:
          await HapticFeedback.heavyImpact(); 
          break;
      }
    } catch (_) {
      // If even that fails, force the absolute base vibrator channel without contexts
      await HapticFeedback.vibrate();
    }
  }

  static Future<void> _triggerMidrange(HapticType type) async {
    switch (type) {
      case HapticType.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticType.success:
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 40));
        await HapticFeedback.mediumImpact();
        break;
      case HapticType.immersive:
        await HapticFeedback.mediumImpact();
        break;
    }
  }

  static Future<void> _triggerFlagship(HapticType type) async {
    switch (type) {
      case HapticType.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticType.success:
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 30));
        await HapticFeedback.selectionClick();
        break;
      case HapticType.immersive:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 15));
        await HapticFeedback.lightImpact();
        break;
    }
  }
}

enum HapticType {
  selection,
  light,
  medium,
  heavy,
  success,
  immersive
}
