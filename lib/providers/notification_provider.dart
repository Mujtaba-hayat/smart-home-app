import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../api/api_service.dart';

class NotificationProvider extends ChangeNotifier {
// ====================================================
// STATE
// ====================================================

List<NotificationModel> _notifications = [];

int _unreadCount = 0;

bool _isLoading = false;

bool _isMarkingAllRead = false;

String? _error;

// ====================================================
// GETTERS
// ====================================================

List<NotificationModel> get notifications =>
List.unmodifiable(_notifications);

int get unreadCount => _unreadCount;

bool get isLoading => _isLoading;

bool get isMarkingAllRead => _isMarkingAllRead;

String? get error => _error;

bool get hasNotifications =>
_notifications.isNotEmpty;

bool get hasUnreadNotifications =>
_unreadCount > 0;

// ====================================================
// LOAD NOTIFICATIONS
//
// GET /user/notifications
// ====================================================

Future<void> loadNotifications() async {
_isLoading = true;
_error = null;

notifyListeners();

try {
debugPrint("=================================");
debugPrint("NOTIFICATION PROVIDER");
debugPrint("LOADING NOTIFICATIONS");
debugPrint("=================================");

final response =
await ApiService.getNotifications();

// ==================================================
// NOTIFICATIONS
// ==================================================

final notificationData =
response["notifications"];

if (notificationData is List) {
_notifications = notificationData
    .whereType<Map<String, dynamic>>()
    .map(
(json) =>
NotificationModel.fromJson(json),
)
    .toList();
} else {
_notifications = [];
}

// ==================================================
// UNREAD COUNT
// ==================================================

final unread =
response["unreadCount"];

if (unread is int) {
_unreadCount = unread;
} else if (unread is num) {
_unreadCount = unread.toInt();
} else {
// Fallback calculation
_unreadCount = _notifications
    .where(
(notification) =>
!notification.isRead,
)
    .length;
}

// ==================================================
// SAFETY CHECK
//
// Make sure unread count never exceeds
// the number of loaded notifications.
// ==================================================

if (_unreadCount < 0) {
_unreadCount = 0;
}

if (_unreadCount > _notifications.length) {
_unreadCount = _notifications
    .where(
(notification) =>
!notification.isRead,
)
    .length;
}

debugPrint(
"Notifications loaded: "
"${_notifications.length}",
);

debugPrint(
"Unread notifications: "
"$_unreadCount",
);

debugPrint("=================================");
} catch (e) {
debugPrint(
"LOAD NOTIFICATIONS ERROR: $e",
);

_error = e.toString();
} finally {
_isLoading = false;

notifyListeners();
}
}

// ====================================================
// REFRESH NOTIFICATIONS
// ====================================================

Future<void> refreshNotifications() async {
await loadNotifications();
}

// ====================================================
// MARK ONE NOTIFICATION AS READ
//
// PUT /user/notifications/:notificationId/read
// ====================================================

Future<bool> markNotificationRead(
String notificationId,
) async {
try {
debugPrint(
"MARK NOTIFICATION READ: "
"$notificationId",
);

await ApiService.markNotificationRead(
notificationId,
);

// ==================================================
// UPDATE LOCAL LIST
// ==================================================

final index =
_notifications.indexWhere(
(notification) =>
notification.id == notificationId,
);

if (index != -1) {
final notification =
_notifications[index];

if (!notification.isRead) {
_notifications[index] =
notification.copyWith(
isRead: true,
);

if (_unreadCount > 0) {
_unreadCount--;
}
}
}

_error = null;

notifyListeners();

return true;
} catch (e) {
debugPrint(
"MARK NOTIFICATION READ ERROR: $e",
);

_error = e.toString();

notifyListeners();

return false;
}
}

// ====================================================
// MARK ALL NOTIFICATIONS AS READ
//
// PUT /user/notifications/read-all
// ====================================================

Future<bool> markAllNotificationsRead() async {
if (_unreadCount == 0) {
return true;
}

_isMarkingAllRead = true;

_error = null;

notifyListeners();

try {
debugPrint(
"MARK ALL NOTIFICATIONS AS READ",
);

await ApiService
    .markAllNotificationsRead();

// ==================================================
// UPDATE LOCAL LIST
// ==================================================

_notifications = _notifications
    .map(
(notification) =>
notification.copyWith(
isRead: true,
),
)
    .toList();

_unreadCount = 0;

debugPrint(
"All notifications marked as read.",
);

notifyListeners();

return true;
} catch (e) {
debugPrint(
"MARK ALL READ ERROR: $e",
);

_error = e.toString();

notifyListeners();

return false;
} finally {
_isMarkingAllRead = false;

notifyListeners();
}
}

// ====================================================
// DELETE NOTIFICATION
//
// DELETE /user/notifications/:notificationId
// ====================================================

Future<bool> deleteNotification(
String notificationId,
) async {
try {
debugPrint(
"DELETE NOTIFICATION: "
"$notificationId",
);

// ==================================================
// FIND BEFORE DELETE
// ==================================================

final index =
_notifications.indexWhere(
(notification) =>
notification.id == notificationId,
);

NotificationModel? notification;

if (index != -1) {
notification =
_notifications[index];
}

// ==================================================
// DELETE FROM BACKEND
// ==================================================

await ApiService.deleteNotification(
notificationId,
);

// ==================================================
// REMOVE LOCALLY
// ==================================================

if (index != -1) {
_notifications.removeAt(index);

// =================================================
// UPDATE UNREAD COUNT
// =================================================

if (notification != null &&
!notification.isRead &&
_unreadCount > 0) {
_unreadCount--;
}
}

_error = null;

notifyListeners();

return true;
} catch (e) {
debugPrint(
"DELETE NOTIFICATION ERROR: $e",
);

_error = e.toString();

notifyListeners();

return false;
}
}

// ====================================================
// CLEAR ERROR
// ====================================================

void clearError() {
_error = null;

notifyListeners();
}

// ====================================================
// CLEAR LOCAL NOTIFICATIONS
//
// Used during logout.
// ====================================================

void clearNotifications() {
_notifications = [];

_unreadCount = 0;

_error = null;

_isLoading = false;

_isMarkingAllRead = false;

notifyListeners();
}
}
