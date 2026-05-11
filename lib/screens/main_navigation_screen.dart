import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'rooms/rooms_screen.dart';
import 'automation/automation_screen.dart';
import 'analytics/analytics_screen.dart';
import 'profile/profile_screen.dart';

import '../core/theme/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget>screens = [
    const HomeScreen(),
    const RoomsScreen(),
    const AutomationScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index){
          setState(() {
            currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        backgroundColor: AppColors.cardColor,

        selectedItemColor: AppColors.primary,

        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: "Rooms",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.auto_mode),
            label: "Automation",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Analytics",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "profile",
          ),
        ],
      ),
    );
  }
}
