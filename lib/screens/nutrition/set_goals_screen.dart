import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetGoalsScreen extends StatefulWidget {
  const SetGoalsScreen({super.key});

  @override
  State<SetGoalsScreen> createState() => _SetGoalsScreenState();
}

class _SetGoalsScreenState extends State<SetGoalsScreen> {
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _workoutsController = TextEditingController();
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _workoutsController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _caloriesController.text = prefs.getInt('goal_calories')?.toString() ?? '2000';
      _proteinController.text = prefs.getInt('goal_protein')?.toString() ?? '150';
      _carbsController.text = prefs.getInt('goal_carbs')?.toString() ?? '200';
      _fatController.text = prefs.getInt('goal_fat')?.toString() ?? '60';
      _workoutsController.text = prefs.getInt('goal_workouts_week')?.toString() ?? '3';
      _isLoading = false;
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('goal_calories', int.tryParse(_caloriesController.text) ?? 2000);
    await prefs.setInt('goal_protein', int.tryParse(_proteinController.text) ?? 150);
    await prefs.setInt('goal_carbs', int.tryParse(_carbsController.text) ?? 200);
    await prefs.setInt('goal_fat', int.tryParse(_fatController.text) ?? 60);
    await prefs.setInt('goal_workouts_week', int.tryParse(_workoutsController.text) ?? 3);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Objectifs enregistrés !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes objectifs'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.flag,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 32),

            Text(
              'Objectifs nutritionnels quotidiens',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Calories
            TextField(
              controller: _caloriesController,
              decoration: InputDecoration(
                labelText: 'Calories',
                suffix Text: 'kcal',
                prefixIcon: const Icon(Icons.local_fire_department),
                filled: true,
                fillColor: Colors.orange.shade50,
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Protein
            TextField(
              controller: _proteinController,
              decoration: InputDecoration(
                labelText: 'Protéines',
                suffixText: 'g',
                prefixIcon: Icon(Icons.fitness_center, color: Colors.blue.shade700),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Carbs
            TextField(
              controller: _carbsController,
              decoration: InputDecoration(
                labelText: 'Glucides',
                suffixText: 'g',
                prefixIcon: Icon(Icons.eco, color: Colors.green.shade700),
                filled: true,
                fillColor: Colors.green.shade50,
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Fat
            TextField(
              controller: _fatController,
              decoration: InputDecoration(
                labelText: 'Lipides',
                suffixText: 'g',
                prefixIcon: Icon(Icons.opacity, color: Colors.purple.shade700),
                filled: true,
                fillColor: Colors.purple.shade50,
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 32),

            Text(
              'Objectifs sportifs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Workouts per week
            TextField(
              controller: _workoutsController,
              decoration: const InputDecoration(
                labelText: 'Workouts par semaine',
                suffixText: 'sessions',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _saveGoals,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
              ),
              child: const Text('Enregistrer mes objectifs'),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ces objectifs servent de référence pour suivre ta progression. Tu peux les modifier à tout moment.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to get goals
class GoalsHelper {
  static Future<Map<String, int>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'calories': prefs.getInt('goal_calories') ?? 2000,
      'protein': prefs.getInt('goal_protein') ?? 150,
      'carbs': prefs.getInt('goal_carbs') ?? 200,
      'fat': prefs.getInt('goal_fat') ?? 60,
      'workouts_week': prefs.getInt('goal_workouts_week') ?? 3,
    };
  }
}
