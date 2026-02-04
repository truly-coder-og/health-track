import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_database.g.dart';

// ==================== TABLES ====================

/// Logs de sessions d'entraînement (offline)
class WorkoutLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get programId => text().nullable()(); // null si workout perso
  TextColumn get programName => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get duration => integer()(); // minutes
  TextColumn get exercises => text()(); // JSON array
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Logs de repas (offline)
class MealLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get mealType => text()(); // breakfast, lunch, dinner, snack
  TextColumn get name => text()();
  IntColumn get calories => integer()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Stats utilisateur (poids, mesures)
class UserStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weight => real().nullable()(); // kg
  RealColumn get bodyFat => real().nullable()(); // %
  IntColumn get steps => integer().nullable()();
  IntColumn get sleepHours => integer().nullable()(); // minutes
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ==================== DATABASE ====================

@DriftDatabase(tables: [WorkoutLogs, MealLogs, UserStats])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ==================== WORKOUT LOGS ====================

  /// Ajouter une session d'entraînement
  Future<int> addWorkoutLog(WorkoutLogsCompanion entry) {
    return into(workoutLogs).insert(entry);
  }

  /// Récupérer logs par user et date range
  Future<List<WorkoutLog>> getWorkoutLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final query = select(workoutLogs)..where((t) => t.userId.equals(userId));

    if (startDate != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.date.isSmallerOrEqualValue(endDate));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.get();
  }

  /// Supprimer un log
  Future<int> deleteWorkoutLog(int id) {
    return (delete(workoutLogs)..where((t) => t.id.equals(id))).go();
  }

  // ==================== MEAL LOGS ====================

  /// Ajouter un repas
  Future<int> addMealLog(MealLogsCompanion entry) {
    return into(mealLogs).insert(entry);
  }

  /// Récupérer logs par user et date
  Future<List<MealLog>> getMealLogs(
    String userId, {
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final query = select(mealLogs)..where((t) => t.userId.equals(userId));

    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query
        ..where((t) => t.date.isBiggerOrEqualValue(start))
        ..where((t) => t.date.isSmallerThanValue(end));
    } else {
      if (startDate != null) {
        query.where((t) => t.date.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        query.where((t) => t.date.isSmallerOrEqualValue(endDate));
      }
    }

    query.orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.get();
  }

  /// Stats nutrition pour une période
  Future<Map<String, double>> getNutritionStats(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final logs = await getMealLogs(
      userId,
      startDate: startDate,
      endDate: endDate,
    );

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var log in logs) {
      totalCalories += log.calories;
      totalProtein += log.protein;
      totalCarbs += log.carbs;
      totalFat += log.fat;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  /// Supprimer un log repas
  Future<int> deleteMealLog(int id) {
    return (delete(mealLogs)..where((t) => t.id.equals(id))).go();
  }

  // ==================== USER STATS ====================

  /// Ajouter des stats
  Future<int> addUserStats(UserStatsCompanion entry) {
    return into(userStats).insert(entry);
  }

  /// Récupérer stats par user et date range
  Future<List<UserStat>> getUserStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final query = select(userStats)..where((t) => t.userId.equals(userId));

    if (startDate != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.date.isSmallerOrEqualValue(endDate));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.get();
  }

  /// Dernière pesée
  Future<UserStat?> getLatestWeight(String userId) async {
    final query = select(userStats)
      ..where((t) => t.userId.equals(userId))
      ..where((t) => t.weight.isNotNull())
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(1);

    final results = await query.get();
    return results.isEmpty ? null : results.first;
  }

  /// Supprimer des stats
  Future<int> deleteUserStats(int id) {
    return (delete(userStats)..where((t) => t.id.equals(id))).go();
  }
}

// ==================== CONNECTION ====================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fitness_local.db'));
    return NativeDatabase(file);
  });
}
