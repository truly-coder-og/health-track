import 'package:flutter/foundation.dart';
import '../database/local_database.dart';
import 'package:drift/drift.dart' as drift;

class NutritionProvider extends ChangeNotifier {
  final LocalDatabase _localDb;

  List<MealLog> _todayMeals = [];
  List<MealLog> _recentMeals = [];
  Map<String, double> _todayStats = {
    'calories': 0,
    'protein': 0,
    'carbs': 0,
    'fat': 0,
  };
  bool _isLoading = false;
  String? _error;

  NutritionProvider(this._localDb);

  List<MealLog> get todayMeals => _todayMeals;
  List<MealLog> get recentMeals => _recentMeals;
  Map<String, double> get todayStats => _todayStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charger les repas du jour
  Future<void> loadTodayMeals(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      _todayMeals = await _localDb.getMealLogs(userId, date: today);
      
      // Calculate today's stats
      _todayStats = {
        'calories': _todayMeals.fold(0.0, (sum, meal) => sum + meal.calories),
        'protein': _todayMeals.fold(0.0, (sum, meal) => sum + meal.protein),
        'carbs': _todayMeals.fold(0.0, (sum, meal) => sum + meal.carbs),
        'fat': _todayMeals.fold(0.0, (sum, meal) => sum + meal.fat),
      };
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger l'historique récent
  Future<void> loadRecentMeals(String userId, {int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      _recentMeals = await _localDb.getMealLogs(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Logger un repas
  Future<void> logMeal({
    required String userId,
    required String mealType,
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    String? notes,
  }) async {
    try {
      await _localDb.addMealLog(
        MealLogsCompanion.insert(
          userId: userId,
          date: DateTime.now(),
          mealType: mealType,
          name: name,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          notes: drift.Value(notes),
        ),
      );

      // Reload today's meals
      await loadTodayMeals(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer un repas
  Future<void> deleteMeal(int mealId, String userId) async {
    try {
      await _localDb.deleteMealLog(mealId);
      await loadTodayMeals(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtenir stats pour une période
  Future<Map<String, double>> getStats({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _localDb.getNutritionStats(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }
}
