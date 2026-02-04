import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/groups_provider.dart';
import '../../providers/workouts_provider.dart';
import 'create_program_screen.dart';
import 'program_detail_screen.dart';

class ProgramsListScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ProgramsListScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<ProgramsListScreen> createState() => _ProgramsListScreenState();
}

class _ProgramsListScreenState extends State<ProgramsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrograms();
    });
  }

  Future<void> _loadPrograms() async {
    await context.read<WorkoutsProvider>().loadGroupPrograms(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        subtitle: const Text('Programmes d\'entraînement'),
      ),
      body: Consumer<WorkoutsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.groupPrograms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Erreur: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPrograms,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.groupPrograms.isEmpty) {
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
                    'Aucun programme',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crée le premier programme du groupe',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateProgramScreen(
                            groupId: widget.groupId,
                          ),
                        ),
                      ).then((_) => _loadPrograms());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un programme'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadPrograms,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.groupPrograms.length,
              itemBuilder: (context, index) {
                final program = provider.groupPrograms[index];
                return _ProgramCard(
                  program: program,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgramDetailScreen(
                          program: program,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateProgramScreen(groupId: widget.groupId),
            ),
          ).then((_) => _loadPrograms());
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau programme'),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.program,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = program['exercises'] as List? ?? [];
    final exerciseCount = exercises.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program['name'] ?? 'Sans nom',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$exerciseCount ${exerciseCount > 1 ? 'exercices' : 'exercice'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
              if (program['description'] != null && program['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  program['description'],
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
