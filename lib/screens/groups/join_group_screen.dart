import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/groups_provider.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<GroupsProvider>().joinGroup(
            _codeController.text.trim().toUpperCase(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu as rejoint le groupe !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Erreur inconnue';
      if (e.toString().contains('not found')) {
        errorMessage = 'Code invalide ou groupe inexistant';
      } else if (e.toString().contains('already a member')) {
        errorMessage = 'Tu es déjà membre de ce groupe';
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
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
        title: const Text('Rejoindre un groupe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Icon
              Icon(
                Icons.group_add,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 32),

              // Instruction
              Text(
                'Entre le code d\'invitation',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Demande le code à l\'organisateur du groupe',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),

              const SizedBox(height: 32),

              // Code field
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code d\'invitation',
                  hintText: 'Ex: ABC123',
                  prefixIcon: Icon(Icons.key),
                ),
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleJoin(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Entre un code d\'invitation';
                  }
                  if (value.trim().length < 4) {
                    return 'Code trop court';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Join button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleJoin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Rejoindre'),
              ),

              const SizedBox(height: 24),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Une fois membre, tu pourras voir les programmes d\'entraînement partagés et les plans de nutrition du groupe.',
                        style: TextStyle(
                          fontSize: 13,
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
