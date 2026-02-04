import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  User? _currentUser;
  bool _isLoading = true;

  AuthProvider() {
    _init();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get userId => _currentUser?.id;

  void _init() {
    // Écouter les changements d'auth
    _supabase.authStateChanges.listen((AuthState state) {
      _currentUser = state.session?.user;
      _isLoading = false;
      notifyListeners();
    });

    // Check initial auth state
    _currentUser = _supabase.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  /// Sign up
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _supabase.signUp(
        email: email,
        password: password,
        name: name,
      );
      // User sera automatiquement mis à jour via le stream
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.signIn(email: email, password: password);
      // User sera automatiquement mis à jour via le stream
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }
}
