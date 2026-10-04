import 'package:flutter/foundation.dart';
import '../../core/config/supabase_config.dart';
import '../models/artwork_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Artwork Remote DataSource - Data Layer
/// Tương tác trực tiếp với Supabase
abstract class ArtworkRemoteDataSource {
  Future<List<ArtworkModel>> getAllArtworks();
  Future<ArtworkModel?> getArtworkById(String id);
  Future<ArtworkModel> createArtwork(ArtworkModel artwork);
  Future<ArtworkModel> updateArtwork(ArtworkModel artwork);
  Future<void> deleteArtwork(String id);
}

class ArtworkRemoteDataSourceImpl implements ArtworkRemoteDataSource {
  final SupabaseClient _supabase = SupabaseConfig.client;

  @override
  Future<List<ArtworkModel>> getAllArtworks() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Optimize query: only select needed fields
      final response = await _supabase
          .from('artworks')
          .select('id, user_id, title, artist, description, image_url, category, year, location, created_at, updated_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => ArtworkModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get artworks: $e');
    }
  }

  @override
  Future<ArtworkModel?> getArtworkById(String id) async {
    try {
      final response = await _supabase
          .from('artworks')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ArtworkModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Failed to get artwork: $e');
    }
  }

  @override
  Future<ArtworkModel> createArtwork(ArtworkModel artwork) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final data = artwork.toJson();
      // Remove id, created_at, updated_at (Supabase sẽ tự tạo)
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data['user_id'] = userId;

      final response = await _supabase
          .from('artworks')
          .insert(data)
          .select()
          .single();

      return ArtworkModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Failed to create artwork: $e');
    }
  }

  @override
  Future<ArtworkModel> updateArtwork(ArtworkModel artwork) async {
    try {
      final data = artwork.toJson();
      // Remove id, user_id, created_at (không được update)
      data.remove('id');
      data.remove('user_id');
      data.remove('created_at');
      data.remove('updated_at'); // Trigger sẽ tự update

      final response = await _supabase
          .from('artworks')
          .update(data)
          .eq('id', artwork.id)
          .select()
          .single();

      return ArtworkModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Failed to update artwork: $e');
    }
  }

  @override
  Future<void> deleteArtwork(String id) async {
    try {
      // First, get the artwork to get image URL
      final artwork = await getArtworkById(id);
      
      // Delete image from Storage if exists
      if (artwork != null && artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty) {
        try {
          // Extract file path from URL
          // URL format: https://xxx.supabase.co/storage/v1/object/public/artwork-images/userId/filename
          final imageUrl = artwork.imageUrl!;
          
          // Try to extract path from URL
          String? filePath;
          
          // Method 1: Parse from URL path
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          
          // Find 'artwork-images' in path
          final bucketIndex = pathSegments.indexOf('artwork-images');
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            // Get path after 'artwork-images': userId/filename
            filePath = pathSegments.sublist(bucketIndex + 1).join('/');
          } else {
            // Method 2: Extract from query or use full path
            // If URL contains 'artwork-images', try to extract manually
            final match = RegExp(r'artwork-images/(.+)$').firstMatch(imageUrl);
            if (match != null) {
              filePath = match.group(1);
            }
          }
          
          if (filePath != null && filePath.isNotEmpty) {
            // Delete from Storage
            await _supabase.storage
                .from('artwork-images')
                .remove([filePath]);
            debugPrint('✅ Deleted image from storage: $filePath');
          } else {
            debugPrint('⚠️ Could not extract file path from URL: $imageUrl');
          }
        } catch (e) {
          // Log error but don't fail - image might already be deleted or path incorrect
          debugPrint('⚠️ Failed to delete image from storage: $e');
        }
      }
      
      // Delete artwork record from database
      await _supabase.from('artworks').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete artwork: $e');
    }
  }
}

