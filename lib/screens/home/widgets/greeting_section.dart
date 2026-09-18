import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../notifications/notifications_screen.dart';

class GreetingSection extends StatelessWidget {
const GreetingSection({super.key});

@override
Widget build(BuildContext context) {
final authProvider =
Provider.of<AuthProvider>(context);

final user = authProvider.user;

final fullName =
user?["fullName"]?.toString().trim() ?? "";

final userName =
fullName.isNotEmpty ? fullName : "User";

return Row(
crossAxisAlignment:
CrossAxisAlignment.center,

children: [
// ====================================================
// MENU BUTTON
// ====================================================

Builder(
builder: (context) {
return IconButton(
onPressed: () {
Scaffold.of(context).openDrawer();
},

icon: const Icon(
Icons.menu_rounded,
size: 28,
),

tooltip: "Menu",
);
},
),

const SizedBox(
width: 4,
),

// ====================================================
// GREETING
// ====================================================

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [
Text(
"Hello $userName 👋",

maxLines: 1,

overflow:
TextOverflow.ellipsis,

style: const TextStyle(
fontSize: 23,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 5,
),

const Text(
"Welcome Back",

style: TextStyle(
color:
AppColors.textSecondary,
fontSize: 15,
),
),
],
),
),

// ====================================================
// NOTIFICATION BUTTON
// ====================================================

GestureDetector(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const NotificationsScreen(),
),
);
},

child: Container(
width: 52,
height: 52,

decoration: BoxDecoration(
color: AppColors.primary,
shape: BoxShape.circle,
),

child: const Icon(
Icons.notifications_rounded,
color: Colors.white,
size: 27,
),
),
),
],
);
}
}
