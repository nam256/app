import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth Repository Implementation - Data Layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User?> signUp(String email, String password) async {
    try {
      return await remoteDataSource.signUp(email, password);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      return await remoteDataSource.signIn(email, password);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  User? getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Stream<AuthState> get authStateChanges => remoteDataSource.authStateChanges;
}

