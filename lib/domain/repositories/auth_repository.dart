import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth Repository Interface - Domain Layer
abstract class AuthRepository {
  Future<User?> signUp(String email, String password);
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
  Stream<AuthState> get authStateChanges;
}

