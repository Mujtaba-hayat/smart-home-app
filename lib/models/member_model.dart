class MemberModel {
  final String id;
  final String userId;
  final String name;
  final String email;

  final bool controlDevices;
  final bool controlPump;
  final bool manageMembers;

  final DateTime? joinedAt;

  MemberModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.controlDevices,
    required this.controlPump,
    required this.manageMembers,
    this.joinedAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return MemberModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      userId: user is Map
          ? user['_id']?.toString() ??
          user['id']?.toString() ??
          ''
          : user?.toString() ?? '',

      name: user is Map
          ? user['name']?.toString() ?? 'Unknown User'
          : 'Unknown User',

      email: user is Map
          ? user['email']?.toString() ?? ''
          : '',

      controlDevices:
      json['controlDevices'] == true,

      controlPump:
      json['controlPump'] == true,

      manageMembers:
      json['manageMembers'] == true,

      joinedAt:
      json['joinedAt'] != null
          ? DateTime.tryParse(
        json['joinedAt'].toString(),
      )
          : null,
    );
  }
}