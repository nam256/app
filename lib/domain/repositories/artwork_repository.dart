import '../entities/artwork.dart';

/// Artwork Repository Interface - Domain Layer
/// Định nghĩa các operations mà domain layer cần
/// Implementation sẽ ở data layer
abstract class ArtworkRepository {
  /// Lấy tất cả artworks của user hiện tại
  Future<List<Artwork>> getAllArtworks();

  /// Lấy artwork theo ID
  Future<Artwork?> getArtworkById(String id);

  /// Tạo artwork mới
  Future<Artwork> createArtwork(Artwork artwork);

  /// Cập nhật artwork
  Future<Artwork> updateArtwork(Artwork artwork);

  /// Xóa artwork
  Future<void> deleteArtwork(String id);
}

