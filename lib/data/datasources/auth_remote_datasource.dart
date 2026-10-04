import '../../core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth Remote DataSource - Data Layer
/// Tương tác trực tiếp với Supabase Auth
abstract class AuthRemoteDataSource {
  Future<User?> signUp(String email, String password);
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
  Stream<AuthState> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase = SupabaseConfig.client;

  @override
  Future<User?> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      // Validate input
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }
      
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }
      
      return response.user;
    } on AuthException catch (e) {
      // Handle Supabase AuthException specifically
      String message;
      final statusCode = e.statusCode ?? '';
      final errorMsg = e.message.toLowerCase();
      
      if (statusCode == 'invalid_credentials' || 
          statusCode == '400' ||
          errorMsg.contains('invalid login credentials') ||
          errorMsg.contains('invalid_credentials')) {
        message = 'Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.';
      } else if (statusCode == 'email_not_confirmed' ||
                 errorMsg.contains('email not confirmed')) {
        message = 'Vui lòng xác nhận email trước khi đăng nhập.';
      } else if (errorMsg.contains('user not found')) {
        message = 'Tài khoản không tồn tại. Vui lòng đăng ký trước.';
      } else {
        message = 'Đăng nhập thất bại: ${e.message.isNotEmpty ? e.message : e.toString()}';
      }
      throw Exception(message);
    } catch (e) {
      // Handle other exceptions
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('invalid login credentials') || 
          errorMessage.contains('invalid_credentials')) {
        throw Exception('Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.');
      } else if (errorMessage.contains('email not confirmed') ||
                 errorMessage.contains('email_not_confirmed')) {
        throw Exception('Vui lòng xác nhận email trước khi đăng nhập.');
      } else if (errorMessage.contains('400') || errorMessage.contains('bad request')) {
        throw Exception('Yêu cầu không hợp lệ. Vui lòng kiểm tra email và mật khẩu.');
      } else if (errorMessage.contains('user not found')) {
        throw Exception('Tài khoản không tồn tại. Vui lòng đăng ký trước.');
      } else {
        throw Exception('Đăng nhập thất bại: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}

