import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/constants.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/service_provider.dart';
import 'package:mobile_app/providers/booking_provider.dart';
import 'package:mobile_app/providers/dashboard_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool isFirebaseReady = false;
  try {
    // Attempt to initialize Firebase
    await Firebase.initializeApp();
    isFirebaseReady = true;
  } catch (e) {
    // Only log in debug/development; avoid crashing the app
    debugPrint('Firebase initialization failed: \$e. Google Sign-In will be disabled.');
  }

  runApp(MyApp(isFirebaseReady: isFirebaseReady));
}

class MyApp extends StatelessWidget {
  final bool isFirebaseReady;
  const MyApp({super.key, required this.isFirebaseReady});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(isFirebaseAvailable: isFirebaseReady)),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.getRoutes(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
