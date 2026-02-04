import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nutrition_provider.dart';
import 'search_food_screen.dart';

class LogMealScreen extends StatefulWidget {
  final String mealType;

  const LogMealScreen({super.key, required this.mealType});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getMealTypeName() {
    switch (widget.mealType) {
      case 'breakfast':
        return 'Petit-déjeuner';
      case 'lunch':
        return 'Déjeuner';
      case 'dinner':
        return 'Dîner';
      case 'snack':
        return 'Snack';
      default:
        return 'Repas';
    }
  }

  IconData _getMealTypeIcon() {
    switch (widget.mealType) {
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) throw Exception('User not authenticated');

      await context.read<NutritionProvider>().logMeal(
            userId: userId,
            mealType: widget.mealType,
            name: _nameController.text.trim(),
            calories: int.parse(_caloriesController.text),
            protein: double.parse(_proteinController.text),
            carbs: double.parse(_carbsController.text),
            fat: double.parse(_fatController.text),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Repas enregistré !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _searchFood() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchFoodScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _nameController.text = result['name'] ?? '';
        _caloriesController.text = result['calories']?.toString() ?? '';
        _proteinController.text = result['protein']?.toStringAsFixed(1) ?? '';
        _carbsController.text = result['carbs']?.toStringAsFixed(1) ?? '';
        _fatController.text = result['fat']?.toStringAsFixed(1) ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getMealTypeName()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Rechercher un aliment',
            onPressed: _searchFood,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                _getMealTypeIcon(),
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 16),

              // Search button
              OutlinedButton.icon(
                onPressed: _searchFood,
                icon: const Icon(Icons.search),
                label: const Text('Rechercher dans Open Food Facts'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OU saisie manuelle'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              // Meal name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du repas',
                  hintText: 'Ex: Poulet-riz, Omelette...',
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Entre un nom';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Calories
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(
                  labelText: 'Calories',
                  hintText: '500',
                  prefixIcon: const Icon(Icons.local_fire_department),
                  suffixText: 'kcal',
                  filled: true,
                  fillColor: Colors.orange.shade50,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requis';
                  if (int.tryParse(value) == null) return 'Nombre invalide';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Macros header
              const Text(
                'Macronutriments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Protein
              TextFormField(
                controller: _proteinController,
                decoration: InputDecoration(
                  labelText: 'Protéines',
                  hintText: '30',
                  prefixIcon: Icon(Icons.fitness_center, color: Colors.blue.shade700),
                  suffixText: 'g',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requis';
                  if (double.tryParse(value) == null) return 'Nombre invalide';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Carbs
              TextFormField(
                controller: _carbsController,
                decoration: InputDecoration(
                  labelText: 'Glucides',
                  hintText: '50',
                  prefixIcon: Icon(Icons.eco, color: Colors.green.shade700),
                  suffixText: 'g',
                  filled: true,
                  fillColor: Colors.green.shade50,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requis';
                  if (double.tryParse(value) == null) return 'Nombre invalide';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Fat
              TextFormField(
                controller: _fatController,
                decoration: InputDecoration(
                  labelText: 'Lipides',
                  hintText: '15',
                  prefixIcon: Icon(Icons.opacity, color: Colors.purple.shade700),
                  suffixText: 'g',
                  filled: true,
                  fillColor: Colors.purple.shade50,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requis';
                  if (double.tryParse(value) == null) return 'Nombre invalide';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  hintText: 'Ex: Restaurant, fait maison...',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer le repas'),
              ),

              const SizedBox(height: 16),

              // Quick tip
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
                    Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Astuce : Les macros ne sont pas toujours disponibles. Dans ce cas, estime ou mets 0.',
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
      ),
    );
  }
}
