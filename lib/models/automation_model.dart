class AutomationModel {
  final String id;
  final String deviceId;
  final String deviceName;
  final String time;
  final bool turnOn;
  final bool enabled;

  final List<String> repeatDays;

  // NEW
  final int? durationMinutes;

  const AutomationModel({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.time,
    required this.turnOn,
    required this.enabled,
    required this.repeatDays,

    this.durationMinutes,
  });

  factory AutomationModel.fromJson(Map<String, dynamic> json) {
    return AutomationModel(
      id: json["id"],
      deviceId: json["deviceId"],
      deviceName: json["deviceName"],
      time: json["time"],
      turnOn: json["turnOn"],
      enabled: json["enabled"],
      repeatDays: List<String>.from(json["repeatDays"]),

      durationMinutes: json["durationMinutes"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "deviceId": deviceId,
      "deviceName": deviceName,
      "time": time,
      "turnOn": turnOn,
      "enabled": enabled,
      "repeatDays": repeatDays,

      "durationMinutes": durationMinutes,
    };
  }
}