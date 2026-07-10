import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:smart_home/screens/automation/add_automation_screen.dart';
import '../../providers/automation_provider.dart';
import 'widgets/automation_card.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AutomationProvider>(context);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Automation"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
          MaterialPageRoute(
            builder: (_) => const AddAutomationScreen(),
          ),
          );
        },
      ),

      body: provider.automations.isEmpty
        ? const Center(
        child: Text(
          "No automations yet",
          style: TextStyle(fontSize: 18),
        ),
      )
      :ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.automations.length,
        itemBuilder: (context, index) {
          final automation = provider.automations[index];
          return AutomationCard(
            deviceName: automation.deviceName,
            time: automation.time,
            turnOn: automation.turnOn,
            repeatDays: automation.repeatDays.join(", "),
            enabled: automation.enabled,
            onToggle: (value) {
              //We'll implement this later.
            },
          );
        },
      ),
    );
  }
}
