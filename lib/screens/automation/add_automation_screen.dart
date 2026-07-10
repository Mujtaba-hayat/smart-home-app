import 'package:flutter/material.dart';
import '../../providers/device_provider.dart';
import 'package:provider/provider.dart';

class AddAutomationScreen extends StatefulWidget {
  const AddAutomationScreen({
    super.key});

  @override
  State<AddAutomationScreen> createState() =>
      _AddAutomationScreenState();
}

class _AddAutomationScreenState
    extends State<AddAutomationScreen> {

  final _formKey = GlobalKey<FormState>();

  String? _selectedDevice;

  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _turnOn = true;

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


  @override
  Widget build(BuildContext context) {

    final deviceProvider = Provider.of<DeviceProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Automation"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const Text(
                "Create Automation",
                style: TextStyle(
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
                    (device) => DropdownMenuItem(
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

                  if (pickedTime != null){
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
                  ?"Device will turn ON"
                      :"Device will turn OFF",
                ),

                value: _turnOn,

                onChanged: (value) {
                  setState(() {
                    _turnOn = value;
                  });
                },
              ),

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

                children: _days.map((day){

                  final selected = _selectedDays.contains(day);

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

                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Automation Saved!"),
                      ),
                    );
                  },

                  child: const Text("Save Automation"),
                ),
              ),
            ],

          ),
        ),
      ),
    );
  }
}