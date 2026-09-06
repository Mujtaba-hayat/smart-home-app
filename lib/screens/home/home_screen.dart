import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/device_provider.dart';
import '../../providers/smart_home_provider.dart';

import 'widgets/greeting_section.dart';
import 'widgets/status_card.dart';
import 'widgets/device_card.dart';
import 'widgets/pump_card.dart';

import 'widgets/search_bar_widget.dart';
import 'widgets/filter_chips.dart';

import '../device_details/device_details_screen.dart';
import '../add_device/add_device_screen.dart';

import 'widgets/room_status_card.dart';

import '../../data/room_data.dart';
import 'widgets/home_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // ====================================================
    // INITIAL REFRESH
    // ====================================================

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      _refreshHomeData();
    });

    // ====================================================
    // AUTOMATIC REFRESH
    // ====================================================

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) {
        if (!mounted) return;

        _refreshHomeData();
      },
    );
  }

  // ====================================================
  // REFRESH HOME DATA
  // ====================================================

  Future<void> _refreshHomeData() async {
    if (!mounted) return;

    debugPrint(
      "=================================",
    );

    debugPrint(
      "HOME SCREEN REFRESH",
    );

    debugPrint(
      "=================================",
    );

    final deviceProvider =
    Provider.of<DeviceProvider>(
      context,
      listen: false,
    );

    final smartHomeProvider =
    Provider.of<SmartHomeProvider>(
      context,
      listen: false,
    );

    // --------------------------------------------------
    // Refresh devices
    // --------------------------------------------------

    await deviceProvider.refreshAll();

    // --------------------------------------------------
    // Refresh Smart Home
    // --------------------------------------------------

    await smartHomeProvider.refresh();

    if (!mounted) return;

    debugPrint(
      "=================================",
    );

    debugPrint(
      "HOME DATA REFRESH COMPLETE",
    );

    debugPrint(
      "SMART HOME: "
          "${smartHomeProvider.smartHomeName}",
    );

    debugPrint(
      "ESP32 ID: "
          "${smartHomeProvider.esp32Id}",
    );

    debugPrint(
      "ESP32 STATUS: "
          "${smartHomeProvider.esp32Status}",
    );

    debugPrint(
      "TEMPERATURE: "
          "${smartHomeProvider.temperature}",
    );

    debugPrint(
      "HUMIDITY: "
          "${smartHomeProvider.humidity}",
    );

    debugPrint(
      "DOOR: "
          "${smartHomeProvider.doorStatus}",
    );

    debugPrint(
      "ALARM ENABLED: "
          "${smartHomeProvider.alarmEnabled}",
    );

    debugPrint(
      "ALARM STATUS: "
          "${smartHomeProvider.alarmStatus}",
    );

    debugPrint(
      "=================================",
    );
  }

  // ====================================================
  // BUILD
  // ====================================================

  @override
  Widget build(BuildContext context) {
    final deviceProvider =
    Provider.of<DeviceProvider>(context);

    final smartHomeProvider =
    Provider.of<SmartHomeProvider>(
      context,
    );

    final bool isConnected =
        smartHomeProvider.esp32Connected;

    // ====================================================
    // ONLINE DEVICES
    // ====================================================

    final int onlineDevices =
    isConnected
        ? deviceProvider.devices.length
        : 0;

    // ====================================================
    // SENSOR VALUES
    // ====================================================

    final double? temperature =
        smartHomeProvider.temperature;

    final double? humidity =
        smartHomeProvider.humidity;

    final String doorStatus =
        smartHomeProvider.doorStatus;

    final bool doorOpen =
        smartHomeProvider.doorOpen;

    final bool alarmEnabled =
        smartHomeProvider.alarmEnabled;

    return Scaffold(
      drawer: const HomeMenu(),

      // ==================================================
      // ADD DEVICE
      // ==================================================

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        AppColors.primary,

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const AddDeviceScreen(),
            ),
          );
        },

        child: const Icon(
          Icons.add,
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHomeData,

          child:
          SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            padding:
            const EdgeInsets.all(20),

            child: Column(
              children: [
                // ====================================================
                // GREETING
                // ====================================================

                const GreetingSection(),

                const SizedBox(
                  height: 20,
                ),

                // ====================================================
                // SMART HOME CARD
                // ====================================================

                Container(
                  width:
                  double.infinity,

                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    AppColors.cardColor,

                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),

                    border:
                    Border.all(
                      color: isConnected
                          ? Colors.green
                          .withValues(
                        alpha: 0.55,
                      )
                          : Colors.red
                          .withValues(
                        alpha: 0.55,
                      ),

                      width: 1,
                    ),
                  ),

                  child: Row(
                    children: [
                      // ================================================
                      // HOME ICON
                      // ================================================

                      Container(
                        width: 46,
                        height: 46,

                        decoration:
                        BoxDecoration(
                          color: AppColors
                              .primary
                              .withValues(
                            alpha: 0.12,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            14,
                          ),
                        ),

                        child: Icon(
                          Icons
                              .home_rounded,

                          color:
                          AppColors
                              .primary,

                          size: 26,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      // ================================================
                      // SMART HOME INFORMATION
                      // ================================================

                      Expanded(
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [
                            Text(
                              smartHomeProvider
                                  .smartHomeName,

                              maxLines: 1,

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            if (smartHomeProvider
                                .esp32Id !=
                                null)
                              Text(
                                "ESP32: "
                                    "${smartHomeProvider.esp32Id}",

                                maxLines: 1,

                                overflow:
                                TextOverflow
                                    .ellipsis,

                                style:
                                const TextStyle(
                                  fontSize: 12,
                                  color:
                                  Colors
                                      .grey,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      // ================================================
                      // CONNECTION STATUS
                      // ================================================

                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),

                        decoration:
                        BoxDecoration(
                          color: isConnected
                              ? Colors.green
                              .withValues(
                            alpha: 0.12,
                          )
                              : Colors.red
                              .withValues(
                            alpha: 0.12,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            20,
                          ),
                        ),

                        child: Row(
                          mainAxisSize:
                          MainAxisSize
                              .min,

                          children: [
                            Container(
                              width: 7,
                              height: 7,

                              decoration:
                              BoxDecoration(
                                color: isConnected
                                    ? Colors
                                    .green
                                    : Colors
                                    .red,

                                shape:
                                BoxShape
                                    .circle,
                              ),
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Text(
                              isConnected
                                  ? "Connected"
                                  : "Disconnected",

                              style:
                              TextStyle(
                                fontSize: 11,

                                fontWeight:
                                FontWeight
                                    .w600,

                                color: isConnected
                                    ? Colors
                                    .green
                                    : Colors
                                    .red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // ====================================================
                // SENSOR CARD
                // ====================================================

                _buildSensorCard(
                  temperature:
                  temperature,

                  humidity:
                  humidity,

                  doorStatus:
                  doorStatus,

                  doorOpen:
                  doorOpen,

                  isConnected:
                  isConnected,

                  lastUpdated:
                  smartHomeProvider
                      .sensorLastUpdated,
                ),

                const SizedBox(
                  height: 25,
                ),

                // ====================================================
                // STATISTICS
                // ====================================================

                Row(
                  children: [
                    StatusCard(
                      title: "Online",

                      value:
                      onlineDevices
                          .toString(),

                      icon:
                      Icons.wifi,
                    ),

                    StatusCard(
                      title: "Active",

                      value:
                      deviceProvider
                          .activeDevices
                          .toString(),

                      icon:
                      Icons.flash_on,
                    ),
                  ],
                ),

                Row(
                  children: [
                    StatusCard(
                      title: "Power",

                      value:
                      "${deviceProvider.currentPowerUsage.toStringAsFixed(0)} W",

                      icon:
                      Icons.bolt,
                    ),

                    // ==================================================
                    // DOOR ALARM CARD
                    // ==================================================

                    _buildAlarmCard(
                      alarmEnabled:
                      alarmEnabled,

                      doorOpen:
                      doorOpen,

                      isConnected:
                      isConnected,

                      onChanged:
                          (value) {
                        smartHomeProvider
                            .setDoorAlarm(
                          value,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),

                // ====================================================
                // PUMP
                // ====================================================

                PumpCard(
                  isRunning:
                  deviceProvider
                      .pumpRunning,

                  selectedMinutes:
                  deviceProvider
                      .selectedPumpMinutes,

                  remainingTime:
                  deviceProvider
                      .formattedRemainingTime,

                  onDurationChanged:
                      (value) {
                    if (value != null) {
                      deviceProvider
                          .changePumpDuration(
                        value,
                      );
                    }
                  },

                  onStart: () {
                    deviceProvider
                        .startPump();
                  },

                  onStop: () {
                    deviceProvider
                        .stopPump();
                  },
                ),

                const SizedBox(
                  height: 25,
                ),

                // ====================================================
                // ROOM OVERVIEW
                // ====================================================

                const Align(
                  alignment:
                  Alignment.centerLeft,

                  child: Text(
                    "Room Overview",

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                ListView.builder(
                  shrinkWrap: true,

                  physics:
                  const NeverScrollableScrollPhysics(),

                  itemCount:
                  roomList.length,

                  itemBuilder:
                      (context, index) {
                    final room =
                    roomList[index];

                    return RoomStatusCard(
                      roomName:
                      room.name,

                      totalDevices:
                      deviceProvider
                          .getDeviceCount(
                        room.name,
                      ),

                      activeDevices:
                      deviceProvider
                          .getActiveDeviceCount(
                        room.name,
                      ),
                    );
                  },
                ),

                // ====================================================
                // SEARCH
                // ====================================================

                SearchBarWidget(
                  onChanged: (value) {
                    deviceProvider
                        .updateSearch(
                      value,
                    );
                  },
                ),

                const SizedBox(
                  height: 15,
                ),

                // ====================================================
                // FILTER
                // ====================================================

                FilterChips(
                  selected:
                  deviceProvider
                      .selectedFilter,

                  onSelected:
                      (value) {
                    deviceProvider
                        .updateFilter(
                      value,
                    );
                  },

                  showFavoritesOnly:
                  deviceProvider
                      .showFavoriteOnly,

                  onFavoriteTap: () {
                    deviceProvider
                        .toggleFavoritesFilter();
                  },
                ),

                const SizedBox(
                  height: 25,
                ),

                // ====================================================
                // DEVICES
                // ====================================================

                GridView.builder(
                  shrinkWrap: true,

                  physics:
                  const NeverScrollableScrollPhysics(),

                  itemCount:
                  deviceProvider
                      .filteredDevices
                      .length,

                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    crossAxisSpacing: 15,

                    mainAxisSpacing: 15,

                    childAspectRatio:
                    0.72,
                  ),

                  itemBuilder:
                      (context, index) {
                    final device =
                    deviceProvider
                        .filteredDevices[
                    index];

                    debugPrint(
                      "BUILDING DEVICE CARD:"
                          " ${device.name}"
                          " | Relay: ${device.relay}"
                          " | isOn: ${device.isOn}",
                    );

                    return DeviceCard(
                      deviceName:
                      device.name,

                      icon: _getIcon(
                        device.iconName,
                      ),

                      isOn:
                      device.isOn,

                      isFavorite:
                      device.isFavorite,

                      onToggle: () {
                        deviceProvider
                            .toggleDevice(
                          device,
                        );
                      },

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DeviceDetailsScreen(
                                  device:
                                  device,
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================================================
  // ALARM CARD
  // ====================================================

  Widget _buildAlarmCard({
    required bool alarmEnabled,
    required bool doorOpen,
    required bool isConnected,
    required ValueChanged<bool> onChanged,
  }) {
    final bool alertActive =
        alarmEnabled && doorOpen;

    Color statusColor;

    if (alertActive) {
      statusColor = Colors.red;
    } else if (alarmEnabled) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
    }

    String statusText;

    if (alertActive) {
      statusText = "Alert";
    } else if (alarmEnabled) {
      statusText = "Armed";
    } else {
      statusText = "Off";
    }

    return Expanded(
      child: Container(
        margin:
        const EdgeInsets.all(6),

        padding:
        const EdgeInsets.all(14),

        decoration:
        BoxDecoration(
          color:
          AppColors.cardColor,

          borderRadius:
          BorderRadius.circular(
            20,
          ),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ==============================================
            // ICON + TOGGLE
            // ==============================================

            Row(
              children: [
                Icon(
                  alertActive
                      ? Icons
                      .warning_amber_rounded
                      : Icons.security_rounded,

                  color:
                  statusColor,

                  size: 28,
                ),

                const Spacer(),

                Switch(
                  value:
                  alarmEnabled,

                  onChanged:
                  isConnected
                      ? onChanged
                      : null,

                  activeThumbColor:
                  AppColors.primary,
                ),
              ],
            ),

            const SizedBox(
              height: 7,
            ),

            // ==============================================
            // STATUS
            // ==============================================

            Text(
              statusText,

              maxLines: 1,

              overflow:
              TextOverflow.ellipsis,

              style:
              TextStyle(
                fontSize: 20,

                fontWeight:
                FontWeight.bold,

                color:
                statusColor,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            // ==============================================
            // TITLE
            // ==============================================

            const Text(
              "Door Alarm",

              maxLines: 1,

              overflow:
              TextOverflow.ellipsis,

              style:
              TextStyle(
                color:
                AppColors
                    .textSecondary,

                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            // ==============================================
            // DOOR STATUS
            // ==============================================

            Text(
              doorOpen
                  ? "Door Open"
                  : "Door Closed",

              maxLines: 1,

              overflow:
              TextOverflow.ellipsis,

              style:
              TextStyle(
                fontSize: 11,

                color:
                doorOpen
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // SENSOR CARD
  // ====================================================

  Widget _buildSensorCard({
    required double? temperature,
    required double? humidity,
    required String doorStatus,
    required bool doorOpen,
    required bool isConnected,
    required DateTime? lastUpdated,
  }) {
    final bool hasTemperature =
        temperature != null;

    final bool hasHumidity =
        humidity != null;

    final bool hasDoorStatus =
        doorStatus.isNotEmpty;

    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(18),

      decoration:
      BoxDecoration(
        color:
        AppColors.cardColor,

        borderRadius:
        BorderRadius.circular(18),

        border:
        Border.all(
          color: isConnected
              ? AppColors.primary
              .withValues(
            alpha: 0.20,
          )
              : Colors.grey
              .withValues(
            alpha: 0.25,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          // ==================================================
          // HEADER
          // ==================================================

          Row(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration:
                BoxDecoration(
                  color: AppColors
                      .primary
                      .withValues(
                    alpha: 0.12,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),

                child: Icon(
                  Icons.sensors_rounded,

                  color:
                  AppColors.primary,

                  size: 24,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Text(
                      "Home Sensors",

                      style:
                      TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(
                      height: 3,
                    ),

                    Text(
                      "Live sensor readings",

                      style:
                      TextStyle(
                        fontSize: 12,
                        color:
                        Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // SENSOR CONNECTION
              // ============================================

              Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),

                decoration:
                BoxDecoration(
                  color: isConnected
                      ? Colors.green
                      .withValues(
                    alpha: 0.10,
                  )
                      : Colors.grey
                      .withValues(
                    alpha: 0.10,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),

                child: Text(
                  isConnected
                      ? "LIVE"
                      : "OFFLINE",

                  style:
                  TextStyle(
                    fontSize: 10,

                    fontWeight:
                    FontWeight.bold,

                    color: isConnected
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // ==================================================
          // SENSOR VALUES
          // ==================================================

          Row(
            children: [
              // ============================================
              // TEMPERATURE
              // ============================================

              Expanded(
                child:
                _buildSensorItem(
                  icon:
                  Icons.thermostat,

                  title:
                  "Temperature",

                  value:
                  hasTemperature
                      ? "${temperature!.toStringAsFixed(1)} °C"
                      : "--",

                  iconColor:
                  Colors.orange,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              // ============================================
              // HUMIDITY
              // ============================================

              Expanded(
                child:
                _buildSensorItem(
                  icon:
                  Icons.water_drop,

                  title:
                  "Humidity",

                  value:
                  hasHumidity
                      ? "${humidity!.toStringAsFixed(1)} %"
                      : "--",

                  iconColor:
                  Colors.blue,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              // ============================================
              // DOOR
              // ============================================

              Expanded(
                child:
                _buildSensorItem(
                  icon: doorOpen
                      ? Icons
                      .door_front_door
                      : Icons
                      .door_sliding,

                  title:
                  "Door",

                  value:
                  hasDoorStatus
                      ? doorOpen
                      ? "Open"
                      : "Closed"
                      : "--",

                  iconColor:
                  doorOpen
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ],
          ),

          // ==================================================
          // LAST UPDATED
          // ==================================================

          if (lastUpdated != null) ...[
            const SizedBox(
              height: 15,
            ),

            Row(
              children: [
                const Icon(
                  Icons
                      .update_rounded,

                  size: 14,

                  color:
                  Colors.grey,
                ),

                const SizedBox(
                  width: 5,
                ),

                Text(
                  "Last updated: "
                      "${_formatSensorTime(lastUpdated)}",

                  style:
                  const TextStyle(
                    fontSize: 11,
                    color:
                    Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ====================================================
  // SENSOR ITEM
  // ====================================================

  Widget _buildSensorItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.grey.withValues(
          alpha: 0.06,
        ),

        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,

            color:
            iconColor,

            size: 25,
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            title,

            maxLines: 1,

            overflow:
            TextOverflow.ellipsis,

            style:
            const TextStyle(
              fontSize: 10,
              color:
              Colors.grey,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            value,

            maxLines: 1,

            overflow:
            TextOverflow.ellipsis,

            style:
            const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // FORMAT SENSOR TIME
  // ====================================================

  String _formatSensorTime(
      DateTime dateTime,
      ) {
    final local =
    dateTime.toLocal();

    final hour =
    local.hour % 12 == 0
        ? 12
        : local.hour % 12;

    final minute =
    local.minute
        .toString()
        .padLeft(2, "0");

    final period =
    local.hour >= 12
        ? "PM"
        : "AM";

    return "$hour:$minute $period";
  }

  // ====================================================
  // DISPOSE
  // ====================================================

  @override
  void dispose() {
    _refreshTimer?.cancel();

    super.dispose();
  }

  // ====================================================
  // ICON
  // ====================================================

  IconData _getIcon(
      String iconName,
      ) {
    switch (iconName) {
      case "lightbulb":
        return Icons.lightbulb;

      case "fan":
        return Icons.air;

      case "pump":
        return Icons.water_drop;

      case "alarm":
        return Icons.security;

      default:
        return Icons.devices;
    }
  }
}