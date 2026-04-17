import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/hardware_state.dart';
import 'core/theme/app_theme.dart';
import 'views/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp() goes here when ready.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HardwareState()),
      ],
      child: const PixelControllerApp(),
    ),
  );
}

class PixelControllerApp extends StatelessWidget {
  const PixelControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Controller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const DashboardScreen(),
    );
  }
}
