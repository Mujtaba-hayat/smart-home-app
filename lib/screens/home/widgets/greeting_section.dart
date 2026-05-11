import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: const [
            Text(
              "Hello Mujtaba 👋",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,

              ),
            ),

            SizedBox(height: 5),

            Text(
              "Welcome Back ",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
      ],

    );
  }
}
