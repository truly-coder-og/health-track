import 'package:supabase_flutter/supabase_flutter.dart';

/// Service centralisé pour toutes les interactions Supabase
class SupabaseService {
  // Singleton
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => currentUser?.id;

  // ==================== AUTH ====================

  /// Signup avec email/password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name}, // Stocké dans raw_user_meta_data
    );

    if (response.user == null) {
      throw Exception('Échec de création de compte');
    }

    return response;
  }

  /// Login avec email/password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Déconnexion
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Stream de l'état d'auth
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ==================== USER PROFILE ====================

  /// Récupérer profil user
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  /// Mettre à jour profil
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await client.from('users').update(data).eq('id', userId);
  }

  // ==================== GROUPS ====================

  /// Créer un groupe
  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String type,
    String? description,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Générer code d'invitation unique
    final inviteCode = _generateInviteCode();

    final groupData = {
      'name': name,
      'type': type,
      'description': description,
      'created_by': currentUserId,
      'invite_code': inviteCode,
    };

    // Créer groupe
    final group = await client
        .from('groups')
        .insert(groupData)
        .select()
        .single();

    // Auto-ajouter créateur comme membre
    await client.from('group_members').insert({
      'group_id': group['id'],
      'user_id': currentUserId,
    });

    return group;
  }

  /// Rejoindre groupe via code
  Future<Map<String, dynamic>> joinGroup(String inviteCode) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Trouver groupe avec ce code
    final group = await client
        .from('groups')
        .select()
        .eq('invite_code', inviteCode)
        .maybeSingle();

    if (group == null) {
      throw Exception('Code d\'invitation invalide');
    }

    // Vérifier si déjà membre
    final existing = await client
        .from('group_members')
        .select()
        .eq('group_id', group['id'])
        .eq('user_id', currentUserId!)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Vous êtes déjà membre de ce groupe');
    }

    // Ajouter comme membre
    await client.from('group_members').insert({
      'group_id': group['id'],
      'user_id': currentUserId,
    });

    return group;
  }

  /// Récupérer groupes de l'utilisateur
  Future<List<Map<String, dynamic>>> getUserGroups() async {
    if (currentUserId == null) return [];

    final response = await client
        .from('groups')
        .select('''
          *,
          group_members!inner(user_id)
        ''')
        .eq('group_members.user_id', currentUserId!);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Récupérer membres d'un groupe
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final response = await client
        .from('group_members')
        .select('''
          user_id,
          joined_at,
          users(id, name, email, profile_picture)
        ''')
        .eq('group_id', groupId);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Quitter groupe
  Future<void> leaveGroup(String groupId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await client
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', currentUserId!);
  }

  // ==================== WORKOUT PROGRAMS ====================

  /// Créer programme d'entraînement
  Future<Map<String, dynamic>> createWorkoutProgram({
    required String groupId,
    required String name,
    String? description,
    required List<Map<String, dynamic>> exercises,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final programData = {
      'group_id': groupId,
      'created_by': currentUserId,
      'name': name,
      'description': description,
      'exercises': exercises,
    };

    final program = await client
        .from('workout_programs')
        .insert(programData)
        .select()
        .single();

    return program;
  }

  /// Récupérer programmes d'un groupe
  Future<List<Map<String, dynamic>>> getGroupWorkoutPrograms(String groupId) async {
    final response = await client
        .from('workout_programs')
        .select('''
          *,
          users!created_by(name)
        ''')
        .eq('group_id', groupId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Supprimer programme (seulement créateur)
  Future<void> deleteWorkoutProgram(String programId) async {
    await client.from('workout_programs').delete().eq('id', programId);
  }

  // ==================== MEAL PLANS (optionnel) ====================

  /// Créer plan de repas
  Future<Map<String, dynamic>> createMealPlan({
    required String groupId,
    required String name,
    required DateTime date,
    required List<Map<String, dynamic>> meals,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final planData = {
      'group_id': groupId,
      'created_by': currentUserId,
      'name': name,
      'date': date.toIso8601String(),
      'meals': meals,
    };

    final plan = await client
        .from('meal_plans')
        .insert(planData)
        .select()
        .single();

    return plan;
  }

  /// Récupérer plans de repas d'un groupe
  Future<List<Map<String, dynamic>>> getGroupMealPlans(String groupId) async {
    final response = await client
        .from('meal_plans')
        .select()
        .eq('group_id', groupId)
        .order('date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==================== HELPERS ====================

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    return List.generate(
      6,
      (i) => chars[(random + i) % chars.length],
    ).join();
  }
}
