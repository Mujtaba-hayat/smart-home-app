class AutomationModel {

  final String id;
  final String deviceId;
  final String deviceName;
  final String time;
  final bool turnOn;
  final bool enabled;

  final List<String> repeatDays;

  const AutomationModel({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.time,
    required this.turnOn,
    required this.enabled,
    required this.repeatDays,
});

}