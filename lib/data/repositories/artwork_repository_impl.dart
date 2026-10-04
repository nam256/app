import '../../domain/entities/artwork.dart';
import '../../domain/repositories/artwork_repository.dart';
import '../datasources/artwork_remote_datasource.dart';
import '../models/artwork_model.dart';

/// Artwork Repository Implementation - Data Layer
/// Implement interface từ domain layer
class ArtworkRepositoryImpl implements ArtworkRepository {
  final ArtworkRemoteDataSource remoteDataSource;

  ArtworkRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Artwork>> getAllArtworks() async {
    try {
      final models = await remoteDataSource.getAllArtworks();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get artworks: $e');
    }
  }

  @override
  Future<Artwork?> getArtworkById(String id) async {
    try {
      final model = await remoteDataSource.getArtworkById(id);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to get artwork: $e');
    }
  }

  @override
  Future<Artwork> createArtwork(Artwork artwork) async {
    try {
      final model = ArtworkModel.fromEntity(artwork);
      final created = await remoteDataSource.createArtwork(model);
      return created.toEntity();
    } catch (e) {
      throw Exception('Failed to create artwork: $e');
    }
  }

  @override
  Future<Artwork> updateArtwork(Artwork artwork) async {
    try {
      final model = ArtworkModel.fromEntity(artwork);
      final updated = await remoteDataSource.updateArtwork(model);
      return updated.toEntity();
    } catch (e) {
      throw Exception('Failed to update artwork: $e');
    }
  }

  @override
  Future<void> deleteArtwork(String id) async {
    try {
      await remoteDataSource.deleteArtwork(id);
    } catch (e) {
      throw Exception('Failed to delete artwork: $e');
    }
  }
}

