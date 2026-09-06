class SensorModel {
  // ====================================================
  // SENSOR VALUES
  // ====================================================

  final double? temperature;

  final double? humidity;

  final String? doorStatus;

  // ====================================================
  // SENSOR TIMESTAMP
  // ====================================================

  final DateTime? sensorLastUpdated;

  // ====================================================
  // SMART HOME / ESP32
  // ====================================================

  final String? smartHomeId;

  final String? smartHomeName;

  final String? esp32Id;

  final String? status;

  final DateTime? lastSeen;

  // ====================================================
  // CONSTRUCTOR
  // ====================================================

  SensorModel({
    this.temperature,
    this.humidity,
    this.doorStatus,
    this.sensorLastUpdated,
    this.smartHomeId,
    this.smartHomeName,
    this.esp32Id,
    this.status,
    this.lastSeen,
  });

  // ====================================================
  // FROM JSON
  // ====================================================

  factory SensorModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final sensors =
    Map<String, dynamic>.from(
      json["sensors"] ?? {},
    );

    final smartHome =
    Map<String, dynamic>.from(
      json["smartHome"] ?? {},
    );

    return SensorModel(
      temperature:
      _toDouble(
        sensors["temperature"],
      ),

      humidity:
      _toDouble(
        sensors["humidity"],
      ),

      doorStatus:
      sensors["doorStatus"]?.toString(),

      sensorLastUpdated:
      _toDateTime(
        sensors["sensorLastUpdated"],
      ),

      smartHomeId:
      smartHome["id"]?.toString(),

      smartHomeName:
      smartHome["name"]?.toString(),

      esp32Id:
      smartHome["esp32Id"]?.toString(),

      status:
      smartHome["status"]?.toString(),

      lastSeen:
      _toDateTime(
        smartHome["lastSeen"],
      ),
    );
  }

  // ====================================================
  // DOUBLE CONVERTER
  // ====================================================

  static double? _toDouble(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  // ====================================================
  // DATE CONVERTER
  // ====================================================

  static DateTime? _toDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  // ====================================================
  // ESP32 CONNECTION
  // ====================================================

  bool get isConnected {
    return status?.toLowerCase() ==
        "connected";
  }

  // ====================================================
  // DOOR STATUS
  // ====================================================

  bool get isDoorOpen {
    return doorStatus?.toLowerCase() ==
        "open";
  }
}