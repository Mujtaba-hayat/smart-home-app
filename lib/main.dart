import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';

import 'providers/device_provider.dart';
import 'providers/automation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/smart_home_provider.dart';
import 'providers/member_provider.dart';
import 'providers/sensor_provider.dart';

import 'screens/splash/splash_screen.dart';
import 'providers/notification_provider.dart';
void main() {
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        // =========================================
        // DEVICE PROVIDER
        // =========================================

        ChangeNotifierProvider(
          create: (_) => DeviceProvider(),
        ),

        // =========================================
        // AUTOMATION PROVIDER
        // =========================================

        ChangeNotifierProvider(
          create: (_) => AutomationProvider(),
        ),

        // =========================================
        // AUTH PROVIDER
        // =========================================

        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        // =========================================
        // SMART HOME PROVIDER
        // =========================================

        ChangeNotifierProvider(
          create: (_) => SmartHomeProvider(),
        ),

        // =========================================
        // MEMBER PROVIDER
        // =========================================

        ChangeNotifierProvider(
          create: (_) => MemberProvider(),
        ),

        // =========================================
        // SENSOR PROVIDER
        // =========================================

        ChangeNotifierProvider(
          create: (_) => SensorProvider(),
        ),

        // =========================================
// NOTIFICATION PROVIDER
// =========================================

        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'Smart Home',

        theme: AppTheme.darkTheme,

        home: const SplashScreen(),
      ),
    );
  }
}