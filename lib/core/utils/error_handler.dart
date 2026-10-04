import 'dart:io';
import 'package:flutter/foundation.dart';

/// Utility class for handling and formatting errors
class ErrorHandler {
  /// Get user-friendly error message from exception
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return 'Đã xảy ra lỗi không xác định';
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (error is SocketException || errorString.contains('socket') || errorString.contains('network')) {
      return 'Không có kết nối mạng. Vui lòng kiểm tra kết nối internet.';
    }

    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Kết nối quá lâu. Vui lòng thử lại.';
    }

    if (errorString.contains('connection refused') || errorString.contains('failed host lookup')) {
      return 'Không thể kết nối đến server. Vui lòng thử lại sau.';
    }

    // Authentication errors
    if (errorString.contains('not authenticated') || 
        errorString.contains('unauthorized') ||
        errorString.contains('session expired')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }

    if (errorString.contains('invalid email') || errorString.contains('email')) {
      return 'Email không hợp lệ.';
    }

    if (errorString.contains('password') && errorString.contains('weak')) {
      return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
    }

    if (errorString.contains('email already registered') || errorString.contains('already exists')) {
      return 'Email này đã được đăng ký.';
    }

    // Supabase specific errors
    if (errorString.contains('row-level security') || errorString.contains('rls')) {
      return 'Bạn không có quyền thực hiện thao tác này.';
    }

    if (errorString.contains('foreign key') || errorString.contains('constraint')) {
      return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
    }

    // Storage errors
    if (errorString.contains('storage') || errorString.contains('bucket')) {
      return 'Lỗi khi tải ảnh lên. Vui lòng thử lại.';
    }

    if (errorString.contains('file not found') || errorString.contains('not found')) {
      return 'Không tìm thấy tệp.';
    }

    // Generic error messages
    if (errorString.contains('exception:')) {
      // Remove "Exception: " prefix
      final message = errorString.replaceFirst('exception:', '').trim();
      if (message.isNotEmpty) {
        return _capitalizeFirst(message);
      }
    }

    // Return original error if no match
    return _capitalizeFirst(errorString);
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;
    
    final errorString = error.toString().toLowerCase();
    return error is SocketException ||
        errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection refused') ||
        errorString.contains('failed host lookup');
  }

  /// Check if error is authentication-related
  static bool isAuthError(dynamic error) {
    if (error == null) return false;
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('not authenticated') ||
        errorString.contains('unauthorized') ||
        errorString.contains('session expired') ||
        errorString.contains('invalid credentials');
  }

  /// Capitalize first letter of string
  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Log error for debugging
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    debugPrint('❌ Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

