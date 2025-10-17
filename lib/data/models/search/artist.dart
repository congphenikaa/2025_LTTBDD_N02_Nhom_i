

import 'package:app_nghenhac/domain/entities/search/artist.dart';

class ArtistModel {
  final String id;
  final String name;
  final String nameLowercase; // Thêm field này
  final String? bio;
  final String? imageUrl;
  final String? imageStoragePath; // Thêm field storage path
  final List<String>? genres;
  final int? followers;
  final bool isFollowed;

  ArtistModel({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    this.imageStoragePath,
    this.genres,
    this.followers,
    this.isFollowed = false,
  }) : nameLowercase = name.toLowerCase();

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'],
      imageUrl: json['image_url'],
      imageStoragePath: json['image_storage_path'],
      genres: json['genres'] != null 
          ? List<String>.from(json['genres'])
          : null,
      followers: json['followers'],
      isFollowed: json['is_followed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_lowercase': nameLowercase, // Thêm vào JSON
      'bio': bio,
      'image_url': imageUrl,
      'image_storage_path': imageStoragePath,
      'genres': genres,
      'followers': followers,
      'is_followed': isFollowed,
    };
  }

  ArtistModel copyWith({
    String? id,
    String? name,
    String? bio,
    String? imageUrl,
    String? imageStoragePath,
    List<String>? genres,
    int? followers,
    bool? isFollowed,
  }) {
    return ArtistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      imageStoragePath: imageStoragePath ?? this.imageStoragePath,
      genres: genres ?? this.genres,
      followers: followers ?? this.followers,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  ArtistEntity toEntity() {
    return ArtistEntity(
      id: id,
      name: name,
      bio: bio,
      imageUrl: imageUrl,
      imageStoragePath: imageStoragePath,
      genres: genres,
      followers: followers,
      isFollowed: isFollowed,
    );
  }
}