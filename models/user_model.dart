class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profilePicture;
  final UserStats? stats;
  final UserGoals? goals;
  final List<String> groupIds;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profilePicture,
    this.stats,
    this.goals,
    this.groupIds = const [],
    required this.createdAt,
  });

  // Firestore → Model
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePicture: map['profilePicture'],
      stats: map['stats'] != null ? UserStats.fromMap(map['stats']) : null,
      goals: map['goals'] != null ? UserGoals.fromMap(map['goals']) : null,
      groupIds: List<String>.from(map['groupIds'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
      'stats': stats?.toMap(),
      'goals': goals?.toMap(),
      'groupIds': groupIds,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? name,
    String? profilePicture,
    UserStats? stats,
    UserGoals? goals,
    List<String>? groupIds,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      stats: stats ?? this.stats,
      goals: goals ?? this.goals,
      groupIds: groupIds ?? this.groupIds,
      createdAt: createdAt,
    );
  }
}

class UserStats {
  final double? weight; // kg
  final double? height; // cm
  final int? age;
  final String? gender; // male, female, other

  UserStats({
    this.weight,
    this.height,
    this.age,
    this.gender,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      weight: map['weight']?.toDouble(),
      height: map['height']?.toDouble(),
      age: map['age'],
      gender: map['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
    };
  }
}

class UserGoals {
  final String? primaryGoal; // lose_weight, gain_muscle, maintain, endurance
  final double? targetWeight;
  final int? weeklyWorkouts;

  UserGoals({
    this.primaryGoal,
    this.targetWeight,
    this.weeklyWorkouts,
  });

  factory UserGoals.fromMap(Map<String, dynamic> map) {
    return UserGoals(
      primaryGoal: map['primaryGoal'],
      targetWeight: map['targetWeight']?.toDouble(),
      weeklyWorkouts: map['weeklyWorkouts'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryGoal': primaryGoal,
      'targetWeight': targetWeight,
      'weeklyWorkouts': weeklyWorkouts,
    };
  }
}
