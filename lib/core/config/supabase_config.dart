import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static String? _supabaseUrl;
  static bool _isInitialized = false;

  // Hardcoded credentials for development (OK for learning project)
  // In production, use environment variables or secure storage
  static const String _defaultSupabaseUrl = 'https://ysqfilaqfrzhjhkdabtz.supabase.co';
  static const String _defaultSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzcWZpbGFxZnJ6aGpoa2RhYnR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzMTE5OTMsImV4cCI6MjA3ODg4Nzk5M30.BWr8gzf2QXTRX_n9u6rEAsWRCD7hPnGJn_sKp2n9JlU';

  static Future<void> initialize() async {
    String supabaseUrl = '';
    String supabaseAnonKey = '';

    // On web, use default credentials (no .env file support)
    if (kIsWeb) {
      supabaseUrl = _defaultSupabaseUrl;
      supabaseAnonKey = _defaultSupabaseAnonKey;
    } else {
      // On mobile/desktop, try to load from .env file
      try {
        await dotenv.load(fileName: '.env');
        supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
        supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      } catch (e) {
        debugPrint('⚠️ Could not load .env file: $e');
      }

      // Fallback to default values if .env is empty
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        debugPrint('ℹ️ Using default Supabase credentials');
        supabaseUrl = _defaultSupabaseUrl;
        supabaseAnonKey = _defaultSupabaseAnonKey;
      }
    }

    _supabaseUrl = supabaseUrl;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _isInitialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
  
  static bool get isConnected => _isInitialized && _supabaseUrl != null && _supabaseUrl!.isNotEmpty;
  
  static String get url => _supabaseUrl ?? 'Not configured';
}

