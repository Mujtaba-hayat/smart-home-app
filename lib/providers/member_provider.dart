import 'package:flutter/foundation.dart';

import '../api/api_service.dart';

class MemberProvider extends ChangeNotifier {
  // =====================================================
  // STATE
  // =====================================================

  bool _isLoading = false;

  String? _errorMessage;

  List<dynamic> _members = [];

  List<dynamic> _invitations = [];

  // =====================================================
  // SMART HOME STATE
  // =====================================================

  Map<String, dynamic>? _smartHome;

  Map<String, dynamic>? _owner;

  Map<String, dynamic>? _currentUserPermissions;

  bool _isOwner = false;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<dynamic> get members => _members;

  List<dynamic> get invitations => _invitations;

  bool get hasInvitations =>
      _invitations.isNotEmpty;

  // =====================================================
  // SMART HOME GETTERS
  // =====================================================

  Map<String, dynamic>? get smartHome =>
      _smartHome;

  Map<String, dynamic>? get owner =>
      _owner;

  Map<String, dynamic>? get currentUserPermissions =>
      _currentUserPermissions;

  bool get isOwner =>
      _isOwner;

  bool get isMember =>
      !_isOwner && _smartHome != null;

  bool get hasSmartHome =>
      _smartHome != null;

  // =====================================================
  // SMART HOME INFORMATION
  // =====================================================

  String get smartHomeName {
    return _smartHome?["name"]?.toString() ??
        "My Smart Home";
  }

  String? get smartHomeId {
    return _smartHome?["id"]?.toString();
  }

  String? get esp32Id {
    return _smartHome?["esp32Id"]?.toString();
  }

  String get smartHomeStatus {
    return _smartHome?["status"]?.toString() ??
        "disconnected";
  }

  bool get esp32Connected =>
      smartHomeStatus.toLowerCase() ==
          "connected";

  bool get pumpIsOn =>
      _smartHome?["pumpIsOn"] == true;

  // =====================================================
  // PERMISSION GETTERS
  // =====================================================

  bool get canControlDevices {
    return _currentUserPermissions?[
    "canControlDevices"] ==
        true;
  }

  bool get canControlPump {
    return _currentUserPermissions?[
    "canControlPump"] ==
        true;
  }

  bool get canManageDevices {
    return _currentUserPermissions?[
    "canManageDevices"] ==
        true;
  }

  bool get canManageMembers {
    return _currentUserPermissions?[
    "canManageMembers"] ==
        true;
  }

  // =====================================================
  // LOAD MEMBERS
  // =====================================================

  Future<void> loadMembers() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final response =
      await ApiService.getMembers();

      debugPrint("=================================");
      debugPrint("GET MEMBERS RAW RESPONSE:");
      debugPrint(response.toString());
      debugPrint("=================================");

