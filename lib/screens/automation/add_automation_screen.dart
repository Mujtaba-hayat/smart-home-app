import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/automation_model.dart';
import '../../providers/device_provider.dart';
import '../../services/automation_service.dart';

class AddAutomationScreen extends StatefulWidget {
  final AutomationModel? automation;

  const AddAutomationScreen({
    super.key,
    this.automation,
  });

  @override
  State<AddAutomationScreen> createState() => _AddAutomationScreenState();
}

class _AddAutomationScreenState extends State<AddAutomationScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedDevice;
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _turnOn = true;
  int _pumpDuration = 5;

  final List<String> _days = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  final List<String> _selectedDays = [];

  final AutomationService _automationService = AutomationService();

  @override
  void initState() {
    super.initState();

    if (widget.automation != null) {
      _selectedDevice = widget.automation!.deviceName;
      _turnOn = widget.automation!.turnOn;
      _selectedDays.addAll(widget.automation!.repeatDays);

      if (widget.automation!.durationMinutes != null) {
        _pumpDuration = widget.automation!.durationMinutes!;
      }
    }
  }

  Future<void> _saveAutomation(
      DeviceProvider deviceProvider,
      ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedDevice = deviceProvider.devices.firstWhere(
          (device) => device.name == _selectedDevice,
    );

    final automation = AutomationModel(
      id: widget.automation?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      deviceId: selectedDevice.id,
      deviceName: selectedDevice.name,
      time: _selectedTime.format(context),
      turnOn: _turnOn,
      enabled: widget.automation?.enabled ?? true,
      repeatDays: List.from(_selectedDays),
      durationMinutes:
      selectedDevice.relay == "R8"
          ? _pumpDuration
          : null,
    );

    final response = widget.automation == null
        ? await _automationService.createAutomation(automation)
        : await _automationService.updateAutomation(automation);

    if (!mounted) return;

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.automation == null
              ? "Add Automation"
              : "Edit Automation",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.automation == null
                      ? "Create Automation"
                      : "Edit Automation",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  initialValue: _selectedDevice,
                  decoration: const InputDecoration(
                    labelText: "Select Device",
                    border: OutlineInputBorder(),
                  ),
                  items: deviceProvider.devices
                      .map(
                        (device) => DropdownMenuItem<String>(
                      value: device.name,
                      child: Text(device.name),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDevice = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a device";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Automation Time"),
                  subtitle: Text(
                    _selectedTime.format(context),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );

                    if (!mounted) return;

                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Turn Device ON"),
                  subtitle: Text(
                    _turnOn
                        ? "Device will turn ON"
                        : "Device will turn OFF",
                  ),
                  value: _turnOn,
                  onChanged: (value) {
                    setState(() {
                      _turnOn = value;
                    });
                  },
                ),

                if ((_selectedDevice ?? "").trim() == "Water Pump") ...[
                  DropdownButtonFormField<int>(
                    initialValue: _pumpDuration,
                    decoration: const InputDecoration(
                      labelText: "Pump Duration",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 5,
                        child: Text("5 Minutes"),
                      ),
                      DropdownMenuItem(
                        value: 10,
                        child: Text("10 Minutes"),
                      ),
                      DropdownMenuItem(
                        value: 15,
                        child: Text("15 Minutes"),
                      ),
                      DropdownMenuItem(
                        value: 20,
                        child: Text("20 Minutes"),
                      ),
                      DropdownMenuItem(
                        value: 30,
                        child: Text("30 Minutes"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _pumpDuration = value;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 20),

                const Text(
                  "Repeat Days",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _days.map((day) {
                    final selected =
                    _selectedDays.contains(day);

                    return FilterChip(
                      label: Text(day),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _saveAutomation(deviceProvider);
                    },
                    child: Text(
                      widget.automation == null
                          ? "Save Automation"
                          : "Update Automation",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}