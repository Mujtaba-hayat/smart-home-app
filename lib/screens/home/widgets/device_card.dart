import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DeviceCard extends StatelessWidget {
  final String deviceName;
  final IconData icon;
  final bool isOn;
  final bool isFavorite;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.icon,
    required this.isOn,
    required this.isFavorite,
    required this.onToggle,
    required this.onTap,


  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: BorderRadius.circular(24),

        onTap: onTap,
        child: Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(22),
      ),

      child: Stack(
        children: [
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Align(
              alignment: Alignment.topRight,
              child: Switch(
                value: isOn,
                onChanged: (_) => onToggle(),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Icon(
                icon,
                size: 42,
                color: isOn
                    ? AppColors.accent
                    : AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              deviceName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              isOn ? "ON" : "OFF",
              style: TextStyle(
                fontSize: 14,
                color: isOn
                    ? AppColors.accent
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),

          if (isFavorite)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.star,
                color: Colors.amber,
                size: 24,
              ),
            )
          ]
      ),

    ),);
  }
}