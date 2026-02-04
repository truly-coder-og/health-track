class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final List<String> members; // userIds
  final DateTime createdAt;
  final GroupType type;
  final String? description;
  final String inviteCode; // code unique pour rejoindre

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
    required this.createdAt,
    required this.type,
    this.description,
    required this.inviteCode,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map, String id) {
    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      type: GroupType.fromString(map['type'] ?? 'both'),
      description: map['description'],
      inviteCode: map['inviteCode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdBy': createdBy,
      'members': members,
      'createdAt': createdAt,
      'type': type.value,
      'description': description,
      'inviteCode': inviteCode,
    };
  }
}

enum GroupType {
  fitness('fitness'),
  nutrition('nutrition'),
  both('both');

  final String value;
  const GroupType(this.value);

  static GroupType fromString(String value) {
    return GroupType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GroupType.both,
    );
  }

  String get displayName {
    switch (this) {
      case GroupType.fitness:
        return 'Sport';
      case GroupType.nutrition:
        return 'Nutrition';
      case GroupType.both:
        return 'Sport & Nutrition';
    }
  }
}
