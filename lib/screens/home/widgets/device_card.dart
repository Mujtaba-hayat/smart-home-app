import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DeviceCard extends StatelessWidget {
  final String deviceName;
  final IconData icon;
  final bool isOn;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.icon,
    required this.isOn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Align(
            alignment: Alignment.topRight,

            child: Switch(
                value: isOn,
                onChanged: (_){},

            ),
          ),

          const Spacer(),

          Icon(
            icon,
            size: 42,
            color: isOn
              ?AppColors.accent
                :AppColors.textSecondary,
          ),

          const SizedBox(height: 15,),

          Text(
            deviceName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5,),

          Text(
            isOn ? "ON" : "OFF",
            style: TextStyle(
              color: isOn
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
