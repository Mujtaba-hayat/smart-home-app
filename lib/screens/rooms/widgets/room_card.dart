import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class RoomCard extends StatelessWidget {
  final String roomName;
  final int devices;
  final int activeDevice;
  final IconData icon;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.roomName,
    required this.devices,
    required this.activeDevice,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(28),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Align(
              alignment: Alignment.topRight,

              child: Icon(
                icon,
                size: 36,
                color: AppColors.primary,
              ),
            ),

            const Spacer(),

            Text(
              roomName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "$devices Devices",
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,

                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  "$activeDevice Active",
                      style: const TextStyle(
                        color: AppColors.accent,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
