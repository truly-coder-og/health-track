import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workouts_provider.dart';

class CreateProgramScreen extends StatefulWidget {
  final String groupId;

  const CreateProgramScreen({super.key, required this.groupId});

  @override
  State<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<ExerciseData> _exercises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start with one empty exercise
    _addExercise();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var ex in _exercises) {
      ex.dispose();
    }
    super.dispose();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(ExerciseData());
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises[index].dispose();
      _exercises.removeAt(index);
    });
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplis tous les champs requis')),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoute au moins un exercice')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final exercisesList = _exercises.map((ex) => ex.toMap()).toList();

      await context.read<WorkoutsProvider>().createProgram(
            groupId: widget.groupId,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            exercises: exercisesList,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Programme créé !'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un programme'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Program name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du programme',
                hintText: 'Ex: Full Body, Push Day...',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Entre un nom';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Ex: Programme complet 3x par semaine',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // Exercises header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercices (${_exercises.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Exercises list
            ..._exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;

              return _ExerciseCard(
                key: ValueKey(exercise),
                exercise: exercise,
                index: index,
                onRemove: _exercises.length > 1
                    ? () => _removeExercise(index)
                    : null,
              );
            }),

            const SizedBox(height: 24),

            // Create button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleCreate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Créer le programme'),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseData exercise;
  final int index;
  final VoidCallback? onRemove;

  const _ExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Exercice ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onRemove,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Exercise name
            TextFormField(
              controller: exercise.nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Ex: Squat, Bench Press...',
                isDense: true,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Entre le nom';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Sets and reps
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: exercise.setsController,
                    decoration: const InputDecoration(
                      labelText: 'Séries',
                      hintText: '3',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requis';
                      if (int.tryParse(value) == null) return 'Nombre';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: exercise.repsController,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      hintText: '10',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requis';
                      if (int.tryParse(value) == null) return 'Nombre';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: exercise.restController,
                    decoration: const InputDecoration(
                      labelText: 'Repos (s)',
                      hintText: '60',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Notes
            TextFormField(
              controller: exercise.notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                hintText: 'Ex: Tempo 3-1-1, form strict...',
                isDense: true,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseData {
  final nameController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();
  final restController = TextEditingController(text: '60');
  final notesController = TextEditingController();

  Map<String, dynamic> toMap() {
    return {
      'name': nameController.text.trim(),
      'sets': int.tryParse(setsController.text) ?? 0,
      'reps': int.tryParse(repsController.text) ?? 0,
      'rest_time': int.tryParse(restController.text) ?? 60,
      'notes': notesController.text.trim(),
    };
  }

  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    restController.dispose();
    notesController.dispose();
  }
}
