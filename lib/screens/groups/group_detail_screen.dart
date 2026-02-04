import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/groups_provider.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  Map<String, dynamic>? _group;
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<GroupsProvider>();
      final group = await provider.getGroupDetails(widget.groupId);
      final members = await provider.getGroupMembers(widget.groupId);

      if (mounted) {
        setState(() {
          _group = group;
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyInviteCode() {
    final code = _group?['invite_code'];
    if (code != null) {
      Clipboard.setData(ClipboardData(text: code));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code copié !')),
      );
    }
  }

  Future<void> _confirmLeave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le groupe'),
        content: const Text(
          'Es-tu sûr de vouloir quitter ce groupe ? Tu ne pourras plus voir les programmes partagés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<GroupsProvider>().leaveGroup(widget.groupId);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tu as quitté le groupe')),
          );
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_group == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Groupe non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_group!['name'] ?? 'Groupe'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'leave') {
                _confirmLeave();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Quitter le groupe'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGroupData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invite code card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.key,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Code d\'invitation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                _group!['invite_code'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _copyInviteCode,
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copier le code',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Partage ce code avec tes amis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description if exists
              if (_group!['description'] != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.description_outlined),
                            SizedBox(width: 8),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_group!['description']),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Members section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Membres (${_members.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_members.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('Aucun membre')),
                  ),
                )
              else
                ...List.generate(_members.length, (index) {
                  final member = _members[index];
                  final isCreator = member['id'] == _group!['created_by'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          (member['name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        member['name'] ?? 'Sans nom',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(member['email'] ?? ''),
                      trailing: isCreator
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            )
                          : null,
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Quick actions
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: const Text('Programmes d\'entraînement'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bientôt disponible')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.restaurant),
                      title: const Text('Plans de nutrition'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bientôt disponible')),
                        );
                      },
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
