class NotificationModel {
// ====================================================
// FIELDS
// ====================================================

final String id;

final String smartHomeId;

final String type;

final String title;

final String message;

final bool isRead;

final DateTime createdAt;

// ====================================================
// CONSTRUCTOR
// ====================================================

NotificationModel({
required this.id,
required this.smartHomeId,
required this.type,
required this.title,
required this.message,
required this.isRead,
required this.createdAt,
});

// ====================================================
// FROM JSON
//
// Converts MongoDB notification response
// into Flutter NotificationModel.
// ====================================================

factory NotificationModel.fromJson(
Map<String, dynamic> json,
) {
return NotificationModel(
// MongoDB ObjectId
id: json["_id"]?.toString() ?? "",

// Smart Home ObjectId
smartHomeId:
json["smartHome"]?.toString() ?? "",

// Notification type
type:
json["type"]?.toString() ?? "system",

// Notification title
title:
json["title"]?.toString() ?? "",

// Notification message
message:
json["message"]?.toString() ?? "",

// Read / unread status
isRead:
json["isRead"] == true,

// Creation date
createdAt:
DateTime.tryParse(
json["createdAt"]?.toString() ?? "",
) ??
DateTime.now(),
);
}

// ====================================================
// COPY WITH
//
// Used when changing notification state locally.
//
// Example:
//
// notification.copyWith(
//   isRead: true,
// )
// ====================================================

NotificationModel copyWith({
bool? isRead,
}) {
return NotificationModel(
id: id,
smartHomeId: smartHomeId,
type: type,
title: title,
message: message,
isRead: isRead ?? this.isRead,
createdAt: createdAt,
);
}
}

