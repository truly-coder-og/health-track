import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class GroupsProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  
  List<Map<String, dynamic>> _myGroups = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get myGroups => _myGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charger mes groupes
  Future<void> loadMyGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myGroups = await _supabase.getMyGroups();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer un groupe
  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String type,
    String? description,
  }) async {
    try {
      final group = await _supabase.createGroup(
        name: name,
        type: type,
        description: description,
      );
      
      // Reload groups
      await loadMyGroups();
      
      return group;
    } catch (e) {
      rethrow;
    }
  }

  /// Rejoindre un groupe via code
  Future<void> joinGroup(String inviteCode) async {
    try {
      await _supabase.joinGroupByCode(inviteCode);
      
      // Reload groups
      await loadMyGroups();
    } catch (e) {
      rethrow;
    }
  }

  /// Quitter un groupe
  Future<void> leaveGroup(String groupId) async {
    try {
      await _supabase.leaveGroup(groupId);
      
      // Reload groups
      await loadMyGroups();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer détails d'un groupe
  Future<Map<String, dynamic>?> getGroupDetails(String groupId) async {
    try {
      return await _supabase.getGroupDetails(groupId);
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer membres d'un groupe
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      return await _supabase.getGroupMembers(groupId);
    } catch (e) {
      rethrow;
    }
  }
}
