import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'logic/hardware_state.dart';
import 'core/theme/app_theme.dart';
import 'views/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge transparent system bars
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  // Initialize Firebase with project credentials
  bool firebaseOk = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseOk = true;
  } catch (e) {
    debugPrint('⚠️  Firebase init failed: $e');
  }

  final hardwareState = HardwareState();
  if (firebaseOk) {
    hardwareState.initFirebase();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: hardwareState),
      ],
      child: const PixelControllerApp(),
    ),
  );
}

class PixelControllerApp extends StatelessWidget {
  const PixelControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<HardwareState>().activeTheme;
    
    return MaterialApp(
      title: 'Pixel Controller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData(theme),
      home: const DashboardScreen(),
    );
  }
}
