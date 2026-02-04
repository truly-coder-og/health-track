import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../database/local_database.dart';

class WorkoutsProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  final LocalDatabase _localDb;

  List<Map<String, dynamic>> _groupPrograms = [];
  List<WorkoutLog> _myLogs = [];
  bool _isLoading = false;
  String? _error;

  WorkoutsProvider(this._localDb);

  List<Map<String, dynamic>> get groupPrograms => _groupPrograms;
  List<WorkoutLog> get myLogs => _myLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charger les programmes d'un groupe
  Future<void> loadGroupPrograms(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groupPrograms = await _supabase.getGroupWorkoutPrograms(groupId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer un programme
  Future<Map<String, dynamic>> createProgram({
    required String groupId,
    required String name,
    required String description,
    required List<Map<String, dynamic>> exercises,
  }) async {
    try {
      final program = await _supabase.createWorkoutProgram(
        groupId: groupId,
        name: name,
        description: description,
        exercises: exercises,
      );

      // Reload programs
      await loadGroupPrograms(groupId);

      return program;
    } catch (e) {
      rethrow;
    }
  }

  /// Charger mes logs locaux
  Future<void> loadMyLogs(String userId) async {
    try {
      _myLogs = await _localDb.getWorkoutLogs(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Logger une session (offline)
  Future<void> logWorkout({
    required String userId,
    String? programId,
    required String programName,
    required int duration,
    required List<Map<String, dynamic>> exercises,
    String? notes,
  }) async {
    try {
      await _localDb.addWorkoutLog(
        WorkoutLogsCompanion.insert(
          userId: userId,
          programId: Value(programId),
          programName: programName,
          date: DateTime.now(),
          duration: duration,
          exercises: _exercisesToJson(exercises),
          notes: Value(notes),
        ),
      );

      // Reload logs
      await loadMyLogs(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer un log
  Future<void> deleteLog(int logId, String userId) async {
    try {
      await _localDb.deleteWorkoutLog(logId);
      await loadMyLogs(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Helper: Convertir exercices en JSON string
  String _exercisesToJson(List<Map<String, dynamic>> exercises) {
    // Simple JSON encoding (in production, use dart:convert)
    return exercises.toString();
  }
}
