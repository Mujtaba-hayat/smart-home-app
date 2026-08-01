import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:smart_home/screens/automation/add_automation_screen.dart';
import '../../providers/automation_provider.dart';
import 'widgets/automation_card.dart';
import '../../services/automation_service.dart';
class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}
class _AutomationScreenState extends State<AutomationScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask((){
      Provider.of<AutomationProvider>(
        context,
        listen:false,
      ).loadAutomations();
    });
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AutomationProvider>(context);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Automation"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await Navigator.push(
            context,
          MaterialPageRoute(
            builder: (_) => const AddAutomationScreen(),
          ),
          );
          await provider.loadAutomations();
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
            automation: automation,

            onToggle: (value) async {

              final automationService = AutomationService();

              final response =
              await automationService.toggleAutomation(automation.id);

              if (response.statusCode == 200) {

                await provider.loadAutomations();

              } else {

                if (context.mounted) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to update automation"),
                    ),
                  );

                }

              }

            },

            onEdit: () async {

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddAutomationScreen(
                    automation: automation,
                  ),
                ),
              );

              await provider.loadAutomations();

            },
            onDelete: (){

              showDialog(

                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete Automation"),

                    content: Text(
                      'Are you sure you want to delete "${automation.deviceName}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {

                          final automationService = AutomationService();
                          final response =
                          await automationService
                              .deleteAutomation(automation.id);

                          if (response.statusCode == 200) {

                            await provider.loadAutomations();

                            if (context.mounted) {
                              Navigator.pop(context);
                            }

                          } else {

                            if (context.mounted) {

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to delete automation"),
                                ),
                              );

                            }

                          }

                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                }
              );
            },
          );
        },
      ),
    );
  }
}
