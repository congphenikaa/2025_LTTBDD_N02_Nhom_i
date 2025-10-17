import 'package:equatable/equatable.dart';
import '../../../domain/entities/search/album.dart';

class AlbumModel extends Equatable {
  final String id;
  final String title;
  final String? titleLowercase;
  final String artist;
  final String? artistLowercase;
  final String? artistId;
  final String? coverUrl;
  final String? coverStoragePath; // Thêm storage path
  final DateTime? releaseDate;
  final List<String>? genres;
  final int? trackCount;

  const AlbumModel({
    required this.id,
    required this.title,
    this.titleLowercase,
    required this.artist,
    this.artistLowercase,
    this.artistId,
    this.coverUrl,
    this.coverStoragePath,
    this.releaseDate,
    this.genres,
    this.trackCount,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleLowercase: json['title_lowercase'],
      artist: json['artist'] ?? '',
      artistLowercase: json['artist_lowercase'],
      artistId: json['artist_id'],
      coverUrl: json['cover_url'],
      coverStoragePath: json['cover_storage_path'],
      releaseDate: json['release_date'] != null
          ? (json['release_date'].runtimeType.toString().contains('Timestamp')
              ? (json['release_date'] as dynamic).toDate()
              : DateTime.tryParse(json['release_date'].toString()))
          : null,
      genres: json['genres'] != null 
          ? List<String>.from(json['genres'])
          : null,
      trackCount: _parseTrackCount(json['track_count']), // Safe parsing
    );
  }

  // Safe parsing for track_count
  static int? _parseTrackCount(dynamic trackCount) {
    if (trackCount == null) return null;
    if (trackCount is int) return trackCount;
    if (trackCount is String) {
      return int.tryParse(trackCount);
    }
    if (trackCount is double) return trackCount.round();
    return null;
  }

  AlbumModel copyWith({
    String? id,
    String? title,
    String? titleLowercase,
    String? artist,
    String? artistLowercase,
    String? artistId,
    String? coverUrl,
    String? coverStoragePath,
    DateTime? releaseDate,
    List<String>? genres,
    int? trackCount,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleLowercase: titleLowercase ?? this.titleLowercase,
      artist: artist ?? this.artist,
      artistLowercase: artistLowercase ?? this.artistLowercase,
      artistId: artistId ?? this.artistId,
      coverUrl: coverUrl ?? this.coverUrl,
      coverStoragePath: coverStoragePath ?? this.coverStoragePath,
      releaseDate: releaseDate ?? this.releaseDate,
      genres: genres ?? this.genres,
      trackCount: trackCount ?? this.trackCount,
    );
  }

  AlbumEntity toEntity() {
    return AlbumEntity(
      id: id,
      title: title,
      artist: artist,
      artistId: artistId,
      coverUrl: coverUrl,
      coverStoragePath: coverStoragePath,
      releaseDate: releaseDate,
      genres: genres,
      trackCount: trackCount,
    );
  }

  @override
  List<Object?> get props => [
    id, title, titleLowercase, artist, artistLowercase, 
    artistId, coverUrl, coverStoragePath, releaseDate, genres, trackCount
  ];
}