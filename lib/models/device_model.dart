import 'device_type.dart';

class DeviceModel {
  // ====================================================
  // BACKEND IDs
  // ====================================================

  final String id; // MongoDB _id

  final String deviceId; // Backend deviceId

  // ====================================================
  // RELAY
  // ====================================================

  final String relay; // R1-R7

  // ====================================================
  // DEVICE INFORMATION
  // ====================================================

  String name;

  String room;

  DeviceType type;

  String iconName;

  // ====================================================
  // DEVICE STATE
  // ====================================================

  bool isOn;

  bool isFavorite;

  double power;

  // ====================================================
  // CONSTRUCTOR
  // ====================================================

  DeviceModel({
    required this.id,
    required this.deviceId,
    required this.relay,
    required this.name,
    required this.room,
    required this.type,
    required this.iconName,
    required this.isOn,
    this.isFavorite = false,
    required this.power,
  });

  // ====================================================
  // CONVERT STRING TO DEVICE TYPE
  // ====================================================

  static DeviceType deviceTypeFromString(
      String? value,
      ) {
    switch (value?.toLowerCase()) {
      case "light":
        return DeviceType.light;

      case "fan":
        return DeviceType.fan;

      case "socket":
        return DeviceType.socket;

      case "appliance":
        return DeviceType.appliance;

      case "alarm":
        return DeviceType.alarm;

      case "pump":
        return DeviceType.pump;

      case "other":
        return DeviceType.other;

      default:
        return DeviceType.other;
    }
  }

  // ====================================================
  // CONVERT DEVICE TYPE TO STRING
  // ====================================================

  static String deviceTypeToString(
      DeviceType type,
      ) {
    switch (type) {
      case DeviceType.light:
        return "light";

      case DeviceType.fan:
        return "fan";

      case DeviceType.socket:
        return "socket";

      case DeviceType.appliance:
        return "appliance";

      case DeviceType.alarm:
        return "alarm";

      case DeviceType.pump:
        return "pump";

      case DeviceType.other:
        return "other";
    }
  }
}