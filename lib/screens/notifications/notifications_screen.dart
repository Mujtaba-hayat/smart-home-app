import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
const NotificationsScreen({super.key});

@override
State<NotificationsScreen> createState() =>
_NotificationsScreenState();
}

class _NotificationsScreenState
extends State<NotificationsScreen> {

// ====================================================
// INIT STATE
// ====================================================

@override
void initState() {
super.initState();

WidgetsBinding.instance.addPostFrameCallback((_) {
if (!mounted) {
return;
}

context
    .read<NotificationProvider>()
    .loadNotifications();
});
}

// ====================================================
// NOTIFICATION ICON
// ====================================================

IconData _getNotificationIcon(String type) {
switch (type) {
case "door_alarm":
return Icons.warning_rounded;

case "device":
return Icons.power_settings_new_rounded;

case "pump":
return Icons.water_drop_rounded;

case "sensor":
return Icons.sensors_rounded;

case "system":
default:
return Icons.notifications_rounded;
}
}

// ====================================================
// NOTIFICATION COLOR
// ====================================================

Color _getNotificationColor(String type) {
switch (type) {
case "door_alarm":
return Colors.red;

case "device":
return Colors.blue;

case "pump":
return Colors.cyan;

case "sensor":
return Colors.orange;

case "system":
default:
return Colors.grey;
}
}

// ====================================================
// TIME FORMAT
// ====================================================

String _formatTime(DateTime dateTime) {
final now = DateTime.now();

final difference = now.difference(
dateTime.toLocal(),
);

if (difference.isNegative) {
return "Just now";
}

if (difference.inSeconds < 60) {
return "Just now";
}

if (difference.inMinutes < 60) {
return "${difference.inMinutes}m ago";
}

if (difference.inHours < 24) {
return "${difference.inHours}h ago";
}

if (difference.inDays < 7) {
return "${difference.inDays}d ago";
}

final localDate = dateTime.toLocal();

return "${localDate.day}/"
"${localDate.month}/"
"${localDate.year}";
}

// ====================================================
// DELETE NOTIFICATION
// ====================================================

Future<void> _deleteNotification(
NotificationModel notification,
) async {
final provider =
context.read<NotificationProvider>();

final success =
await provider.deleteNotification(
notification.id,
);

if (!mounted) {
return;
}

if (!success) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Failed to delete notification",
),
),
);
}
}

// ====================================================
// CONFIRM DELETE
// ====================================================

Future<bool> _confirmDelete(
NotificationModel notification,
) async {
final result = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text(
"Delete Notification",
),

content: const Text(
"Are you sure you want to delete this notification?",
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(
dialogContext,
false,
);
},

child: const Text(
"Cancel",
),
),

FilledButton(
onPressed: () {
Navigator.pop(
dialogContext,
true,
);
},

child: const Text(
"Delete",
),
),
],
);
},
);

return result ?? false;
}

// ====================================================
// MARK AS READ
// ====================================================

Future<void> _openNotification(
NotificationModel notification,
) async {
if (notification.isRead) {
return;
}

await context
    .read<NotificationProvider>()
    .markNotificationRead(
notification.id,
);
}

// ====================================================
// NOTIFICATION CARD
// ====================================================

Widget _buildNotificationCard(
NotificationModel notification,
) {
final iconColor =
_getNotificationColor(
notification.type,
);

final icon =
_getNotificationIcon(
notification.type,
);

final theme = Theme.of(context);

return Dismissible(
key: ValueKey(
notification.id,
),

direction:
DismissDirection.endToStart,

confirmDismiss: (_) async {
final confirmed =
await _confirmDelete(
notification,
);

if (!confirmed) {
return false;
}

await _deleteNotification(
notification,
);

return true;
},

// ==================================================
// DELETE BACKGROUND
// ==================================================

background: Container(
margin: const EdgeInsets.only(
bottom: 12,
),

alignment:
Alignment.centerRight,

padding:
const EdgeInsets.only(
right: 20,
),

decoration: BoxDecoration(
color: Colors.red,

borderRadius:
BorderRadius.circular(16),
),

child: const Icon(
Icons.delete_outline,

color: Colors.white,

size: 26,
),
),

// ==================================================
// CARD
// ==================================================

child: InkWell(
borderRadius:
BorderRadius.circular(16),

onTap: () {
_openNotification(
notification,
);
},

child: Container(
margin:
const EdgeInsets.only(
bottom: 12,
),

padding:
const EdgeInsets.all(16),

decoration: BoxDecoration(

// ============================================
// CARD BACKGROUND
// ============================================

color: notification.isRead
? theme.cardColor
    : theme
    .colorScheme
    .primary
    .withValues(
alpha: 0.08,
),

borderRadius:
BorderRadius.circular(16),

// ============================================
// CARD BORDER
// ============================================

border: Border.all(
color: notification.isRead
? theme.dividerColor
    : theme
    .colorScheme
    .primary
    .withValues(
alpha: 0.25,
),
),
),

child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

// ==========================================
// ICON
// ==========================================

Container(
width: 46,
height: 46,

decoration:
BoxDecoration(
color:
iconColor.withValues(
alpha: 0.12,
),

shape:
BoxShape.circle,
),

child: Icon(
icon,

color: iconColor,

size: 24,
),
),

const SizedBox(
width: 14,
),

// ==========================================
// CONTENT
// ==========================================

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

// ====================================
// TITLE + TIME
// ====================================

Row(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Expanded(
child: Text(
notification.title,

style: TextStyle(
fontSize: 16,

fontWeight:
notification.isRead
? FontWeight.w600
    : FontWeight.bold,
),
),
),

const SizedBox(
width: 8,
),

Text(
_formatTime(
notification.createdAt,
),

style: TextStyle(
fontSize: 12,

color: theme
    .textTheme
    .bodySmall
    ?.color,
),
),
],
),

const SizedBox(
height: 6,
),

// ====================================
// MESSAGE
// ====================================

Text(
notification.message,

style: TextStyle(
fontSize: 14,

height: 1.4,

color: theme
    .textTheme
    .bodyMedium
    ?.color,
),
),

// ====================================
// UNREAD
// ====================================

if (!notification.isRead) ...[
const SizedBox(
height: 8,
),

Row(
children: [

Container(
width: 7,
height: 7,

decoration:
BoxDecoration(
color: theme
    .colorScheme
    .primary,

shape:
BoxShape.circle,
),
),

const SizedBox(
width: 6,
),

Text(
"Unread",

style: TextStyle(
fontSize: 12,

fontWeight:
FontWeight.w600,

color: theme
    .colorScheme
    .primary,
),
),
],
),
],
],
),
),
],
),
),
),
);
}

