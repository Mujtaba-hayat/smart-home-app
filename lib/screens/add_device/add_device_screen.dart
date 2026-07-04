import 'package:flutter/material.dart';

import '../../data/room_data.dart';
import '../../models/device_type.dart';

import '../../core/widgets/custom_dropdown.dart';
import '../../core/widgets/custom_text_field.dart';

import 'package:provider/provider.dart';

import '../../providers/device_provider.dart';
import '../../models/device_model.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  String? _selectedRoom;

  DeviceType? _selectedType;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

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

                      final provider =
                          Provider.of<DeviceProvider>(
                            context,
                            listen: false,
                          );
                      final id =
                          "R${provider.devices.length + 1}";
                      final device = DeviceModel(
                          id: id,
                          name: _nameController.text.trim(),
                          room: _selectedRoom!,
                          type: _selectedType!,
                          iconName: _selectedType!.name,
                          isOn: false,
                      );
                      provider.addDevice(device);
                      Navigator.pop(context);
                    }

                  },

                  child: const Text(

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