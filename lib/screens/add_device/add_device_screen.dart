import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/custom_dropdown.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/room_data.dart';
import '../../models/device_model.dart';
import '../../models/device_type.dart';
import '../../providers/device_provider.dart';

class AddDeviceScreen extends StatefulWidget {
  final DeviceModel? device;

  const AddDeviceScreen({
    super.key,
    this.device,
  });

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  String? _selectedRoom;
  DeviceType? _selectedType;

  @override
  void initState() {
    super.initState();

    if (widget.device != null) {
      _nameController.text = widget.device!.name;
      _selectedRoom = widget.device!.room;
      _selectedType = widget.device!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String getIconName() {
    switch (_selectedType!) {
      case DeviceType.light:
        return "lightbulb";
      case DeviceType.fan:
        return "fan";
      case DeviceType.alarm:
        return "alarm";
      case DeviceType.pump:
        return "pump";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.device == null ? "Add Device" : "Edit Device",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                label: "Device Name",
                icon: Icons.devices,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter device name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              CustomDropdown<String>(
                label: "Room",
                icon: Icons.home,
                value: _selectedRoom,
                items: roomList.map((room) {
                  return DropdownMenuItem(
                    value: room.name,
                    child: Text(room.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoom = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select a room";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              CustomDropdown<DeviceType>(
                label: "Device Type",
                icon: Icons.category,
                value: _selectedType,
                items: DeviceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select device type";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final provider = Provider.of<DeviceProvider>(
                        context,
                        listen: false,
                      );

                      if (widget.device == null) {
                        // ADD MODE
                        int nextId = 1;

                        while (
                        provider.devices.any(
                              (device) => device.id == "R$nextId",
                        )
                        ) {
                          nextId++;
                        }

                        final id = "R$nextId";

                        final device = DeviceModel(
                          id: id,
                          name: _nameController.text.trim(),
                          room: _selectedRoom!,
                          type: _selectedType!,
                          iconName: getIconName(),
                          isOn: false,
                        );

                        provider.addDevice(device);
                      } else {
                        // EDIT MODE
                        final updatedDevice = DeviceModel(
                          id: widget.device!.id,
                          name: _nameController.text.trim(),
                          room: _selectedRoom!,
                          type: _selectedType!,
                          iconName: getIconName(),
                          isOn: widget.device!.isOn,
                        );

                        provider.updateDevice(updatedDevice);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    widget.device == null
                        ? "ADD DEVICE"
                        : "SAVE CHANGES",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}