// ====================================================
// EMPTY STATE
// ====================================================

Widget _buildEmptyState() {
final theme =
Theme.of(context);

return Center(
child: Padding(
padding:
const EdgeInsets.all(32),

child: Column(
mainAxisAlignment:
MainAxisAlignment.center,

children: [

Icon(
Icons
    .notifications_none_rounded,

size: 80,

color:
theme.disabledColor,
),

const SizedBox(
height: 20,
),

Text(
"No Notifications",

style: theme
    .textTheme
    .titleLarge
    ?.copyWith(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 8,
),

Text(
"You're all caught up.",

textAlign:
TextAlign.center,

style:
theme.textTheme.bodyMedium,
),
],
),
),
);
}

// ====================================================
// ERROR STATE
// ====================================================

Widget _buildErrorState(
NotificationProvider provider,
) {
return Center(
child: Padding(
padding:
const EdgeInsets.all(32),

child: Column(
mainAxisAlignment:
MainAxisAlignment.center,

children: [

const Icon(
Icons.error_outline_rounded,

size: 64,
),

const SizedBox(
height: 16,
),

const Text(
"Unable to load notifications",

textAlign:
TextAlign.center,

style: TextStyle(
fontSize: 18,

fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 8,
),

Text(
provider.error ??
"Something went wrong.",

textAlign:
TextAlign.center,
),

const SizedBox(
height: 20,
),

ElevatedButton.icon(
onPressed:
provider.isLoading
? null
    : () {
provider
    .loadNotifications();
},

icon: provider.isLoading
? const SizedBox(
width: 18,
height: 18,

child:
CircularProgressIndicator(
strokeWidth: 2,
),
)
    : const Icon(
Icons.refresh,
),

label: Text(
provider.isLoading
? "Loading..."
    : "Try Again",
),
),
],
),
),
);
}

// ====================================================
// BUILD
// ====================================================

@override
Widget build(
BuildContext context,
) {
return Scaffold(

// ==================================================
// APP BAR
// ==================================================

appBar: AppBar(
title:
const Text(
"Notifications",
),

actions: [

Consumer<NotificationProvider>(
builder: (
context,
provider,
child,
) {

// ==========================================
// NO UNREAD NOTIFICATIONS
// ==========================================

if (!provider
    .hasUnreadNotifications) {
return const SizedBox
    .shrink();
}

return Row(
children: [

// ======================================
// UNREAD COUNT
// ======================================

Container(
constraints:
const BoxConstraints(
minWidth: 24,
minHeight: 24,
),

alignment:
Alignment.center,

padding:
const EdgeInsets
    .symmetric(
horizontal: 6,
),

decoration:
BoxDecoration(
color: Theme.of(
context,
)
    .colorScheme
    .error,

borderRadius:
BorderRadius
    .circular(
12,
),
),

child: Text(
provider
    .unreadCount
    .toString(),

style:
const TextStyle(
color:
Colors.white,

fontSize: 12,

fontWeight:
FontWeight.bold,
),
),
),

// ======================================
// READ ALL BUTTON
// ======================================

TextButton(
onPressed:
provider
    .isMarkingAllRead
? null
    : () async {
await provider
    .markAllNotificationsRead();
},

child: provider
    .isMarkingAllRead
? const SizedBox(
width: 18,
height: 18,

child:
CircularProgressIndicator(
strokeWidth: 2,
),
)
    : const Text(
"Read all",
),
),
],
);
},
),
],
),

// ==================================================
// BODY
// ==================================================

body:
Consumer<NotificationProvider>(
builder: (
context,
provider,
child,
) {

// ============================================
// INITIAL LOADING
// ============================================

if (provider.isLoading &&
!provider.hasNotifications) {

return const Center(
child:
CircularProgressIndicator(),
);
}

// ============================================
// ERROR
// ============================================

if (provider.error != null &&
!provider.hasNotifications) {

return _buildErrorState(
provider,
);
}

// ============================================
// EMPTY
// ============================================

if (!provider.hasNotifications) {

return RefreshIndicator(
onRefresh:
provider
    .refreshNotifications,

child: ListView(
physics:
const AlwaysScrollableScrollPhysics(),

children: [

SizedBox(
height:
MediaQuery.of(
context,
)
    .size
    .height *
0.7,

child:
_buildEmptyState(),
),
],
),
);
}

// ============================================
// NOTIFICATION LIST
// ============================================

return RefreshIndicator(
onRefresh:
provider
    .refreshNotifications,

child:
ListView.builder(

physics:
const AlwaysScrollableScrollPhysics(),

padding:
const EdgeInsets.all(16),

itemCount:
provider
    .notifications
    .length,

itemBuilder:
(
context,
index,
) {

final notification =
provider
    .notifications[index];

return _buildNotificationCard(
notification,
);
},
),
);
},
),
);
}
}

