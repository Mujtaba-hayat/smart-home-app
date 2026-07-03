import'device_type.dart';

class DeviceModel {
  final String id;

  String name;

  String room;

  DeviceType type;

  String iconName;

  bool isOn;

  DeviceModel({
   required this.id,
    required this.name,
    required this.room,
    required this.type,
    required this.iconName,
    required this.isOn,
});
}