import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workouts_provider.dart';
import '../../database/local_database.dart';
import 'dart:convert';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
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
      await context.read<WorkoutsProvider>().loadMyLogs(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique Workouts'),
      ),
      body: Consumer<WorkoutsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myLogs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune session enregistrée',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group by date
          final logsByDate = <String, List<WorkoutLog>>{};
          for (var log in provider.myLogs) {
            final dateKey = DateFormat('yyyy-MM-dd').format(log.date);
            logsByDate.putIfAbsent(dateKey, () => []);
            logsByDate[dateKey]!.add(log);
          }

          final sortedDates = logsByDate.keys.toList()
            ..sort((a, b) => b.compareTo(a)); // Most recent first

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateKey = sortedDates[index];
                final logs = logsByDate[dateKey]!;
                final date = DateTime.parse(dateKey);

                return _DayCard(date: date, logs: logs);
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
  final List<WorkoutLog> logs;

  const _DayCard({
    required this.date,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    final totalDuration = logs.fold(0, (sum, log) => sum + log.duration);
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
              color: isToday ? Colors.blue.shade50 : Colors.grey.shade50,
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
                  color: isToday ? Colors.blue.shade700 : Colors.grey.shade700,
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
                          color: isToday ? Colors.blue.shade700 : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${logs.length} ${logs.length > 1 ? 'sessions' : 'session'}',
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
                      '$totalDuration',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const Text(
                      'min',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Workout logs
          ...logs.map((log) => _WorkoutLogTile(log: log)),
        ],
      ),
    );
  }
}

class _WorkoutLogTile extends StatelessWidget {
  final WorkoutLog log;

  const _WorkoutLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    List<dynamic> exercises = [];
    try {
      // Try to parse exercises JSON
      exercises = json.decode(log.exercises.replaceAll("'", '"'));
    } catch (e) {
      // Fallback
    }

    final exerciseCount = exercises.length;

    return ExpansionTile(
      leading: const Icon(Icons.fitness_center, color: Colors.blue),
      title: Text(
        log.programName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${log.duration} min • $exerciseCount exercices',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        DateFormat('HH:mm').format(log.date),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      children: [
        if (log.notes != null && log.notes!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log.notes!,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        if (exercises.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exercices :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ...exercises.map((ex) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ex['name'] ?? 'Exercice',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '${ex['completed_sets'] ?? 0}/${ex['target_sets'] ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
      ],
    );
  }
}
