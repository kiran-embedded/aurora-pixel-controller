import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/engine/display_engine.dart';
import 'haptic_service.dart';

class HardwareState extends ChangeNotifier {
  // Core State
  bool _isPowered = true;
  int _brightness = 100;
  String _mode = 'pixel'; // 'pixel' or 'vu'
  String _activeAnimation = 'Rainbow Flow';
  String _colorMode = 'single';
  Color _activeColor = const Color(0xFF00E5FF);
  int _numLeds = 14;

  // Global Configs (UDE & Theme)
  DisplaySize _displaySize = DisplaySize.medium;
  FontSize _fontSize = FontSize.medium;
  NeonTheme _activeTheme = NeonTheme.cyberCyan;
  HapticGrade _hapticGrade = HapticGrade.midrange;

  // Infrastructure
  late final DatabaseReference _stateRef;
  StreamSubscription<DatabaseEvent>? _statusSubscription;
  bool _isFirebaseReady = false;
  bool _isSyncingFromRemote = false; 
  bool _isConnected = false;

  // Getters
  int get numLeds => _numLeds;
  bool get isPowered => _isPowered;
  int get brightness => _brightness;
  String get mode => _mode;
  String get activeAnimation => _activeAnimation;
  String get colorMode => _colorMode;
  Color get activeColor => _activeColor;
  DisplaySize get displaySize => _displaySize;
  FontSize get fontSize => _fontSize;
  NeonTheme get activeTheme => _activeTheme;
  HapticGrade get hapticGrade => _hapticGrade;
  bool get isConnected => _isConnected;
  bool get isFirebaseReady => _isFirebaseReady;

  HardwareState() {
    _loadPreferences();
  }

  // Setters
  void setDisplaySize(DisplaySize size) {
    _displaySize = size;
    _savePreference('displaySize', size.index);
    notifyListeners();
  }

  void setFontSize(FontSize size) {
    _fontSize = size;
    _savePreference('fontSize', size.index);
    notifyListeners();
  }

  void setNeonTheme(NeonTheme theme) {
    _activeTheme = theme;
    _savePreference('neonTheme', theme.index);
    notifyListeners();
  }

  void setNumLeds(int val) {
    _numLeds = val;
    if (_isFirebaseReady) {
      _stateRef.child('matrix/count').set(val);
      _syncMetadata();
    }
    notifyListeners();
  }

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
    _colorMode = 'single';
    _syncToHardware();
    notifyListeners();
  }

  void setActiveColorLocal(Color color) {
    _activeColor = color;
    _colorMode = 'single';
    notifyListeners();
  }

  void setHapticGrade(HapticGrade grade) {
    _hapticGrade = grade;
    HapticService.setGrade(grade);
    HapticService.trigger(HapticType.success);
    notifyListeners();
  }

  // Persistence Helpers
  Future<void> _savePreference(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _displaySize = DisplaySize.values[prefs.getInt('displaySize') ?? 1];
    _fontSize = FontSize.values[prefs.getInt('fontSize') ?? 1];
    _activeTheme = NeonTheme.values[prefs.getInt('neonTheme') ?? 0];
    notifyListeners();
  }

  // Firebase Logic
  void initFirebase() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      _isFirebaseReady = true;
      _stateRef = FirebaseDatabase.instance.ref('devices/esp32_pixel_controller/commands');
      
      FirebaseDatabase.instance.ref('.info/connected').onValue.listen((event) {
        _isConnected = event.snapshot.value == true;
        notifyListeners();
      });

      _statusSubscription = FirebaseDatabase.instance.ref('devices/esp32_pixel_controller/status').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data == null || data is! Map) return;

        final map = Map<String, dynamic>.from(data);
        _isSyncingFromRemote = true;

        _isPowered = map['isPowered'] ?? _isPowered;
        _brightness = map['brightness'] ?? _brightness;
        _mode = map['mode'] ?? _mode;
        _activeAnimation = map['activeAnimation'] ?? _activeAnimation;
        _colorMode = map['colorMode'] ?? _colorMode;

        final hexStr = map['activeColor'] as String?;
        if (hexStr != null && hexStr.startsWith('#') && hexStr.length == 7) {
          _activeColor = Color(int.parse('FF${hexStr.substring(1)}', radix: 16));
        }

        _isSyncingFromRemote = false;
        notifyListeners();
      });

      _syncToHardware();
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
  }

  void _syncToHardware() {
    if (_isSyncingFromRemote || !_isFirebaseReady) return;

    final config = {
      'isPowered': _isPowered,
      'brightness': _brightness,
      'mode': _mode,
      'activeAnimation': _activeAnimation,
      'colorMode': _colorMode,
      'activeColor': '#${_activeColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
    };

    _stateRef.update(config).catchError((e) => debugPrint('Sync error: $e'));
  }

  void _syncMetadata() {
    if (_isFirebaseReady) {
      FirebaseDatabase.instance.ref('devices/esp32_pixel_controller/metadata').update({
        'numLeds': _numLeds,
        'updateTimestamp': ServerValue.timestamp,
      });
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}
