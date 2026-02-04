import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/groups_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'both';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final group = await context.read<GroupsProvider>().createGroup(
            name: _nameController.text.trim(),
            type: _selectedType,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          );

      if (!mounted) return;

      // Show success with invite code
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Groupe créé !'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ton groupe "${group['name']}" a été créé.'),
              const SizedBox(height: 16),
              const Text(
                'Code d\'invitation :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  group['invite_code'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Partage ce code avec tes amis pour qu\'ils rejoignent le groupe.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to groups list
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
        title: const Text('Créer un groupe'),
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
                Icons.groups,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 32),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du groupe',
                  hintText: 'Ex: Team Running, Gym Buddies...',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Entre un nom de groupe';
                  }
                  if (value.trim().length < 3) {
                    return 'Minimum 3 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  hintText: 'Ex: On s\'entraîne 3x par semaine...',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 24),

              // Type selector
              const Text(
                'Type de groupe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _TypeOption(
                value: 'both',
                groupValue: _selectedType,
                title: 'Sport + Nutrition',
                subtitle: 'Workouts et repas',
                icon: Icons.track_changes,
                color: Colors.purple,
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),

              const SizedBox(height: 8),

              _TypeOption(
                value: 'fitness',
                groupValue: _selectedType,
                title: 'Sport uniquement',
                subtitle: 'Workouts seulement',
                icon: Icons.fitness_center,
                color: Colors.blue,
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),

              const SizedBox(height: 8),

              _TypeOption(
                value: 'nutrition',
                groupValue: _selectedType,
                title: 'Nutrition uniquement',
                subtitle: 'Repas et calories',
                icon: Icons.restaurant,
                color: Colors.green,
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),

              const SizedBox(height: 32),

              // Create button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleCreate,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Créer le groupe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final ValueChanged<String?> onChanged;

  const _TypeOption({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
