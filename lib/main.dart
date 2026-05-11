import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/main_navigation_screen.dart';

void main(){
  runApp(const SmartHomeApp());

}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp (
      debugShowCheckedModeBanner: false,

      title: 'Smart Home',

      theme: AppTheme.darkTheme,

      home: const MainNavigationScreen(),
    );
  }
}
