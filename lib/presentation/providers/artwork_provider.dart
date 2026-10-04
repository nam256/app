import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/artwork_remote_datasource.dart';
import '../../data/repositories/artwork_repository_impl.dart';
import '../../data/models/artwork_model.dart';
import '../../domain/entities/artwork.dart';
import '../../domain/repositories/artwork_repository.dart';
import '../../core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Providers
final artworkRemoteDataSourceProvider = Provider<ArtworkRemoteDataSource>(
  (ref) => ArtworkRemoteDataSourceImpl(),
);

final artworkRepositoryProvider = Provider<ArtworkRepository>(
  (ref) => ArtworkRepositoryImpl(
    remoteDataSource: ref.watch(artworkRemoteDataSourceProvider),
  ),
);

// Artwork List Provider
final artworkListProvider = FutureProvider<List<Artwork>>((ref) async {
  final repository = ref.watch(artworkRepositoryProvider);
  return await repository.getAllArtworks();
});

// Artwork Provider (by ID)
final artworkProvider = FutureProvider.family<Artwork?, String>((ref, id) async {
  final repository = ref.watch(artworkRepositoryProvider);
  return await repository.getArtworkById(id);
});

// Artwork Notifier for CRUD operations with Real-time Sync
class ArtworkNotifier extends StateNotifier<AsyncValue<List<Artwork>>> {
  final ArtworkRepository _repository;
  RealtimeChannel? _realtimeChannel;
  StreamSubscription<PostgresChangePayload>? _subscription;

  ArtworkNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadArtworks();
    // Real-time subscription will be set up after artworks are loaded
  }

  Future<void> _loadArtworks() async {
    try {
      // Check authentication before loading
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        state = AsyncValue.error(
          Exception('User not authenticated. Please login again.'),
          StackTrace.current,
        );
        return;
      }

      final artworks = await _repository.getAllArtworks();
      state = AsyncValue.data(artworks);
      
      // Setup real-time subscription after loading artworks
      // This ensures subscription is set up with correct user context
      _setupRealtimeSubscription();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void _setupRealtimeSubscription() {
    // Clean up existing subscription first
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
    
    // Setup subscription asynchronously to avoid blocking
    Future.microtask(() async {
      try {
        final userId = SupabaseConfig.client.auth.currentUser?.id;
        if (userId == null) {
          debugPrint('⚠️ Cannot setup real-time: User not authenticated');
          return;
        }

        // Subscribe to real-time changes in artworks table
        _realtimeChannel = SupabaseConfig.client
            .channel('artworks_changes_${DateTime.now().millisecondsSinceEpoch}')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'artworks',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: userId,
              ),
              callback: (payload) {
                debugPrint('📡 Real-time event received: ${payload.eventType}');
                _handleRealtimeChange(payload);
              },
            )
            .subscribe((status, [error]) {
              if (status == RealtimeSubscribeStatus.subscribed) {
                debugPrint('✅ Real-time subscription SUBSCRIBED for user: $userId');
              } else if (status == RealtimeSubscribeStatus.timedOut) {
                debugPrint('⚠️ Real-time subscription TIMED OUT');
              } else if (status == RealtimeSubscribeStatus.channelError) {
                debugPrint('❌ Real-time subscription ERROR: $error');
              }
            });

        debugPrint('🔄 Real-time subscription setup initiated for user: $userId');
      } catch (e, stackTrace) {
        debugPrint('⚠️ Failed to setup real-time subscription: $e');
        debugPrint('Stack trace: $stackTrace');
        // Don't throw, just log - app can still work without real-time
      }
    });
  }

  void _handleRealtimeChange(PostgresChangePayload payload) {
    try {
      final currentData = state.value;
      if (currentData == null) {
        // If no data, reload
        _loadArtworks();
        return;
      }

      final List<Artwork> updatedList = List.from(currentData);

      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          // New artwork added
          final newArtwork = ArtworkModel.fromJson(
            Map<String, dynamic>.from(payload.newRecord),
          ).toEntity();
          updatedList.insert(0, newArtwork); // Add to top
          break;

        case PostgresChangeEvent.update:
          // Artwork updated
          final updatedArtwork = ArtworkModel.fromJson(
            Map<String, dynamic>.from(payload.newRecord),
          ).toEntity();
          final index = updatedList.indexWhere((a) => a.id == updatedArtwork.id);
          if (index != -1) {
            updatedList[index] = updatedArtwork;
          }
          break;

        case PostgresChangeEvent.delete:
          // Artwork deleted
          final deletedId = payload.oldRecord['id'] as String;
          updatedList.removeWhere((a) => a.id == deletedId);
          break;

        default:
          // For other events, reload
          _loadArtworks();
          return;
      }

      // Update state with new list
      state = AsyncValue.data(updatedList);
      debugPrint('✅ Real-time update applied: ${payload.eventType}');
    } catch (e) {
      debugPrint('⚠️ Error handling real-time change: $e');
      // On error, reload to ensure consistency
      _loadArtworks();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadArtworks();
  }

  Future<void> createArtwork(Artwork artwork) async {
    try {
      await _repository.createArtwork(artwork);
      // Real-time subscription will auto-update, no need to reload
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateArtwork(Artwork artwork) async {
    try {
      await _repository.updateArtwork(artwork);
      // Real-time subscription will auto-update, no need to reload
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteArtwork(String id) async {
    try {
      await _repository.deleteArtwork(id);
      
      // Force reload to ensure UI is updated (real-time might have delay)
      await _loadArtworks();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow; // Re-throw để UI có thể hiển thị error
    }
  }

  @override
  void dispose() {
    // Cleanup real-time subscription
    _subscription?.cancel();
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
    super.dispose();
  }
}

final artworkNotifierProvider = StateNotifierProvider<ArtworkNotifier, AsyncValue<List<Artwork>>>((ref) {
  final repository = ref.watch(artworkRepositoryProvider);
  return ArtworkNotifier(repository);
});

