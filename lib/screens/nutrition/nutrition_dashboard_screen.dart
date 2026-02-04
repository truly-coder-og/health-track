import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../database/local_database.dart';
import 'log_meal_screen.dart';
import 'nutrition_history_screen.dart';

class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({super.key});

  @override
  State<NutritionDashboardScreen> createState() => _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends State<NutritionDashboardScreen> {
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
      await context.read<NutritionProvider>().loadTodayMeals(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NutritionHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NutritionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.todayMeals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Date header
                Text(
                  DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now()),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                // Stats cards
                _StatsCard(stats: provider.todayStats),

                const SizedBox(height: 24),

                // Meals by type
                _MealTypeSection(
                  type: 'breakfast',
                  title: 'Petit-déjeuner',
                  icon: Icons.free_breakfast,
                  meals: provider.todayMeals
                      .where((m) => m.mealType == 'breakfast')
                      .toList(),
                  onAdd: () => _addMeal('breakfast'),
                ),

                const SizedBox(height: 16),

                _MealTypeSection(
                  type: 'lunch',
                  title: 'Déjeuner',
                  icon: Icons.lunch_dining,
                  meals: provider.todayMeals
                      .where((m) => m.mealType == 'lunch')
                      .toList(),
                  onAdd: () => _addMeal('lunch'),
                ),

                const SizedBox(height: 16),

                _MealTypeSection(
                  type: 'dinner',
                  title: 'Dîner',
                  icon: Icons.dinner_dining,
                  meals: provider.todayMeals
                      .where((m) => m.mealType == 'dinner')
                      .toList(),
                  onAdd: () => _addMeal('dinner'),
                ),

                const SizedBox(height: 16),

                _MealTypeSection(
                  type: 'snack',
                  title: 'Snacks',
                  icon: Icons.cookie,
                  meals: provider.todayMeals
                      .where((m) => m.mealType == 'snack')
                      .toList(),
                  onAdd: () => _addMeal('snack'),
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMeal('lunch'),
        icon: const Icon(Icons.add),
        label: const Text('Logger un repas'),
      ),
    );
  }

  void _addMeal(String mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogMealScreen(mealType: mealType),
      ),
    ).then((_) => _loadData());
  }
}

class _StatsCard extends StatelessWidget {
  final Map<String, double> stats;

  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Calories (big)
            Text(
              '${stats['calories']?.toInt() ?? 0}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
            ),
            const Text(
              'Calories',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Macros
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MacroChip(
                  label: 'Protéines',
                  value: stats['protein']?.toInt() ?? 0,
                  unit: 'g',
                  color: Colors.blue,
                ),
                _MacroChip(
                  label: 'Glucides',
                  value: stats['carbs']?.toInt() ?? 0,
                  unit: 'g',
                  color: Colors.green,
                ),
                _MacroChip(
                  label: 'Lipides',
                  value: stats['fat']?.toInt() ?? 0,
                  unit: 'g',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value$unit',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _MealTypeSection extends StatelessWidget {
  final String type;
  final String title;
  final IconData icon;
  final List<MealLog> meals;
  final VoidCallback onAdd;

  const _MealTypeSection({
    required this.type,
    required this.title,
    required this.icon,
    required this.meals,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (totalCalories > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalCalories cal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onAdd,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),

          if (meals.isNotEmpty) ...[
            const Divider(height: 1),
            ...meals.map((meal) => _MealTile(meal: meal)),
          ],

          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aucun repas logué',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final MealLog meal;

  const _MealTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(meal.name),
      subtitle: Text(
        'P: ${meal.protein.toInt()}g • C: ${meal.carbs.toInt()}g • L: ${meal.fat.toInt()}g',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${meal.calories}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'cal',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer ce repas ?'),
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
                  if (context.mounted) Navigator.pop(context);
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
