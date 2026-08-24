import 'package:flutter/material.dart';
import 'package:smart_home/models/automation_model.dart';

class AutomationCard extends StatelessWidget {
  final AutomationModel automation;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AutomationCard({
    super.key,
    required this.automation,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: ListTile(
        leading: const Icon(
          Icons.schedule,
          size: 32,
        ),
        title: Text(
          automation.deviceName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),

            Text("Time: ${automation.time}"),

            Text(
              automation.turnOn
                  ? "Action: Turn ON"
                  : "Action: Turn OFF",
            ),

            Text(
              "Repeat: ${automation.repeatDays.join(", ")}",
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
            Switch(
              value: automation.enabled,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}