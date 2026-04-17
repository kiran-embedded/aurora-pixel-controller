import 'package:flutter/material.dart';

class LayoutEngine {
  /// Base design dimension. All original padding/margins were designed for ~390 width.
  static const double _baseWidth = 390.0;

  /// Retrieves intelligent mathematical scale multiplier based on device screen.
  static double getScale(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    
    // Calculate raw ratio
    double ratio = screenWidth / _baseWidth;
    
    // Clamp the ratio to prevent components from becoming microscopically small 
    // on thin phones or comically large on tablets.
    if (ratio < 0.85) return 0.85;
    if (ratio > 1.25) return 1.25;
    
    return ratio;
  }

  /// Scales vertical/horizontal space (Padding, Heights, Margins) mathematically
  static double scaleV(double base, BuildContext context) {
    return base * getScale(context);
  }

  /// Scales Typography fonts intelligently
  static double scaleF(double base, BuildContext context) {
    // Fonts don't need to scale as aggressively as paddings.
    double fontScale = getScale(context);
    // Soften font scaling
    if (fontScale > 1.0) fontScale = 1.0 + (fontScale - 1.0) * 0.5;
    if (fontScale < 1.0) fontScale = 1.0 - (1.0 - fontScale) * 0.5;
    return base * fontScale;
  }
}
