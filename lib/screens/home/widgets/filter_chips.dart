import 'package:flutter/material.dart';

import '../../../models/device_type.dart';

class FilterChips extends StatelessWidget {
  final DeviceType? selected;
  final ValueChanged<DeviceType?> onSelected;
  final bool showFavoritesOnly;
  final VoidCallback onFavoriteTap;

  const FilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.showFavoritesOnly,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text("All"),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),

          const SizedBox(width: 10),

          ChoiceChip(
            label: const Text("Lights"),
            selected: selected == DeviceType.light,
            onSelected: (_) => onSelected(DeviceType.light),
          ),

          const SizedBox(width: 10),

          ChoiceChip(
            label: const Text("Fans"),
            selected: selected == DeviceType.fan,
            onSelected: (_) => onSelected(DeviceType.fan),
          ),

          const SizedBox(width: 10),

          ChoiceChip(
            label: const Text("Sockets"),
            selected: selected == DeviceType.socket,
            onSelected: (_) => onSelected(DeviceType.socket),
          ),

          const SizedBox(width: 10),

          ChoiceChip(
            label: const Text("Appliances"),
            selected: selected == DeviceType.appliance,
            onSelected: (_) => onSelected(DeviceType.appliance),
          ),

          const SizedBox(width: 10),

          ChoiceChip(
            label: const Text("⭐ Favorites"),
            selected: showFavoritesOnly,
            onSelected: (_) {
              onFavoriteTap();
            },
          ),
        ],
      ),
    );
  }
}