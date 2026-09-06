import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/member_provider.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() =>
      _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final TextEditingController _emailController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      Provider.of<MemberProvider>(
        context,
        listen: false,
      ).loadMembers();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // =====================================================
  // ADD MEMBER
  // =====================================================

  Future<void> _showAddMemberDialog() async {
    _emailController.clear();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Invite Member",
          ),
          content: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Member Email",
              hintText: "Enter user's email",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                final email =
                _emailController.text.trim();

                if (email.isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please enter member email",
                      ),
                    ),
                  );

                  return;
                }

                Navigator.of(dialogContext).pop();

                final provider =
                Provider.of<MemberProvider>(
                  context,
                  listen: false,
                );

                final success =
                await provider.addMember(
                  email: email,
                  controlDevices: true,
                  controlPump: false,
                  manageMembers: false,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "Member invitation sent successfully"
                          : provider.errorMessage ??
                          "Failed to invite member",
                    ),
                  ),
                );
              },
              child: const Text("INVITE"),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // MEMBER CARD
  // =====================================================

  Widget _buildMemberCard(
      BuildContext context,
      dynamic member,
      ) {
    final name =
        member["user"]?["name"]?.toString() ??
            "Unknown User";

    final email =
        member["user"]?["email"]?.toString() ??
            "No email";

    final status =
        member["status"]?.toString() ??
            "pending";

    final controlDevices =
        member["controlDevices"] == true;

    final controlPump =
        member["controlPump"] == true;

    final manageMembers =
        member["manageMembers"] == true;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  child: Icon(
                    Icons.person,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),

            const SizedBox(height: 15),

            const Divider(),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Permissions",
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _permissionItem(
                    "Devices",
                    controlDevices,
                    Icons.devices,
                  ),
                ),
                Expanded(
                  child: _permissionItem(
                    "Pump",
                    controlPump,
                    Icons.water_drop,
                  ),
                ),
                Expanded(
                  child: _permissionItem(
                    "Members",
                    manageMembers,
                    Icons.group,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =====================================================
            // MEMBER MANAGEMENT ACTIONS
            // =====================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _showPermissionsDialog(
                      context,
                      member,
                    );
                  },
                  icon: const Icon(
                    Icons.settings,
                  ),
                  label: const Text(
                    "Permissions",
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  tooltip: "Remove member",
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _confirmRemoveMember(
                      context,
                      member,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // STATUS CHIP
  // =====================================================

  Widget _buildStatusChip(String status) {
    String text;
    IconData icon;

    if (status == "accepted") {
      text = "Accepted";
      icon = Icons.check_circle;
    } else if (status == "rejected") {
      text = "Rejected";
      icon = Icons.cancel;
    } else {
      text = "Pending";
      icon = Icons.pending;
    }

    return Chip(
      avatar: Icon(
        icon,
        size: 16,
      ),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }

  // =====================================================
  // PERMISSION ITEM
  // =====================================================

  Widget _permissionItem(
      String title,
      bool enabled,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          enabled
              ? "Allowed"
              : "Disabled",
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PERMISSIONS DIALOG
  // =====================================================

  Future<void> _showPermissionsDialog(
      BuildContext context,
      dynamic member,
      ) async {
    bool controlDevices =
        member["controlDevices"] == true;

    bool controlPump =
        member["controlPump"] == true;

    bool manageMembers =
        member["manageMembers"] == true;

    final memberId =
        member["_id"]?.toString() ??
            member["id"]?.toString();

    if (memberId == null) {
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              dialogContext,
              setDialogState,
              ) {
            return AlertDialog(
              title: const Text(
                "Member Permissions",
              ),
              content: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text(
                      "Control Devices",
                    ),
                    value: controlDevices,
                    onChanged: (value) {
                      setDialogState(() {
                        controlDevices = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text(
                      "Control Water Pump",
                    ),
                    value: controlPump,
                    onChanged: (value) {
                      setDialogState(() {
                        controlPump = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text(
                      "Manage Members",
                    ),
                    value: manageMembers,
                    onChanged: (value) {
                      setDialogState(() {
                        manageMembers = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text("CANCEL"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(
                      dialogContext,
                    ).pop();

                    final provider =
                    Provider.of<MemberProvider>(
                      context,
                      listen: false,
                    );

                    final success =
                    await provider
                        .updateMemberPermissions(
                      memberId: memberId,
                      controlDevices:
                      controlDevices,
                      controlPump:
                      controlPump,
                      manageMembers:
                      manageMembers,
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "Permissions updated successfully"
                              : provider.errorMessage ??
                              "Failed to update permissions",
                        ),
                      ),
                    );
                  },
                  child: const Text("SAVE"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================================
  // REMOVE MEMBER CONFIRMATION
  // =====================================================

  Future<void> _confirmRemoveMember(
      BuildContext context,
      dynamic member,
      ) async {
    final memberId =
        member["_id"]?.toString() ??
            member["id"]?.toString();

    if (memberId == null) {
      return;
    }

    final name =
        member["user"]?["name"]?.toString() ??
            "this member";

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Remove Member",
          ),
          content: Text(
            "Are you sure you want to remove $name from your Smart Home?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Colors.red,
                foregroundColor:
                Colors.white,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text("REMOVE"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) return;

    final provider =
    Provider.of<MemberProvider>(
      context,
      listen: false,
    );

    final success =
    await provider.removeMember(
      memberId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Member removed successfully"
              : provider.errorMessage ??
              "Failed to remove member",
        ),
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Members",
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: () {
              Provider.of<MemberProvider>(
                context,
                listen: false,
              ).loadMembers();
            },
          ),
        ],
      ),

      body: Consumer<MemberProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          // =====================================================
          // CHECK MEMBER MANAGEMENT PERMISSION
          // =====================================================

          final canManageMembers =
              provider.isOwner ||
                  provider.canManageMembers;

          // =====================================================
          // LOADING
          // =====================================================

          if (provider.isLoading) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          // =====================================================
          // NO PERMISSION
          // =====================================================

          if (!canManageMembers) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 60,
                      color:
                      Colors.grey.shade600,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      "Access Restricted",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      "You do not have permission to manage Smart Home members.",
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // =====================================================
          // ERROR
          // =====================================================

          if (provider.errorMessage != null &&
              provider.members.isEmpty) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      provider.errorMessage!,
                      textAlign:
                      TextAlign.center,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    ElevatedButton(
                      onPressed: () {
                        provider.loadMembers();
                      },
                      child: const Text(
                        "RETRY",
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // =====================================================
          // NO MEMBERS
          // =====================================================

          if (provider.members.isEmpty) {
            return RefreshIndicator(
              onRefresh:
              provider.loadMembers,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 150,
                  ),

                  Icon(
                    Icons.group_outlined,
                    size: 70,
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  Center(
                    child: Text(
                      "No members yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  Center(
                    child: Text(
                      "Invite someone to your Smart Home",
                    ),
                  ),
                ],
              ),
            );
          }

          // =====================================================
          // MEMBERS LIST
          // =====================================================

          return RefreshIndicator(
            onRefresh:
            provider.loadMembers,
            child: ListView(
              padding:
              const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading:
                    const CircleAvatar(
                      child: Icon(
                        Icons.group,
                      ),
                    ),

                    title: const Text(
                      "Smart Home Members",
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "${provider.members.length} member${provider.members.length == 1 ? '' : 's'}",
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                ...provider.members.map(
                      (member) =>
                      _buildMemberCard(
                        context,
                        member,
                      ),
                ),
              ],
            ),
          );
        },
      ),

      // =====================================================
      // ADD MEMBER BUTTON
      // ONLY OWNER / AUTHORIZED MEMBER
      // =====================================================

      floatingActionButton:
      Consumer<MemberProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          final canManageMembers =
              provider.isOwner ||
                  provider.canManageMembers;

          if (!canManageMembers) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed:
            _showAddMemberDialog,
            child: const Icon(
              Icons.person_add,
            ),
          );
        },
      ),
    );
  }
}