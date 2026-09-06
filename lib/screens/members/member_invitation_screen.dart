import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/member_provider.dart';

class MemberInvitationsScreen extends StatefulWidget {
  const MemberInvitationsScreen({super.key});

  @override
  State<MemberInvitationsScreen> createState() =>
      _MemberInvitationsScreenState();
}

class _MemberInvitationsScreenState
    extends State<MemberInvitationsScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvitations();
    });
  }

  // =====================================================
  // LOAD INVITATIONS
  // =====================================================

  Future<void> _loadInvitations() async {
    final provider = Provider.of<MemberProvider>(
      context,
      listen: false,
    );

    await provider.loadMyInvitations();
  }

  // =====================================================
  // ACCEPT INVITATION
  // =====================================================

  Future<void> _acceptInvitation(
      String memberId,
      ) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final provider = Provider.of<MemberProvider>(
      context,
      listen: false,
    );

    final success =
    await provider.acceptInvitation(memberId);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Invitation accepted successfully",
          ),
        ),
      );

      // Refresh invitation list.
      await provider.loadMyInvitations();

      if (!mounted) return;

      // Go back to previous screen after accepting.
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                "Failed to accept invitation",
          ),
        ),
      );
    }
  }

  // =====================================================
  // REJECT INVITATION
  // =====================================================

  Future<void> _rejectInvitation(
      String memberId,
      ) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final provider = Provider.of<MemberProvider>(
      context,
      listen: false,
    );

    final success =
    await provider.rejectInvitation(memberId);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Invitation rejected successfully",
          ),
        ),
      );

      await provider.loadMyInvitations();

      if (!mounted) return;

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                "Failed to reject invitation",
          ),
        ),
      );
    }
  }

  // =====================================================
  // INVITATION CARD
  // =====================================================

  Widget _buildInvitationCard(
      Map<String, dynamic> invitation,
      ) {
    final memberId =
        invitation["_id"]?.toString() ??
            invitation["id"]?.toString() ??
            "";

    final smartHomeData =
    invitation["smartHome"];

    final invitedByData =
    invitation["invitedBy"];

    final Map<String, dynamic> smartHome =
    smartHomeData is Map
        ? Map<String, dynamic>.from(
      smartHomeData,
    )
        : {};

    final Map<String, dynamic> invitedBy =
    invitedByData is Map
        ? Map<String, dynamic>.from(
      invitedByData,
    )
        : {};

    final homeName =
        smartHome["name"]?.toString() ??
            "Smart Home";

    final inviterName =
        invitedBy["name"]?.toString() ??
            invitedBy["fullName"]?.toString() ??
            invitedBy["email"]?.toString() ??
            "Smart Home Owner";

    final inviterEmail =
        invitedBy["email"]?.toString() ?? "";

    final controlDevices =
        invitation["canControlDevices"] == true;

    final controlPump =
        invitation["canControlPump"] == true;

    final manageDevices =
        invitation["canManageDevices"] == true;

    final manageMembers =
        invitation["canManageMembers"] == true;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // =================================================
            // HEADER
            // =================================================

            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Smart Home Invitation",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        homeName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =================================================
            // INVITED BY
            // =================================================

            Text(
              "Invited by",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 4),

            Text(
              inviterName,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            if (inviterEmail.isNotEmpty) ...[
              const SizedBox(height: 2),

              Text(
                inviterEmail,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 18),

            // =================================================
            // PERMISSIONS
            // =================================================

            Text(
              "Your permissions",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _permissionRow(
              Icons.power_settings_new,
              "Control devices",
              controlDevices,
            ),

            _permissionRow(
              Icons.water_drop_outlined,
              "Control water pump",
              controlPump,
            ),

            _permissionRow(
              Icons.devices_other,
              "Manage devices",
              manageDevices,
            ),

            _permissionRow(
              Icons.people_outline,
              "Manage members",
              manageMembers,
            ),

            const SizedBox(height: 18),

            // =================================================
            // ACTION BUTTONS
            // =================================================

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                    _isProcessing ||
                        memberId.isEmpty
                        ? null
                        : () {
                      _rejectInvitation(
                        memberId,
                      );
                    },
                    style:
                    OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Reject",
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed:
                    _isProcessing ||
                        memberId.isEmpty
                        ? null
                        : () {
                      _acceptInvitation(
                        memberId,
                      );
                    },
                    style:
                    ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Accept",
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

  // =====================================================
  // PERMISSION ROW
  // =====================================================

  Widget _permissionRow(
      IconData icon,
      String title,
      bool enabled,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: enabled
                ? Theme.of(context)
                .colorScheme
                .primary
                : Colors.grey,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color:
                enabled ? null : Colors.grey,
              ),
            ),
          ),

          Icon(
            enabled
                ? Icons.check_circle
                : Icons.cancel_outlined,
            size: 20,
            color: enabled
                ? Colors.green
                : Colors.grey,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        final invitations =
            provider.invitations;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Invitations",
            ),
          ),

          body: provider.isLoading
              ? const Center(
            child:
            CircularProgressIndicator(),
          )
              : RefreshIndicator(
            onRefresh:
            _loadInvitations,
            child: invitations.isEmpty
                ? ListView(
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
                      0.3,
                ),

                Icon(
                  Icons.mail_outline,
                  size: 70,
                  color:
                  Colors.grey[400],
                ),

                const SizedBox(
                  height: 16,
                ),

                Center(
                  child: Text(
                    "No pending invitations",
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      color:
                      Colors.grey[
                      600],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Center(
                  child: Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 30,
                    ),
                    child: Text(
                      "New Smart Home invitations "
                          "will appear here.",
                      textAlign:
                      TextAlign.center,
                      style: Theme.of(
                        context,
                      )
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color:
                        Colors.grey[
                        500],
                      ),
                    ),
                  ),
                ),
              ],
            )
                : ListView.builder(
              padding:
              const EdgeInsets.all(
                16,
              ),
              itemCount:
              invitations.length,
              itemBuilder:
                  (context, index) {
                final invitation =
                invitations[index];

                if (invitation
                is Map) {
                  return _buildInvitationCard(
                    Map<String, dynamic>.from(
                      invitation,
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        );
      },
    );
  }
}