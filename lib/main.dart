import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/artwork_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await SupabaseConfig.initialize();
    debugPrint('✅ Supabase initialized successfully!');
  } catch (e) {
    debugPrint('❌ Error initializing Supabase: $e');
    // App will still run, but Supabase features won't work
  }

  runApp(
    const ProviderScope(
      child: ArtCollectionApp(),
    ),
  );
}

class ArtCollectionApp extends ConsumerWidget {
  const ArtCollectionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Quản Lý Bộ Sưu Tập Nghệ Thuật',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user != null) {
            // User is logged in - show artwork list screen
            return const ArtworkListScreen();
          } else {
            // User is not logged in - show login screen
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => const LoginScreen(),
      ),
    );
  }
}
