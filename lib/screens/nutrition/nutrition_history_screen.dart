import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../database/local_database.dart';

class NutritionHistoryScreen extends StatefulWidget {
  const NutritionHistoryScreen({super.key});

  @override
  State<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends State<NutritionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId != null) {
      await context.read<NutritionProvider>().loadRecentMeals(userId, days: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique nutrition'),
      ),
      body: Consumer<NutritionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.recentMeals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.recentMeals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun repas enregistré',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group meals by date
          final mealsByDate = <String, List<MealLog>>{};
          for (var meal in provider.recentMeals) {
            final dateKey = DateFormat('yyyy-MM-dd').format(meal.date);
            mealsByDate.putIfAbsent(dateKey, () => []);
            mealsByDate[dateKey]!.add(meal);
          }

          final sortedDates = mealsByDate.keys.toList()
            ..sort((a, b) => b.compareTo(a)); // Most recent first

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateKey = sortedDates[index];
                final meals = mealsByDate[dateKey]!;
                final date = DateTime.parse(dateKey);

                return _DayCard(
                  date: date,
                  meals: meals,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime date;
  final List<MealLog> meals;

  const _DayCard({
    required this.date,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);
    final totalProtein = meals.fold(0.0, (sum, meal) => sum + meal.protein);
    final totalCarbs = meals.fold(0.0, (sum, meal) => sum + meal.carbs);
    final totalFat = meals.fold(0.0, (sum, meal) => sum + meal.fat);

    final isToday = DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isToday ? Colors.orange.shade50 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: isToday ? Colors.orange.shade700 : Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday
                            ? "Aujourd'hui"
                            : DateFormat('EEEE d MMMM', 'fr_FR').format(date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.orange.shade700 : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${meals.length} ${meals.length > 1 ? 'repas' : 'repas'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalCalories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const Text(
                      'cal',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Macros summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MacroSummary(
                  label: 'P',
                  value: totalProtein.toInt(),
                  color: Colors.blue,
                ),
                _MacroSummary(
                  label: 'G',
                  value: totalCarbs.toInt(),
                  color: Colors.green,
                ),
                _MacroSummary(
                  label: 'L',
                  value: totalFat.toInt(),
                  color: Colors.purple,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Meals list
          ...meals.map((meal) => _MealListTile(meal: meal)),
        ],
      ),
    );
  }
}

class _MacroSummary extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MacroSummary({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value g',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _MealListTile extends StatelessWidget {
  final MealLog meal;

  const _MealListTile({required this.meal});

  IconData _getMealTypeIcon(String type) {
    switch (type) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getMealTypeIcon(meal.mealType)),
      title: Text(meal.name),
      subtitle: Text(
        'P: ${meal.protein.toInt()}g • G: ${meal.carbs.toInt()}g • L: ${meal.fat.toInt()}g',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        '${meal.calories} cal',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer ce repas ?'),
            content: Text('Supprimer "${meal.name}" ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  final userId = context.read<AuthProvider>().userId;
                  if (userId != null) {
                    await context
                        .read<NutritionProvider>()
                        .deleteMeal(meal.id, userId);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Repas supprimé')),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
      },
    );
  }
}
