import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../providers/groups_provider.dart';
import '../../providers/workouts_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../groups/groups_list_screen.dart';
import '../nutrition/log_meal_screen.dart';
import '../nutrition/set_goals_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, int> _goals = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadGoals();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId;
    
    if (userId != null) {
      // Load all data in parallel
      await Future.wait([
        context.read<GroupsProvider>().loadMyGroups(),
        context.read<WorkoutsProvider>().loadMyLogs(userId),
        context.read<NutritionProvider>().loadTodayMeals(userId),
      ]);
    }
  }

  Future<void> _loadGoals() async {
    final goals = await GoalsHelper.getGoals();
    setState(() => _goals = goals);
  }

  void _openGoals() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SetGoalsScreen()),
    );
    if (result == true) {
      _loadGoals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final groupsProvider = context.watch<GroupsProvider>();
    final workoutsProvider = context.watch<WorkoutsProvider>();
    final nutritionProvider = context.watch<NutritionProvider>();

    // Calculate today's stats
    final todayWorkouts = workoutsProvider.myLogs
        .where((log) {
          final today = DateTime.now();
          return log.date.year == today.year &&
              log.date.month == today.month &&
              log.date.day == today.day;
        })
        .length;

    final todayCalories = nutritionProvider.todayStats['calories']?.toInt() ?? 0;
    final todayMeals = nutritionProvider.todayMeals.length;
    final myGroupsCount = groupsProvider.myGroups.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Objectifs',
            onPressed: _openGoals,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          (user?.userMetadata?['name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salut ${user?.userMetadata?['name'] ?? 'Athlète'} !',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Prêt pour aujourd'hui ?",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick stats
              Text(
                'Aujourd\'hui',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      label: 'Calories',
                      value: todayCalories.toString(),
                      color: Colors.orange,
                      onTap: () {
                        // Switch to nutrition tab (index 3)
                        DefaultTabController.of(context)?.animateTo(3);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.fitness_center,
                      label: 'Workouts',
                      value: todayWorkouts.toString(),
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.restaurant,
                      label: 'Repas',
                      value: todayMeals.toString(),
                      color: Colors.green,
                      onTap: () {
                        DefaultTabController.of(context)?.animateTo(3);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.groups,
                      label: 'Groupes',
                      value: myGroupsCount.toString(),
                      color: Colors.purple,
                      onTap: () {
                        DefaultTabController.of(context)?.animateTo(1);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Goals progress
              if (_goals.isNotEmpty && todayMeals > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Objectifs du jour',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: _openGoals,
                      child: const Text('Modifier'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _GoalProgress(
                          label: 'Calories',
                          current: todayCalories,
                          goal: _goals['calories'] ?? 2000,
                          color: Colors.orange,
                          unit: 'kcal',
                        ),
                        const SizedBox(height: 16),
                        _GoalProgress(
                          label: 'Protéines',
                          current: nutritionProvider.todayStats['protein']?.toInt() ?? 0,
                          goal: _goals['protein'] ?? 150,
                          color: Colors.blue,
                          unit: 'g',
                        ),
                        const SizedBox(height: 16),
                        _GoalProgress(
                          label: 'Glucides',
                          current: nutritionProvider.todayStats['carbs']?.toInt() ?? 0,
                          goal: _goals['carbs'] ?? 200,
                          color: Colors.green,
                          unit: 'g',
                        ),
                        const SizedBox(height: 16),
                        _GoalProgress(
                          label: 'Lipides',
                          current: nutritionProvider.todayStats['fat']?.toInt() ?? 0,
                          goal: _goals['fat'] ?? 60,
                          color: Colors.purple,
                          unit: 'g',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quick actions
              Text(
                'Actions rapides',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              _ActionButton(
                icon: Icons.fitness_center,
                label: 'Démarrer un workout',
                subtitle: 'Accède à tes programmes',
                color: Colors.blue,
                onTap: () {
                  if (myGroupsCount == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rejoins ou crée un groupe d\'abord !'),
                      ),
                    );
                  } else {
                    DefaultTabController.of(context)?.animateTo(2);
                  }
                },
              ),

              const SizedBox(height: 8),

              _ActionButton(
                icon: Icons.restaurant_menu,
                label: 'Logger un repas',
                subtitle: 'Enregistre ce que tu manges',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LogMealScreen(mealType: 'lunch'),
                    ),
                  ).then((_) => _loadData());
                },
              ),

              const SizedBox(height: 8),

              _ActionButton(
                icon: Icons.groups,
                label: myGroupsCount == 0 ? 'Créer ton premier groupe' : 'Voir mes groupes',
                subtitle: myGroupsCount == 0
                    ? 'Entraîne-toi avec tes amis'
                    : '$myGroupsCount ${myGroupsCount > 1 ? 'groupes' : 'groupe'}',
                color: Colors.purple,
                onTap: () {
                  DefaultTabController.of(context)?.animateTo(1);
                },
              ),

              const SizedBox(height: 24),

              // Motivation card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Continue comme ça !',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            todayWorkouts > 0 || todayMeals > 0
                                ? 'Tu es sur la bonne voie 💪'
                                : 'Commence ta journée du bon pied',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroIndicator extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MacroIndicator({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value}g',
          style: TextStyle(
            fontSize: 24,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalProgress extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final Color color;
  final String unit;

  const _GoalProgress({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '$current / $goal $unit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
