import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/groups_provider.dart';
import 'create_group_screen.dart';
import 'join_group_screen.dart';
import 'group_detail_screen.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  @override
  void initState() {
    super.initState();
    // Load groups on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupsProvider>().loadMyGroups();
    });
  }

  Future<void> _refresh() async {
    await context.read<GroupsProvider>().loadMyGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes groupes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Rejoindre un groupe',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
              ).then((_) => _refresh());
            },
          ),
        ],
      ),
      body: Consumer<GroupsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myGroups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.myGroups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun groupe',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crée ou rejoins un groupe pour commencer',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateGroupScreen(),
                            ),
                          ).then((_) => _refresh());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Créer'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JoinGroupScreen(),
                            ),
                          ).then((_) => _refresh());
                        },
                        icon: const Icon(Icons.group_add),
                        label: const Text('Rejoindre'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myGroups.length,
              itemBuilder: (context, index) {
                final group = provider.myGroups[index];
                return _GroupCard(
                  group: group,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupDetailScreen(groupId: group['id']),
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
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          ).then((_) => _refresh());
        },
        icon: const Icon(Icons.add),
        label: const Text('Créer un groupe'),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onTap;

  const _GroupCard({
    required this.group,
    required this.onTap,
  });

  IconData _getGroupIcon(String type) {
    switch (type) {
      case 'fitness':
        return Icons.fitness_center;
      case 'nutrition':
        return Icons.restaurant;
      case 'both':
        return Icons.track_changes;
      default:
        return Icons.groups;
    }
  }

  Color _getGroupColor(String type) {
    switch (type) {
      case 'fitness':
        return Colors.blue;
      case 'nutrition':
        return Colors.green;
      case 'both':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = group['type'] ?? 'both';
    final memberCount = group['member_count'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getGroupColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getGroupIcon(type),
                  color: _getGroupColor(type),
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group['name'] ?? 'Sans nom',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (group['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        group['description'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$memberCount ${memberCount > 1 ? 'membres' : 'membre'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
