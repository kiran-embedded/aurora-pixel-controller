import 'dart:math';
import 'package:flutter/material.dart';

class SimulatedLED {
  final Color color;
  final double opacity;
  final double scale;
  final double blurRadius;

  SimulatedLED({
    required this.color,
    required this.opacity,
    required this.scale,
    required this.blurRadius,
  });
}

class EffectEngine {
  static SimulatedLED simulate(
    int index,
    int count,
    double progress,
    String mode,
    String animation,
    Color activeColor,
    String colorMode,
    bool isPowered,
    double vuLevel,
  ) {
    if (!isPowered) {
      return SimulatedLED(color: Colors.black, opacity: 0, scale: 0.8, blurRadius: 0);
    }

    String name = animation.toLowerCase();
    Color ledColor = activeColor;
    double scale = 1.0;
    double opacity = 1.0;
    double blurRadius = 12.0;

    // Helper for multi-color mode gradient
    Color getMultiColor(double pos) {
      return HSVColor.fromAHSV(1.0, (pos * 360) % 360, 1.0, 1.0).toColor();
    }
    
    // Helper for VU colors
    Color getVuColor(double pos) {
      if (colorMode == 'single') return activeColor;
      if (pos < 0.6) return const Color(0xFF00E676);
      if (pos < 0.85) return const Color(0xFFFFEA00);
      return const Color(0xFFFF1744);
    }

    if (mode == 'pixel') {
      double pos = index / count;
      bool isMulti = colorMode == 'single' ? false : true;

      switch (name) {
        case 'solid custom':
          ledColor = isMulti ? getMultiColor(pos) : activeColor;
          opacity = 1.0;
          blurRadius = 14.0; // Increased base glow
          break;
        case 'meteor shower':
          double delay = index * 0.1;
          double localProgress = (progress - delay) % 1.0;
          if (localProgress < 0) localProgress += 1.0;
          ledColor = isMulti ? getMultiColor(pos) : activeColor;
          if (localProgress < 0.1) {
            opacity = 1.0; scale = 1.1; blurRadius = 12.0;
          } else if (localProgress < 0.3) {
            opacity = 0.6; scale = 1.0; blurRadius = 6.0;
          } else {
            opacity = 0.2; scale = 0.8; blurRadius = 2.0;
          }
          break;
        case 'rainbow flow':
          ledColor = getMultiColor((pos + progress) % 1.0);
          opacity = 1.0;
          blurRadius = 15.0;
          break;
        case 'aurora borealis':
          double val = (sin(pos * 4 * pi + progress * 2 * pi) + 1) / 2;
          ledColor = isMulti ? getMultiColor((pos + progress * 0.5) % 1.0) : activeColor;
          opacity = 0.5 + (0.5 * val);
          blurRadius = 10.0 * val;
          break;
        case 'cyber sweep':
          double sweep = (progress * 2) % 1.0;
          double dist = (pos - sweep).abs();
          if (dist > 0.5) dist = 1.0 - dist;
          if (dist < 0.1) {
            opacity = 1.0; scale = 1.2; blurRadius = 15.0;
          } else if (dist < 0.2) {
            opacity = 0.6; scale = 1.0; blurRadius = 5.0;
          } else {
            opacity = 0.15; scale = 0.8; blurRadius = 2.0;
          }
          ledColor = isMulti ? const Color(0xFF00FFCC) : activeColor;
          break;
        case 'galaxy spin':
          double spin = (pos * 2 - progress * 3) % 1.0;
          if (spin < 0) spin += 1.0;
          ledColor = getMultiColor(spin);
          opacity = spin < 0.5 ? 0.3 + (spin * 1.4) : 0.3 + ((1.0 - spin) * 1.4);
          blurRadius = opacity * 12.0;
          break;
        case 'starlight':
          double twinkle = Random(index ^ (progress * 10).floor()).nextDouble();
          ledColor = isMulti ? (twinkle > 0.5 ? Colors.white : Colors.blueAccent) : activeColor;
          opacity = twinkle > 0.9 ? 1.0 : 0.2;
          blurRadius = twinkle > 0.9 ? 15.0 : 2.0;
          scale = twinkle > 0.9 ? 1.15 : 0.9;
          break;
        case 'fire flicker':
          double fire = Random(index ^ (progress * 20).floor()).nextDouble();
          ledColor = isMulti ? HSVColor.fromAHSV(1.0, fire * 40, 1.0, 1.0).toColor() : activeColor;
          opacity = 0.6 + (fire * 0.4);
          blurRadius = 4.0 + (fire * 8.0);
          break;
        case 'pulse wave':
          double wave = (sin(pos * 2 * pi - progress * 4 * pi) + 1) / 2;
          ledColor = isMulti ? getMultiColor(pos) : activeColor;
          opacity = 0.4 + (0.6 * wave);
          scale = 0.9 + (0.2 * wave);
          blurRadius = 18.0 * wave;
          break;
        case 'comet chase':
          double head = progress % 1.0;
          double dist2 = (pos - head);
          if (dist2 < 0) dist2 += 1.0;
          if (dist2 > 0.8) {
            opacity = (dist2 - 0.8) * 5; // Trail
            blurRadius = opacity * 15;
          } else if (dist2 < 0.05) {
            opacity = 1.0; scale = 1.2; blurRadius = 25.0; // Head
          } else {
            opacity = 0.1; blurRadius = 1.0;
          }
          ledColor = isMulti ? getMultiColor(progress) : activeColor;
          break;
        case 'neon breath':
          double breath = (sin(progress * 2 * pi) + 1) / 2;
          ledColor = isMulti ? const Color(0xFFFF00FF) : activeColor;
          opacity = 0.4 + (0.6 * breath);
          scale = 0.95 + (0.05 * breath);
          blurRadius = 12.0 * breath;
          break;
        case 'ghost fade':
          double ghost = Random(index ^ (progress * 5).floor()).nextDouble();
          ledColor = isMulti ? Colors.white.withOpacity(0.5) : activeColor;
          opacity = ghost > 0.8 ? (ghost - 0.8) * 5 : 0.05;
          blurRadius = opacity * 20.0;
          break;
        case 'scanner': // Cylon
          double scan = (sin(progress * 2 * pi) + 1) / 2;
          double scanDist = (pos - scan).abs();
          if (scanDist < 0.05) {
            opacity = 1.0; scale = 1.2; blurRadius = 25.0;
          } else if (scanDist < 0.15) {
            opacity = 0.5; scale = 1.0; blurRadius = 8.0;
          } else {
            opacity = 0.1; scale = 0.8; blurRadius = 2.0;
          }
          ledColor = isMulti ? Colors.red : activeColor;
          break;
        case 'plasma flow':
          double plasma = (sin(pos * 4 * pi + progress * 4 * pi) + cos(pos * 3 * pi - progress * 2 * pi) + 2) / 4;
          ledColor = isMulti ? getMultiColor(plasma) : activeColor;
          opacity = 0.6 + (0.4 * plasma);
          blurRadius = 8.0 * plasma;
          break;
        case 'matrix rain':
          double rainDelay = (index * 0.3) % 1.0;
          double rainProg = (progress * 2 - rainDelay) % 1.0;
          if (rainProg < 0) rainProg += 1.0;
          ledColor = isMulti ? const Color(0xFF00FF00) : activeColor;
          if (rainProg < 0.1) {
            opacity = 1.0; scale = 1.15; blurRadius = 25.0; ledColor = Colors.white;
          } else if (rainProg < 0.6) {
            opacity = 1.0 - ((rainProg - 0.1) * 2.0); // Smoother, longer tail decay mimicking fadeToBlackBy
            blurRadius = opacity * 12.0;
          } else {
            opacity = 0.15; blurRadius = 1.0; // Persistent matrix background glow
          }
          break;
        case 'color wipe':
          double wipe = progress % 1.0;
          opacity = pos <= wipe ? 1.0 : 0.1;
          ledColor = isMulti ? getMultiColor(pos) : activeColor;
          blurRadius = opacity > 0.15 ? 15.0 : 1.0;
          break;
        case 'theater chase':
          int step = (progress * 15).floor() % 3;
          bool on = (index % 3) == step;
          opacity = on ? 1.0 : 0.1;
          ledColor = isMulti ? getMultiColor(pos) : activeColor;
          blurRadius = on ? 15.0 : 1.0;
          break;
        case 'twinkle fox':
          double fox = Random(index ^ (progress * 8).floor()).nextDouble();
          ledColor = isMulti ? getMultiColor(Random(index).nextDouble()) : activeColor;
          opacity = fox > 0.85 ? 1.0 : 0.2;
          blurRadius = fox > 0.85 ? 18.0 : 1.0;
          break;
        case 'sparkle':
          bool spk = Random(index ^ (progress * 30).floor()).nextDouble() > 0.95;
          ledColor = isMulti ? Colors.white : activeColor;
          opacity = spk ? 1.0 : 0.05;
          blurRadius = spk ? 25.0 : 0.0;
          break;
        case 'bouncing balls':
          double ballPos = (sin(progress * 2 * pi).abs());
          double distBall = (pos - ballPos).abs();
          if (distBall < 0.05) {
            opacity = 1.0; scale = 1.25; blurRadius = 12.0;
            ledColor = isMulti ? Colors.redAccent : activeColor;
          } else {
            opacity = 0.15; blurRadius = 1.0;
            ledColor = isMulti ? Colors.blue[900]! : activeColor;
          }
          break;
        case 'sine wave':
          double sne = (sin(pos * 2 * pi + progress * 4 * pi) + 1) / 2;
          opacity = 0.3 + (0.7 * sne);
          ledColor = isMulti ? getMultiColor(pos) : activeColor;
          blurRadius = 4.0 + (sne * 10.0);
          break;
        case 'popcorn':
          double pop = Random(index ^ (progress * 12).floor()).nextDouble();
          if (pop > 0.9) {
            opacity = 1.0; scale = 1.35; blurRadius = 15.0;
            ledColor = isMulti ? HSVColor.fromAHSV(1.0, pop * 360, 1.0, 1.0).toColor() : activeColor;
          } else {
            opacity = 0.2; scale = 0.9; blurRadius = 1.0;
            ledColor = activeColor;
          }
          break;
        case 'hyper jump':
          int hStep = (progress * 20).floor() % count;
          bool hOn = index == hStep || index == count - 1 - hStep;
          opacity = hOn ? 1.0 : 0.2;
          blurRadius = hOn ? 10.0 : 1.0;
          ledColor = isMulti ? Colors.cyanAccent : activeColor;
          break;
        case 'water ripple':
          double center = 0.5;
          double distRip = (pos - center).abs();
          double ripRipple = (sin((distRip * 10) - (progress * 10)) + 1) / 2;
          opacity = 0.3 + (0.7 * ripRipple);
          blurRadius = 4.0 + (ripRipple * 8.0);
          ledColor = isMulti ? Colors.blueAccent : activeColor;
          break;
        case 'candy cane':
          double cProg = (pos * 10 + progress * 5) % 1.0;
          bool cRed = cProg > 0.5;
          ledColor = cRed ? Colors.red : Colors.white;
          if (!isMulti) ledColor = cRed ? activeColor : Colors.white;
          opacity = 1.0; blurRadius = 12.0;
          break;
        default:
          ledColor = isMulti ? getMultiColor(pos) : activeColor;
          opacity = 1.0;
          blurRadius = 12.0;
          break;
      }
    } else {
      // VU Animations Mode
      double pos = index / count;
      bool isPeak = index == vuLevel.floor();
      bool isAtOrBelow = index <= vuLevel;
      double normalizedVu = vuLevel / count;

      switch (name) {
        case 'classic left-right':
          ledColor = getVuColor(pos);
          opacity = isAtOrBelow ? 1.0 : 0.1;
          blurRadius = isAtOrBelow ? 10.0 : 0.0;
          break;
        case 'gravity drop':
          ledColor = isPeak ? Colors.white : getVuColor(pos);
          opacity = isAtOrBelow ? 1.0 : 0.1;
          blurRadius = isPeak ? 15.0 : (isAtOrBelow ? 8.0 : 0.0);
          scale = isPeak ? 1.3 : 1.0;
          if (!isAtOrBelow && !isPeak) opacity = 0.05;
          break;
        case 'center out':
          double centerDist = (pos - 0.5).abs() * 2.0; // 0 at center, 1 at edges
          bool inRange = centerDist <= normalizedVu;
          ledColor = getVuColor(centerDist);
          opacity = inRange ? 1.0 : 0.1;
          blurRadius = inRange ? 12.0 : 1.0;
          break;
        case 'split edges':
          double edgeDist = pos < 0.5 ? (0.5 - pos) * 2.0 : (pos - 0.5) * 2.0;
          bool inEdge = (1.0 - edgeDist) <= normalizedVu;
          ledColor = getVuColor(1.0 - edgeDist);
          opacity = inEdge ? 1.0 : 0.1;
          blurRadius = inEdge ? 16.0 : 1.0;
          break;
        case 'resonance':
          ledColor = getVuColor(pos);
          double resVal = (sin(pos * pi * normalizedVu * 10 + progress * 10) + 1) / 2;
          opacity = isAtOrBelow ? (0.4 + 0.6 * resVal) : 0.1;
          blurRadius = isAtOrBelow ? resVal * 20.0 : 1.0;
          break;
        case 'beat flash':
          ledColor = colorMode == 'single' ? activeColor : (normalizedVu > 0.8 ? Colors.red : Colors.greenAccent);
          opacity = normalizedVu * 1.5;
          if (opacity > 1.0) opacity = 1.0;
          if (opacity < 0.2) opacity = 0.2;
          blurRadius = opacity * 15.0;
          scale = 1.0 + (opacity * 0.3);
          break;
        case 'digital wave':
          double wavePos = (pos * 10 - progress * 5) % 1.0;
          ledColor = getVuColor(pos);
          opacity = isAtOrBelow ? (wavePos > 0.5 ? 1.0 : 0.5) : 0.1;
          blurRadius = isAtOrBelow ? 12.0 : 1.0;
          break;
        case 'stereo pulse': // alternate odd/even pulsing on bass
          bool odd = index % 2 != 0;
          ledColor = getVuColor(pos);
          if (odd) {
            opacity = isAtOrBelow ? 1.0 : 0.1;
            blurRadius = isAtOrBelow ? 20.0 : 1.0;
          } else {
            opacity = isAtOrBelow ? 0.5 : 0.1;
            blurRadius = isAtOrBelow ? 4.0 : 1.0;
          }
          break;
        case 'fire eq':
          ledColor = pos < 0.6 ? Colors.orange : (pos < 0.85 ? Colors.deepOrange : Colors.redAccent);
          double flicker = Random(index ^ DateTime.now().millisecondsSinceEpoch).nextDouble();
          opacity = isAtOrBelow ? (0.8 + 0.2 * flicker) : 0.1;
          blurRadius = isAtOrBelow ? 20.0 * flicker : 1.0;
          break;
        case 'peak hold':
          bool holdPeak = pos >= (normalizedVu - 0.05) && pos <= (normalizedVu + 0.05) && normalizedVu > 0;
          ledColor = holdPeak ? Colors.white : getVuColor(pos);
          opacity = holdPeak ? 1.0 : (isAtOrBelow ? 0.6 : 0.1);
          blurRadius = holdPeak ? 25.0 : (isAtOrBelow ? 10.0 : 1.0);
          scale = holdPeak ? 1.25 : 1.0;
          break;
        case 'sound ripple':
          double rip = (sin(pos * 20 - progress * 15) + 1) / 2;
          ledColor = getVuColor(pos);
          opacity = isAtOrBelow ? 0.3 + (0.7 * rip) : 0.1;
          blurRadius = isAtOrBelow ? rip * 15.0 : 1.0;
          break;
        case 'bass bounce':
          double bounce = (sin(normalizedVu * pi) + 1) / 2;
          ledColor = getVuColor(bounce);
          opacity = 1.0;
          blurRadius = 15.0;
          scale = 1.0 + (bounce * 0.6);
          if (pos > bounce) {
            opacity = 0.15; scale = 1.0; blurRadius = 1.0;
          }
          break;
        case 'symmetric fill':
          double centerAbs = (pos - 0.5).abs();
          bool symFilled = centerAbs <= (normalizedVu / 2);
          ledColor = getVuColor(centerAbs * 2);
          opacity = symFilled ? 1.0 : 0.1;
          blurRadius = symFilled ? 15.0 : 1.0;
          break;
        case 'color shift eq':
          ledColor = HSVColor.fromAHSV(1.0, (progress * 360 + pos * 180) % 360, 1.0, 1.0).toColor();
          if (colorMode == 'single') ledColor = activeColor;
          opacity = isAtOrBelow ? 1.0 : 0.1;
          blurRadius = isAtOrBelow ? 15.0 : 1.0;
          break;
        case 'flash pulse':
          bool hi = normalizedVu > 0.7;
          ledColor = hi ? Colors.white : getVuColor(pos);
          opacity = hi ? 1.0 : (isAtOrBelow ? 0.7 : 0.1);
          blurRadius = hi ? 35.0 : (isAtOrBelow ? 12.0 : 1.0);
          scale = hi ? 1.3 : 1.0;
          break;
        default:
          ledColor = getVuColor(pos);
          opacity = isAtOrBelow ? 1.0 : 0.1;
          blurRadius = isAtOrBelow ? 12.0 : 1.0;
          break;
      }
    }

    return SimulatedLED(color: ledColor, opacity: opacity, scale: scale, blurRadius: blurRadius);
  }
}