      if (response["success"] == true) {
        // -------------------------------------------------
        // Members
        // -------------------------------------------------

        final data =
        response["members"];

        if (data is List) {
          _members =
          List<dynamic>.from(data);
        } else {
          _members = [];
        }

        // -------------------------------------------------
        // Smart Home
        // -------------------------------------------------

        final smartHomeData =
        response["smartHome"];

        if (smartHomeData is Map) {
          _smartHome =
          Map<String, dynamic>.from(
            smartHomeData,
          );
        } else {
          _smartHome = null;
        }

        // -------------------------------------------------
        // Owner
        // -------------------------------------------------

        final ownerData =
        response["owner"];

        if (ownerData is Map) {
          _owner =
          Map<String, dynamic>.from(
            ownerData,
          );
        } else {
          _owner = null;
        }

        // -------------------------------------------------
        // Is Owner
        // -------------------------------------------------

        _isOwner =
            response["isOwner"] == true;

        // -------------------------------------------------
        // Current User Permissions
        // -------------------------------------------------

        final permissions =
        response[
        "currentUserPermissions"];

        if (permissions is Map) {
          _currentUserPermissions =
          Map<String, dynamic>.from(
            permissions,
          );
        } else {
          _currentUserPermissions = null;
        }

        // -------------------------------------------------
        // Debug
        // -------------------------------------------------

        debugPrint(
          "=================================",
        );

        debugPrint(
          "MEMBER PROVIDER: MEMBERS LOADED",
        );

        debugPrint(
          "Smart Home: "
              "${_smartHome?["name"]}",
        );

        debugPrint(
          "Is Owner: $_isOwner",
        );

        debugPrint(
          "Members: ${_members.length}",
        );

        debugPrint(
          "Can Control Devices: "
              "$canControlDevices",
        );

        debugPrint(
          "Can Control Pump: "
              "$canControlPump",
        );

        debugPrint(
          "Can Manage Devices: "
              "$canManageDevices",
        );

        debugPrint(
          "Can Manage Members: "
              "$canManageMembers",
        );

        debugPrint(
          "=================================",
        );
      } else {
        _errorMessage =
            response["message"]?.toString() ??
                "Failed to load members";
      }
    } catch (e) {
      debugPrint(
        "LOAD MEMBERS ERROR: $e",
      );

      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );
    }

    _isLoading = false;

    notifyListeners();
  }

  // =====================================================
  // ADD / INVITE MEMBER
  // =====================================================

  Future<bool> addMember({
    required String email,
    bool controlDevices = true,
    bool controlPump = false,
    bool manageDevices = false,
    bool manageMembers = false,
  }) async {
    _errorMessage = null;

    notifyListeners();

    try {
      final response =
      await ApiService.addMember(
        email: email,
        controlDevices: controlDevices,
        controlPump: controlPump,
        manageDevices: manageDevices,
        manageMembers: manageMembers,
      );

      if (response["success"] == true) {
        await loadMembers();

        return true;
      }

      _errorMessage =
          response["message"]?.toString() ??
              "Failed to invite member";

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint(
        "ADD MEMBER ERROR: $e",
      );

      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );

      notifyListeners();

      return false;
    }
  }

  // =====================================================
  // GET MY INVITATIONS
  // =====================================================

  Future<void> loadMyInvitations() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final response =
      await ApiService.getMyInvitations();

      if (response["success"] == true) {
        final data =
        response["invitations"];

        if (data is List) {
          _invitations =
          List<dynamic>.from(data);
        } else {
          _invitations = [];
        }

        debugPrint(
          "PENDING INVITATIONS: "
              "${_invitations.length}",
        );
      } else {
        _invitations = [];

        _errorMessage =
            response["message"]?.toString() ??
                "Failed to load invitations";
      }
    } catch (e) {
      debugPrint(
        "LOAD INVITATIONS ERROR: $e",
      );

      _invitations = [];

      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );
    }

    _isLoading = false;

    notifyListeners();
  }

  // =====================================================
  // LOAD INVITATIONS
  // =====================================================

  Future<void> loadInvitations() async {
    await loadMyInvitations();
  }

  // =====================================================
  // GET MY INVITATIONS
  // =====================================================

  Future<List<dynamic>> getMyInvitations() async {
    await loadMyInvitations();

    return _invitations;
  }

  // =====================================================
  // ACCEPT INVITATION
  // =====================================================

  Future<bool> acceptInvitation(
      String memberId,
      ) async {
    _errorMessage = null;

    notifyListeners();

    try {
      final response =
      await ApiService.acceptInvitation(
        memberId,
      );

      if (response["success"] == true) {
        // -------------------------------------------------
        // Remove accepted invitation
        // -------------------------------------------------

        _invitations.removeWhere(
              (invitation) {
            final id =
                invitation["_id"]?.toString() ??
                    invitation["id"]?.toString();

            return id == memberId;
          },
        );

        // -------------------------------------------------
        // Store Smart Home returned by backend
        // -------------------------------------------------

        final smartHomeData =
        response["smartHome"];

        if (smartHomeData is Map) {
          _smartHome =
          Map<String, dynamic>.from(
            smartHomeData,
          );

          _isOwner = false;

          // -------------------------------------------------
          // Store member permissions
          // -------------------------------------------------

          final memberData =
          response["member"];

          if (memberData is Map) {
            _currentUserPermissions = {
              "canControlDevices":
              memberData[
              "canControlDevices"] ==
                  true,

              "canControlPump":
              memberData[
              "canControlPump"] ==
                  true,

              "canManageDevices":
              memberData[
              "canManageDevices"] ==
                  true,

              "canManageMembers":
              memberData[
              "canManageMembers"] ==
                  true,
            };
          }
        }

        notifyListeners();

        return true;
      }

      _errorMessage =
          response["message"]?.toString() ??
              "Failed to accept invitation";

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint(
        "ACCEPT INVITATION ERROR: $e",
      );

      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );

      notifyListeners();

      return false;
    }
  }

  // =====================================================
  // REJECT INVITATION
  // =====================================================

  Future<bool> rejectInvitation(
      String memberId,
      ) async {
    _errorMessage = null;

    notifyListeners();

    try {
      final response =
      await ApiService.rejectInvitation(
        memberId,
      );

      if (response["success"] == true) {
        _invitations.removeWhere(
              (invitation) {
            final id =
                invitation["_id"]?.toString() ??
                    invitation["id"]?.toString();

            return id == memberId;
          },
        );

        notifyListeners();

        return true;
      }

      _errorMessage =
          response["message"]?.toString() ??
              "Failed to reject invitation";

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint(
        "REJECT INVITATION ERROR: $e",
      );

      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );

      notifyListeners();

      return false;
    }
  }

  // =====================================================
  // REMOVE MEMBER
  // =====================================================

  Future<bool> removeMember(
      String memberId,
      ) async {
    _errorMessage = null;

    notifyListeners();

    try {
      final response =
      await ApiService.removeMember(
        memberId,
      );

      if (response["success"] == true) {
        _members.removeWhere(
              (member) {
            final id =
                member["_id"]?.toString() ??
                    member["id"]?.toString();

            final userId =
                member["user"]?["_id"]?.toString() ??
                    member["user"]?["id"]?.toString();

            return id == memberId ||
                userId == memberId;
          },
        );

        notifyListeners();

        return true;
      }

      _errorMessage =
          response["message"]?.toString() ??
              "Failed to remove member";

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint(
        "REMOVE MEMBER ERROR: $e",
      );

      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );

      notifyListeners();

      return false;
    }
  }

  // =====================================================
  // UPDATE MEMBER PERMISSIONS
  // =====================================================

  Future<bool> updateMemberPermissions({
    required String memberId,
    bool? controlDevices,
    bool? controlPump,
    bool? manageDevices,
    bool? manageMembers,
  }) async {
    _errorMessage = null;

    notifyListeners();

    try {
      final response =
      await ApiService.updateMemberPermissions(
        memberId: memberId,
        controlDevices: controlDevices,
        controlPump: controlPump,
        manageDevices: manageDevices,
        manageMembers: manageMembers,
      );

      if (response["success"] == true) {
        await loadMembers();

        return true;
      }

      _errorMessage =
          response["message"]?.toString() ??
              "Failed to update permissions";

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint(
        "UPDATE MEMBER PERMISSIONS ERROR: $e",
      );

      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );

      notifyListeners();

      return false;
    }
  }

  // =====================================================
  // LEAVE SMART HOME
  // =====================================================

  Future<bool> leaveSmartHome() async {
    _errorMessage = null;

    notifyListeners();

    try {
      final response =
      await ApiService.leaveSmartHome();

      if (response["success"] == true) {
        _members = [];

        _smartHome = null;

        _owner = null;

        _currentUserPermissions = null;

        _isOwner = false;

        notifyListeners();

        return true;
      }

      _errorMessage =
          response["message"]?.toString() ??
              "Failed to leave Smart Home";

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint(
        "LEAVE SMART HOME ERROR: $e",
      );

      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );

      notifyListeners();

      return false;
    }
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  // =====================================================
  // CLEAR MEMBERS
  // =====================================================

  void clearMembers() {
    _members = [];

    notifyListeners();
  }

  // =====================================================
  // CLEAR INVITATIONS
  // =====================================================

  void clearInvitations() {
    _invitations = [];

    notifyListeners();
  }

  // =====================================================
  // CLEAR SMART HOME
  // =====================================================

  void clearSmartHome() {
    _smartHome = null;

    _owner = null;

    _currentUserPermissions = null;

    _isOwner = false;

    notifyListeners();
  }

  // =====================================================
  // CLEAR EVERYTHING
  // =====================================================

  void clearAll() {
    _members = [];

    _invitations = [];

    _smartHome = null;

    _owner = null;

    _currentUserPermissions = null;

    _isOwner = false;

    _errorMessage = null;

    _isLoading = false;

    notifyListeners();
  }
}