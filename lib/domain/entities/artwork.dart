/// Artwork Entity - Domain Layer
/// Đây là business entity, không phụ thuộc vào framework hay database
class Artwork {
  final String id;
  final String userId;
  final String title;
  final String? artist;
  final String? description;
  final String? imageUrl;
  final String? category;
  final int? year;
  final String? location; // GPS location format: "lat,lng"
  final DateTime createdAt;
  final DateTime updatedAt;

  Artwork({
    required this.id,
    required this.userId,
    required this.title,
    this.artist,
    this.description,
    this.imageUrl,
    this.category,
    this.year,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Copy with method để tạo bản sao với một số fields thay đổi
  Artwork copyWith({
    String? id,
    String? userId,
    String? title,
    String? artist,
    String? description,
    String? imageUrl,
    String? category,
    int? year,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Artwork(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      year: year ?? this.year,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Artwork(id: $id, title: $title, artist: $artist)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Artwork && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

