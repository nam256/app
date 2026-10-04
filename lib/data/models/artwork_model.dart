import '../../domain/entities/artwork.dart';

/// Artwork Model - Data Layer
/// Chuyển đổi giữa JSON (từ Supabase) và Entity
class ArtworkModel extends Artwork {
  ArtworkModel({
    required super.id,
    required super.userId,
    required super.title,
    super.artist,
    super.description,
    super.imageUrl,
    super.category,
    super.year,
    super.location,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Tạo ArtworkModel từ JSON (từ Supabase)
  factory ArtworkModel.fromJson(Map<String, dynamic> json) {
    return ArtworkModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      year: json['year'] != null ? json['year'] as int : null,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Chuyển ArtworkModel thành JSON (để gửi lên Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'artist': artist,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'year': year,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Tạo ArtworkModel từ Entity
  factory ArtworkModel.fromEntity(Artwork artwork) {
    return ArtworkModel(
      id: artwork.id,
      userId: artwork.userId,
      title: artwork.title,
      artist: artwork.artist,
      description: artwork.description,
      imageUrl: artwork.imageUrl,
      category: artwork.category,
      year: artwork.year,
      location: artwork.location,
      createdAt: artwork.createdAt,
      updatedAt: artwork.updatedAt,
    );
  }

  /// Chuyển ArtworkModel thành Entity
  Artwork toEntity() {
    return Artwork(
      id: id,
      userId: userId,
      title: title,
      artist: artist,
      description: description,
      imageUrl: imageUrl,
      category: category,
      year: year,
      location: location,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

