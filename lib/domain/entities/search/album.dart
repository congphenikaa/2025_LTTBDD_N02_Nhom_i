class AlbumEntity {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? coverUrl;
  final String? coverStoragePath;
  final DateTime? releaseDate;
  final int? trackCount;
  final List<String>? genres;
  final bool isFavorite;

  AlbumEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.coverUrl,
    this.coverStoragePath,
    this.releaseDate,
    this.trackCount,
    this.genres,
    this.isFavorite = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlbumEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}