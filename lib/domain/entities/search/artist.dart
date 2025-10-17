class ArtistEntity {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;
  final String? imageStoragePath;
  final List<String>? genres;
  final int? followers;
  final bool isFollowed;

  ArtistEntity({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    this.imageStoragePath,
    this.genres,
    this.followers,
    this.isFollowed = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArtistEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}