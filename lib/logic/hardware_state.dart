import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// Note: We will integrate firebase_database here later when credentials are set up.

class HardwareState extends ChangeNotifier {
  bool _isPowered = true;
  int _brightness = 100;
  String _mode = 'pixel'; // 'pixel' or 'vu'
  String _activeAnimation = 'Meteor Shower';
  String _colorMode = 'multi'; // 'multi' or 'single'
  Color _activeColor = const Color(0xFF00F0FF); // Hex #00F0FF

  // Getters
  bool get isPowered => _isPowered;
  int get brightness => _brightness;
  String get mode => _mode;
  String get activeAnimation => _activeAnimation;
  String get colorMode => _colorMode;
  Color get activeColor => _activeColor;

  // Setters with notification
  void togglePower() {
    _isPowered = !_isPowered;
    _syncToHardware();
    notifyListeners();
  }

  void setPower(bool val) {
    _isPowered = val;
    _syncToHardware();
    notifyListeners();
  }

  void cycleBrightness() {
    if (_brightness == 100) {
      _brightness = 50;
    } else if (_brightness == 50) {
      _brightness = 20;
    } else {
      _brightness = 100;
    }
    _syncToHardware();
    notifyListeners();
  }

  void setBrightness(int val) {
    _brightness = val.clamp(0, 100);
    _syncToHardware();
    notifyListeners();
  }

  void setMode(String newMode) {
    _mode = newMode;
    _syncToHardware();
    notifyListeners();
  }

  void setActiveAnimation(String newAnimation) {
    _activeAnimation = newAnimation;
    _syncToHardware();
    notifyListeners();
  }

  void setColorMode(String newColorMode) {
    _colorMode = newColorMode;
    _syncToHardware();
    notifyListeners();
  }

  void setActiveColor(Color color) {
    _activeColor = color;
    _colorMode = 'single'; // Usually sets to custom color
    _syncToHardware();
    notifyListeners();
  }
  
  void applyScene(String name) {
    if (!_isPowered) _isPowered = true;
    switch(name) {
      case 'Deep Space':
        _mode = 'pixel';
        _activeAnimation = 'Aurora Borealis';
        _colorMode = 'multi';
        break;
      case 'Cyberpunk':
        _mode = 'pixel';
        _activeAnimation = 'Cyber Sweep';
        _colorMode = 'single';
        _activeColor = const Color(0xFFFF2D55);
        break;
      case 'Studio Mix':
        _mode = 'vu';
        _activeAnimation = 'Gravity Drop';
        _colorMode = 'multi';
        break;
      case 'Sunrise':
        _mode = 'pixel';
        _activeAnimation = 'Solid Custom';
        _colorMode = 'single';
        _activeColor = const Color(0xFFFF9500);
        break;
    }
    _syncToHardware();
    notifyListeners();
  }

  void _syncToHardware() {
    // TODO: Write to Firebase Realtime Database
    /*
    final config = {
      'isPowered': _isPowered,
      'brightness': _brightness,
      'mode': _mode,
      'activeAnimation': _activeAnimation,
      'colorMode': _colorMode,
      'activeColor': '#${_activeColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
    };
    print("Syncing to hardware: $config");
    */
  }
}
