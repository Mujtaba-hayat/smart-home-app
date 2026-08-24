import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/automation_provider.dart';
import '../../services/automation_service.dart';
import 'add_automation_screen.dart';
import 'widgets/automation_card.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  final AutomationService _automationService = AutomationService();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      Provider.of<AutomationProvider>(
        context,
        listen: false,
      ).loadAutomations();
    });
  }

  Future<void> _reloadAutomations() async {
    final provider = Provider.of<AutomationProvider>(
      context,
      listen: false,
    );

    await provider.loadAutomations();
  }

  Future<bool> _toggleAutomation(
      AutomationProvider provider,
      String automationId,
      ) async {
    final response =
    await _automationService.toggleAutomation(automationId);

    if (response.statusCode == 200) {
      await provider.loadAutomations();
      return true;
    }

    return false;
  }

  Future<bool> _deleteAutomation(
      AutomationProvider provider,
      String automationId,
      ) async {
    final response =
    await _automationService.deleteAutomation(automationId);

    if (response.statusCode == 200) {
      await provider.loadAutomations();
      return true;
    }

    return false;
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _performDelete(
      AutomationProvider provider,
      String automationId,
      ) async {
    final success = await _deleteAutomation(
      provider,
      automationId,
    );

    if (!mounted) return;

    if (!success) {
      _showError(
        "Failed to delete automation",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AutomationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Automation"),
      ),

      // ADD AUTOMATION
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddAutomationScreen(),
            ),
          );

          if (!mounted) return;

          await _reloadAutomations();
        },
        child: const Icon(Icons.add),
      ),

      body: provider.automations.isEmpty
          ? const Center(
        child: Text(
          "No automations yet",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.automations.length,
        itemBuilder: (context, index) {
          final automation =
          provider.automations[index];

          return AutomationCard(
            automation: automation,

            // TOGGLE
            onToggle: (_) async {
              final success =
              await _toggleAutomation(
                provider,
                automation.id,
              );

              if (!mounted) return;

              if (!success) {
                _showError(
                  "Failed to update automation",
                );
              }
            },

            // EDIT
            onEdit: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddAutomationScreen(
                    automation: automation,
                  ),
                ),
              );

              if (!mounted) return;

              await _reloadAutomations();
            },

            // DELETE
            onDelete: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text(
                      "Delete Automation",
                    ),

                    content: Text(
                      'Are you sure you want to delete '
                          '"${automation.deviceName}"?',
                    ),

                    actions: [
                      // CANCEL
                      TextButton(
                        onPressed: () {
                          Navigator.of(
                            dialogContext,
                          ).pop();
                        },
                        child: const Text("Cancel"),
                      ),

                      // DELETE
                      ElevatedButton(
                        onPressed: () {
                          // Close dialog first.
                          Navigator.of(
                            dialogContext,
                          ).pop();

                          // Perform delete separately.
                          _performDelete(
                            provider,
                            automation.id,
                          );
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}