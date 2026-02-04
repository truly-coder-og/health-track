import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workouts_provider.dart';

class StartWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic> program;

  const StartWorkoutScreen({super.key, required this.program});

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  late List<ExerciseLog> _exerciseLogs;
  late Stopwatch _stopwatch;
  Timer? _timer;
  String _elapsedTime = '00:00';

  @override
  void initState() {
    super.initState();
    
    // Initialize exercise logs
    final exercises = widget.program['exercises'] as List? ?? [];
    _exerciseLogs = exercises.map((ex) => ExerciseLog.fromMap(ex)).toList();

    // Start timer
    _stopwatch = Stopwatch();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsedTime = _formatDuration(_stopwatch.elapsed);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _finishWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la session'),
        content: const Text('Es-tu sûr de vouloir terminer cette session ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final authProvider = context.read<AuthProvider>();
        final userId = authProvider.userId;

        if (userId == null) throw Exception('User not authenticated');

        await context.read<WorkoutsProvider>().logWorkout(
              userId: userId,
              programId: widget.program['id'],
              programName: widget.program['name'] ?? 'Workout',
              duration: _stopwatch.elapsed.inMinutes,
              exercises: _exerciseLogs.map((e) => e.toMap()).toList(),
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session enregistrée !'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program['name'] ?? 'Workout'),
        actions: [
          // Timer
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _elapsedTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _exerciseLogs.length,
        itemBuilder: (context, index) {
          return _ExerciseLogCard(
            exerciseLog: _exerciseLogs[index],
            index: index,
            onUpdate: () => setState(() {}),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _finishWorkout,
            icon: const Icon(Icons.check),
            label: const Text('Terminer la session'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseLogCard extends StatefulWidget {
  final ExerciseLog exerciseLog;
  final int index;
  final VoidCallback onUpdate;

  const _ExerciseLogCard({
    required this.exerciseLog,
    required this.index,
    required this.onUpdate,
  });

  @override
  State<_ExerciseLogCard> createState() => _ExerciseLogCardState();
}

class _ExerciseLogCardState extends State<_ExerciseLogCard> {
  @override
  Widget build(BuildContext context) {
    final ex = widget.exerciseLog;
    final completedSets = ex.completedSets.where((s) => s).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: completedSets == ex.targetSets
                        ? Colors.green.shade100
                        : Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: completedSets == ex.targetSets
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$completedSets / ${ex.targetSets} séries',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (completedSets == ex.targetSets)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),

            const SizedBox(height: 16),

            // Sets checkboxes
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(ex.targetSets, (setIndex) {
                final isCompleted = ex.completedSets[setIndex];
                return _SetCheckbox(
                  setNumber: setIndex + 1,
                  isCompleted: isCompleted,
                  targetReps: ex.targetReps,
                  onToggle: () {
                    setState(() {
                      ex.completedSets[setIndex] = !isCompleted;
                    });
                    widget.onUpdate();
                  },
                );
              }),
            ),

            if (ex.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ex.notes,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SetCheckbox extends StatelessWidget {
  final int setNumber;
  final bool isCompleted;
  final int targetReps;
  final VoidCallback onToggle;

  const _SetCheckbox({
    required this.setNumber,
    required this.isCompleted,
    required this.targetReps,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: isCompleted ? Colors.green.shade700 : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              'Série $setNumber',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isCompleted ? Colors.green.shade700 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($targetReps)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseLog {
  final String name;
  final int targetSets;
  final int targetReps;
  final int restTime;
  final String notes;
  final List<bool> completedSets;

  ExerciseLog({
    required this.name,
    required this.targetSets,
    required this.targetReps,
    required this.restTime,
    required this.notes,
  }) : completedSets = List.filled(targetSets, false);

  factory ExerciseLog.fromMap(Map<String, dynamic> map) {
    return ExerciseLog(
      name: map['name'] ?? '',
      targetSets: map['sets'] ?? 3,
      targetReps: map['reps'] ?? 10,
      restTime: map['rest_time'] ?? 60,
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'target_sets': targetSets,
      'target_reps': targetReps,
      'completed_sets': completedSets.where((s) => s).length,
      'rest_time': restTime,
      'notes': notes,
    };
  }
}
