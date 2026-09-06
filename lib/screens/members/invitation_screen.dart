import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/member_provider.dart';

class MemberInvitationScreen extends StatefulWidget {
  const MemberInvitationScreen({super.key});

  @override
  State<MemberInvitationScreen> createState() =>
      _MemberInvitationScreenState();
}

class _MemberInvitationScreenState
    extends State<MemberInvitationScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loadInvitations();
    });
  }

  Future<void> _loadInvitations() async {
    final provider = Provider.of<MemberProvider>(
      context,
      listen: false,
    );

    await provider.loadInvitations();

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _acceptInvitation(
      String memberId,
      ) async {
    final provider = Provider.of<MemberProvider>(
      context,
      listen: false,
    );

    final success =
    await provider.acceptInvitation(memberId);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Invitation accepted successfully"
              : provider.errorMessage ??
              "Unable to accept invitation",
        ),
      ),
    );

    if (success) {
      await _loadInvitations();
    }
  }

  Future<void> _rejectInvitation(
      String memberId,
      ) async {
    final provider = Provider.of<MemberProvider>(
      context,
      listen: false,
    );

    final success =
    await provider.rejectInvitation(memberId);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Invitation rejected"
              : provider.errorMessage ??
              "Unable to reject invitation",
        ),
      ),
    );

    if (success) {
      await _loadInvitations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MemberProvider>(
      context,
    );

    final invitations =
        provider.invitations;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Invitations",
        ),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : invitations.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 70,
            ),
            SizedBox(height: 15),
            Text(
              "No pending invitations",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadInvitations,
        child: ListView.builder(
          padding:
          const EdgeInsets.all(16),
          itemCount:
          invitations.length,
          itemBuilder:
              (context, index) {
            final invitation =
            invitations[index];

            return _InvitationCard(
              invitation:
              invitation,
              onAccept: () {
                _acceptInvitation(
                  invitation["_id"]
                      .toString(),
                );
              },
              onReject: () {
                _rejectInvitation(
                  invitation["_id"]
                      .toString(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final Map<String, dynamic> invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _InvitationCard({
    required this.invitation,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final smartHome =
    invitation["smartHome"]
    as Map<String, dynamic>?;

    final invitedBy =
    invitation["invitedBy"]
    as Map<String, dynamic>?;

    final homeName =
        smartHome?["name"]?.toString() ??
            "Smart Home";

    final ownerName =
        invitedBy?["name"]?.toString() ??
            invitedBy?["fullName"]?.toString() ??
            invitedBy?["email"]?.toString() ??
            "Smart Home Owner";

    final canControlDevices =
        invitation["canControlDevices"] ==
            true;

    final canControlPump =
        invitation["canControlPump"] ==
            true;

    final canManageDevices =
        invitation["canManageDevices"] ==
            true;

    final canManageMembers =
        invitation["canManageMembers"] ==
            true;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.home,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        homeName,
                        style:
                        const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Invitation from $ownerName",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Your Permissions",
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _PermissionRow(
              title: "Control Devices",
              enabled:
              canControlDevices,
            ),

            _PermissionRow(
              title: "Control Water Pump",
              enabled:
              canControlPump,
            ),

            _PermissionRow(
              title: "Manage Devices",
              enabled:
              canManageDevices,
            ),

            _PermissionRow(
              title: "Manage Members",
              enabled:
              canManageMembers,
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                    onReject,
                    style:
                    OutlinedButton
                        .styleFrom(
                      foregroundColor:
                      Colors.red,
                    ),
                    child:
                    const Text(
                      "REJECT",
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child:
                  ElevatedButton(
                    onPressed:
                    onAccept,
                    child:
                    const Text(
                      "ACCEPT",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionRow
    extends StatelessWidget {
  final String title;
  final bool enabled;

  const _PermissionRow({
    required this.title,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Icon(
            enabled
                ? Icons.check_circle
                : Icons.cancel,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}