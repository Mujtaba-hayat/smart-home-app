import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/custom_dropdown.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/room_data.dart';
import '../../models/device_type.dart';
import '../../providers/device_provider.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({
    super.key,
  });

  @override
  State<AddDeviceScreen> createState() =>
      _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  String? _selectedRoom;
  DeviceType? _selectedType;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addDevice() async {
    // -----------------------------------------------
    // Validate form
    // -----------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider =
    Provider.of<DeviceProvider>(
      context,
      listen: false,
    );

    // -----------------------------------------------
    // Get values before async operation
    // -----------------------------------------------

    final name = _nameController.text.trim();
    final room = _selectedRoom!;
    final type = _selectedType!;

    // -----------------------------------------------
    // Create device
    // -----------------------------------------------

    final success = await provider.createDevice(
      name: name,
      room: room,
      type: type,
    );

    if (!mounted) {
      return;
    }

    // -----------------------------------------------
    // Success
    // -----------------------------------------------

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    // -----------------------------------------------
    // Failure
    // -----------------------------------------------

    final error =
        provider.errorMessage ??
            "Unable to add device.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    Provider.of<DeviceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Device"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              // =======================================
              // Device Name
              // =======================================

              CustomTextField(
                controller: _nameController,
                label: "Device Name",
                icon: Icons.devices,

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Please enter device name";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // =======================================
              // Room
              // =======================================

              CustomDropdown<String>(
                label: "Room",
                icon: Icons.home,
                value: _selectedRoom,

                items: roomList.map(
                      (room) {
                    return DropdownMenuItem<String>(
                      value: room.name,
                      child: Text(room.name),
                    );
                  },
                ).toList(),

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

              // =======================================
              // Device Type
              // =======================================

              CustomDropdown<DeviceType>(
                label: "Device Type",
                icon: Icons.category,
                value: _selectedType,

                items: DeviceType.values
                    .where(
                      (type) =>
                  type != DeviceType.pump,
                )
                    .map(
                      (type) {
                    return DropdownMenuItem<DeviceType>(
                      value: type,
                      child: Text(
                        type.name.toUpperCase(),
                      ),
                    );
                  },
                )
                    .toList(),

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

              // =======================================
              // Add Device Button
              // =======================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed:
                  provider.isLoading
                      ? null
                      : _addDevice,

                  child: provider.isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,

                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "ADD DEVICE",
                    style: TextStyle(
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