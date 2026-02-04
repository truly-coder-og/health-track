class WorkoutProgram {
  final String id;
  final String groupId;
  final String createdBy;
  final String name;
  final String? description;
  final List<Exercise> exercises;
  final DateTime createdAt;

  WorkoutProgram({
    required this.id,
    required this.groupId,
    required this.createdBy,
    required this.name,
    this.description,
    required this.exercises,
    required this.createdAt,
  });

  factory WorkoutProgram.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutProgram(
      id: id,
      groupId: map['groupId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'createdBy': createdBy,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
    };
  }
}

class Exercise {
  final String name;
  final int sets;
  final int reps;
  final int restTimeSeconds;
  final String? notes;
  final String? videoUrl;
  final String? muscleGroup; // chest, back, legs, etc.

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.restTimeSeconds = 60,
    this.notes,
    this.videoUrl,
    this.muscleGroup,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? 10,
      restTimeSeconds: map['restTimeSeconds'] ?? 60,
      notes: map['notes'],
      videoUrl: map['videoUrl'],
      muscleGroup: map['muscleGroup'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'restTimeSeconds': restTimeSeconds,
      'notes': notes,
      'videoUrl': videoUrl,
      'muscleGroup': muscleGroup,
    };
  }
}

// Log d'une session d'entraînement (copie personnalisée du programme)
class WorkoutLog {
  final String id;
  final String userId;
  final String? programId; // null si workout custom
  final String programName;
  final DateTime date;
  final List<ExerciseLog> exercises;
  final int durationMinutes;
  final String? notes;

  WorkoutLog({
    required this.id,
    required this.userId,
    this.programId,
    required this.programName,
    required this.date,
    required this.exercises,
    this.durationMinutes = 0,
    this.notes,
  });

  factory WorkoutLog.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutLog(
      id: id,
      userId: map['userId'] ?? '',
      programId: map['programId'],
      programName: map['programName'] ?? '',
      date: map['date']?.toDate() ?? DateTime.now(),
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseLog.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      durationMinutes: map['durationMinutes'] ?? 0,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'programId': programId,
      'programName': programName,
      'date': date,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'durationMinutes': durationMinutes,
      'notes': notes,
    };
  }
}

class ExerciseLog {
  final String name;
  final int targetSets;
  final int targetReps;
  final List<SetLog> setsCompleted;
  final bool completed;
  final String? notes;

  ExerciseLog({
    required this.name,
    required this.targetSets,
    required this.targetReps,
    required this.setsCompleted,
    this.completed = false,
    this.notes,
  });

  factory ExerciseLog.fromMap(Map<String, dynamic> map) {
    return ExerciseLog(
      name: map['name'] ?? '',
      targetSets: map['targetSets'] ?? 3,
      targetReps: map['targetReps'] ?? 10,
      setsCompleted: (map['setsCompleted'] as List<dynamic>?)
              ?.map((s) => SetLog.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      completed: map['completed'] ?? false,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'setsCompleted': setsCompleted.map((s) => s.toMap()).toList(),
      'completed': completed,
      'notes': notes,
    };
  }
}

class SetLog {
  final int reps;
  final double? weight; // kg, optionnel

  SetLog({
    required this.reps,
    this.weight,
  });

  factory SetLog.fromMap(Map<String, dynamic> map) {
    return SetLog(
      reps: map['reps'] ?? 0,
      weight: map['weight']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }
}
