import 'package:app_nghenhac/common/helpers/firebase_storage_service.dart';
import 'package:app_nghenhac/data/models/search/album.dart';
import 'package:app_nghenhac/data/models/search/artist.dart';
import 'package:app_nghenhac/data/models/search/playlist.dart';
import 'package:app_nghenhac/data/models/search/search_result.dart';
import 'package:app_nghenhac/data/models/search/song.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SearchFirebaseService {
  Future<SearchResultModel> search(String query);
  Future<List<String>> getSearchSuggestions(String query);
}

class SearchFirebaseServiceImpl extends SearchFirebaseService {
  final FirebaseFirestore _firestore;

  SearchFirebaseServiceImpl({required FirebaseFirestore firestore}) 
      : _firestore = firestore;

  @override
  Future<SearchResultModel> search(String query) async {
    try {
      final String searchQuery = query.toLowerCase().trim();
      
      // Parallel search across all collections
      final results = await Future.wait([
        _searchSongs(searchQuery),
        _searchArtists(searchQuery),
        _searchAlbums(searchQuery),
        _searchPlaylists(searchQuery),
      ]);

      final songs = results[0] as List<SongModel>;
      final artists = results[1] as List<ArtistModel>;
      final albums = results[2] as List<AlbumModel>;
      final playlists = results[3] as List<PlaylistModel>;

      return SearchResultModel(
        songs: songs,
        artists: artists,
        albums: albums,
        playlists: playlists,
        query: query,
        totalResults: songs.length + artists.length + albums.length + playlists.length,
      );
    } catch (e) {
      throw Exception('Failed to search: ${e.toString()}');
    }
  }

  Future<List<SongModel>> _searchSongs(String query) async {
    try {
      print('🎵 Searching songs with query: "$query"');
      
      // Search queries
      final titleQuery = await _firestore
          .collection('songs')
          .where('title_lowercase', isGreaterThanOrEqualTo: query)
          .where('title_lowercase', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();

      final artistQuery = await _firestore
          .collection('songs')
          .where('artist_lowercase', isGreaterThanOrEqualTo: query) 
          .where('artist_lowercase', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();

      // Process results
      final Set<String> seenIds = {};
      final List<SongModel> songsWithoutUrls = [];

      for (final doc in [...titleQuery.docs, ...artistQuery.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          try {
            final songData = {
              'id': doc.id,
              ...doc.data(),
            };
            
            songsWithoutUrls.add(SongModel.fromJson(songData));
          } catch (e) {
            print('❌ Error creating SongModel: $e');
          }
        }
      }

      // Load URLs for all songs
      final songsWithUrls = await _loadUrlsForSongs(songsWithoutUrls);
      
      print('🎵 Final songs count: ${songsWithUrls.length}');
      return songsWithUrls;
    } catch (e) {
      print('❌ Error searching songs: $e');
      return [];
    }
  }

  Future<List<SongModel>> _loadUrlsForSongs(List<SongModel> songs) async {
    if (songs.isEmpty) return songs;
    
    try {
      final storageService = sl<FirebaseStorageService>();
      
      // Collect all storage paths
      final List<String> allPaths = [];
      for (final song in songs) {
        if (song.coverStoragePath != null) allPaths.add(song.coverStoragePath!);
        if (song.audioStoragePath != null) allPaths.add(song.audioStoragePath!);
      }
      
      if (allPaths.isEmpty) return songs;
      
      print('📁 Loading ${allPaths.length} URLs...');
      
      // Get all URLs at once
      final urlMap = await storageService.getDownloadUrls(allPaths);
      
      // Update songs with URLs
      final List<SongModel> updatedSongs = [];
      for (final song in songs) {
        final newSong = song.copyWith(
          coverUrl: song.coverStoragePath != null 
              ? urlMap[song.coverStoragePath!] 
              : null,
          audioUrl: song.audioStoragePath != null 
              ? urlMap[song.audioStoragePath!] 
              : null,
        );
        
        print('🎵 Song: ${song.title}');
        print('🗂️ Storage path: ${song.coverStoragePath}');
        print('🔗 Loaded URL: ${newSong.coverUrl}');
        
        updatedSongs.add(newSong);
      }
      
      print('✅ URLs loaded successfully');
      return updatedSongs;
    } catch (e) {
      print('❌ Error loading URLs: $e');
      return songs; // Return without URLs if error
    }
  }

  Future<List<ArtistModel>> _searchArtists(String query) async {
    try {
      print('👤 Searching artists with query: "$query"');
      
      final querySnapshot = await _firestore
          .collection('artists')
          .where('name_lowercase', isGreaterThanOrEqualTo: query)
          .where('name_lowercase', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();

      final List<ArtistModel> artistsWithoutUrls = querySnapshot.docs.map((doc) => ArtistModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();

      // Load URLs for all artists
      final artistsWithUrls = await _loadUrlsForArtists(artistsWithoutUrls);
      
      print('👤 Final artists count: ${artistsWithUrls.length}');
      return artistsWithUrls;
    } catch (e) {
      print('❌ Error searching artists: ${e.toString()}');
      return [];
    }
  }

  Future<List<ArtistModel>> _loadUrlsForArtists(List<ArtistModel> artists) async {
    print('👤 _loadUrlsForArtists called with ${artists.length} artists');
    
    if (artists.isEmpty) {
      print('👤 No artists to load URLs for');
      return artists;
    }
    
    try {
      final storageService = sl<FirebaseStorageService>();
      
      // Collect all image storage paths
      final List<String> imagePaths = [];
      for (final artist in artists) {
        print('👤 Artist: ${artist.name}');
        print('👤 Image storage path: ${artist.imageStoragePath}');
        print('👤 Image URL: ${artist.imageUrl}');
        
        // Check if imageStoragePath has the storage path
        if (artist.imageStoragePath != null && artist.imageStoragePath!.isNotEmpty) {
          imagePaths.add(artist.imageStoragePath!);
        }
        // If imageStoragePath is null/empty, check if imageUrl contains a storage path (not a download URL)
        else if (artist.imageUrl != null && 
                 artist.imageUrl!.isNotEmpty && 
                 !artist.imageUrl!.startsWith('http') && 
                 !artist.imageUrl!.startsWith('https')) {
          print('👤 Using imageUrl as storage path: ${artist.imageUrl}');
          imagePaths.add(artist.imageUrl!);
        }
      }
      
      if (imagePaths.isEmpty) {
        print('👤 No image paths found for artists');
        return artists;
      }

      print('📁 Loading ${imagePaths.length} artist image URLs...');
      
      // Get all URLs at once
      final urlMap = await storageService.getDownloadUrls(imagePaths);
      
      print('📁 Artist URL map result: $urlMap');
      
      // Update artists with URLs
      final List<ArtistModel> updatedArtists = [];
      for (final artist in artists) {
        String? storagePath;
        
        // Determine which field contains the storage path
        if (artist.imageStoragePath != null && artist.imageStoragePath!.isNotEmpty) {
          storagePath = artist.imageStoragePath!;
        } else if (artist.imageUrl != null && 
                   artist.imageUrl!.isNotEmpty && 
                   !artist.imageUrl!.startsWith('http') && 
                   !artist.imageUrl!.startsWith('https')) {
          storagePath = artist.imageUrl!;
        }
        
        final updatedArtist = artist.copyWith(
          imageUrl: storagePath != null ? urlMap[storagePath] : null,
        );
        
        print('👤 Updated artist: ${artist.name}');
        print('👤 Original imageUrl: ${artist.imageUrl}');
        print('👤 New imageUrl: ${updatedArtist.imageUrl}');
        
        updatedArtists.add(updatedArtist);
      }
      
      print('✅ Artist image URLs loaded successfully');
      return updatedArtists;
    } catch (e) {
      print('❌ Error loading artist URLs: $e');
      return artists; // Return without URLs if error
    }
  }  Future<List<AlbumModel>> _searchAlbums(String query) async {
    try {
      print('💿 Searching albums with query: "$query"');
      
      // Search by album title
      final titleQuery = await _firestore
          .collection('albums')
          .where('title_lowercase', isGreaterThanOrEqualTo: query)
          .where('title_lowercase', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();

      // Search by artist name
      final artistQuery = await _firestore
          .collection('albums')
          .where('artist_lowercase', isGreaterThanOrEqualTo: query)
          .where('artist_lowercase', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();

      // Combine and remove duplicates
      final Set<String> seenIds = {};
      final List<AlbumModel> albumsWithoutUrls = [];

      for (final doc in [...titleQuery.docs, ...artistQuery.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          try {
            final albumData = {
              'id': doc.id,
              ...doc.data(),
            };
            albumsWithoutUrls.add(AlbumModel.fromJson(albumData));
            print('✅ Successfully created AlbumModel for: ${albumData['title']}');
          } catch (e) {
            print('❌ Error creating AlbumModel: $e');
            print('❌ Raw album data: ${doc.data()}');
            // Continue với albums khác thay vì crash
          }
        }
      }

      // Load URLs for all albums
      final albumsWithUrls = await _loadUrlsForAlbums(albumsWithoutUrls);

      print('💿 Final albums count: ${albumsWithUrls.length}');
      return albumsWithUrls;
    } catch (e) {
      print('❌ Error searching albums: $e');
      return [];
    }
  }

  Future<List<AlbumModel>> _loadUrlsForAlbums(List<AlbumModel> albums) async {
    print('💿 _loadUrlsForAlbums called with ${albums.length} albums');
    
    if (albums.isEmpty) {
      print('💿 No albums to load URLs for');
      return albums;
    }
    
    try {
      final storageService = sl<FirebaseStorageService>();
      
      // Collect all cover storage paths
      final List<String> coverPaths = [];
      for (final album in albums) {
        print('💿 Album: ${album.title}');
        print('💿 Cover storage path: ${album.coverStoragePath}');
        print('💿 Cover URL: ${album.coverUrl}');
        
        // Check if coverStoragePath has the storage path
        if (album.coverStoragePath != null && album.coverStoragePath!.isNotEmpty) {
          coverPaths.add(album.coverStoragePath!);
        }
        // If coverStoragePath is null/empty, check if coverUrl contains a storage path (not a download URL)
        else if (album.coverUrl != null && 
                 album.coverUrl!.isNotEmpty && 
                 !album.coverUrl!.startsWith('http') && 
                 !album.coverUrl!.startsWith('https')) {
          print('💿 Using coverUrl as storage path: ${album.coverUrl}');
          coverPaths.add(album.coverUrl!);
        }
      }
      
      if (coverPaths.isEmpty) {
        print('💿 No cover paths found for albums');
        return albums;
      }
      
      print('📁 Loading ${coverPaths.length} album cover URLs...');
      
      // Get all URLs at once
      final urlMap = await storageService.getDownloadUrls(coverPaths);
      
      print('📁 Album URL map result: $urlMap');
      
      // Update albums with URLs
      final List<AlbumModel> updatedAlbums = [];
      for (final album in albums) {
        String? storagePath;
        
        // Determine which field contains the storage path
        if (album.coverStoragePath != null && album.coverStoragePath!.isNotEmpty) {
          storagePath = album.coverStoragePath!;
        } else if (album.coverUrl != null && 
                   album.coverUrl!.isNotEmpty && 
                   !album.coverUrl!.startsWith('http') && 
                   !album.coverUrl!.startsWith('https')) {
          storagePath = album.coverUrl!;
        }
        
        final updatedAlbum = album.copyWith(
          coverUrl: storagePath != null ? urlMap[storagePath] : null,
        );
        
        print('💿 Updated album: ${album.title}');
        print('💿 Original coverUrl: ${album.coverUrl}');
        print('💿 New coverUrl: ${updatedAlbum.coverUrl}');
        
        updatedAlbums.add(updatedAlbum);
      }
      
      print('✅ Album cover URLs loaded successfully');
      return updatedAlbums;
    } catch (e) {
      print('❌ Error loading album URLs: $e');
      return albums; // Return without URLs if error
    }
  }

  Future<List<PlaylistModel>> _loadUrlsForPlaylists(List<PlaylistModel> playlists) async {
    print('🎵 _loadUrlsForPlaylists called with ${playlists.length} playlists');
    
    if (playlists.isEmpty) {
      print('🎵 No playlists to load URLs for');
      return playlists;
    }
    
    try {
      final storageService = sl<FirebaseStorageService>();
      
      // Collect all cover storage paths
      final List<String> coverPaths = [];
      for (final playlist in playlists) {
        print('🎵 Playlist: ${playlist.name}');
        print('🎵 Cover storage path: ${playlist.coverStoragePath}');
        print('🎵 Cover URL: ${playlist.coverUrl}');
        
        // Check if coverStoragePath has the storage path
        if (playlist.coverStoragePath != null && playlist.coverStoragePath!.isNotEmpty) {
          coverPaths.add(playlist.coverStoragePath!);
        }
        // If coverStoragePath is null/empty, check if coverUrl contains a storage path (not a download URL)
        else if (playlist.coverUrl != null && 
                 playlist.coverUrl!.isNotEmpty && 
                 !playlist.coverUrl!.startsWith('http') && 
                 !playlist.coverUrl!.startsWith('https')) {
          print('🎵 Using coverUrl as storage path: ${playlist.coverUrl}');
          coverPaths.add(playlist.coverUrl!);
        }
      }
      
      if (coverPaths.isEmpty) {
        print('🎵 No cover paths found for playlists');
        return playlists;
      }
      
      print('📁 Loading ${coverPaths.length} playlist cover URLs...');
      
      // Get all URLs at once
      final urlMap = await storageService.getDownloadUrls(coverPaths);
      
      print('📁 URL map result: $urlMap');
      
      // Update playlists with URLs
      final List<PlaylistModel> updatedPlaylists = [];
      for (final playlist in playlists) {
        String? storagePath;
        
        // Determine which field contains the storage path
        if (playlist.coverStoragePath != null && playlist.coverStoragePath!.isNotEmpty) {
          storagePath = playlist.coverStoragePath!;
        } else if (playlist.coverUrl != null && 
                   playlist.coverUrl!.isNotEmpty && 
                   !playlist.coverUrl!.startsWith('http') && 
                   !playlist.coverUrl!.startsWith('https')) {
          storagePath = playlist.coverUrl!;
        }
        
        final updatedPlaylist = playlist.copyWith(
          coverUrl: storagePath != null ? urlMap[storagePath] : null,
        );
        
        print('🎵 Updated playlist: ${playlist.name}');
        print('🎵 Original coverUrl: ${playlist.coverUrl}');
        print('🎵 New coverUrl: ${updatedPlaylist.coverUrl}');
        
        updatedPlaylists.add(updatedPlaylist);
      }
      
      print('✅ Playlist cover URLs loaded successfully');
      return updatedPlaylists;
    } catch (e) {
      print('❌ Error loading playlist URLs: $e');
      return playlists; // Return without URLs if error
    }
  }

Future<List<PlaylistModel>> _searchPlaylists(String query) async {
  try {
    print('🎵 Searching playlists with query: "$query"');
    
    final String lowerQuery = query.toLowerCase();
    final List<String> searchTerms = lowerQuery.split(' ').where((term) => term.isNotEmpty).toList();
    
    final querySnapshot = await _firestore
        .collection('playlists')
        .where('is_public', isEqualTo: true)
        .limit(50)
        .get();

    final List<PlaylistModel> playlists = [];
    
    for (final doc in querySnapshot.docs) {
      try {
        final data = doc.data();
        final nameLowercase = data['name_lowercase'] as String? ?? '';
        final description = (data['description'] as String? ?? '').toLowerCase();
        final creatorName = (data['creator_name'] as String? ?? '').toLowerCase();
        
        // ✅ Tìm kiếm từng term trong query
        bool matches = searchTerms.any((term) => 
          nameLowercase.contains(term) || 
          description.contains(term) || 
          creatorName.contains(term)
        );
        
        if (matches) {
          final playlistData = {
            'id': doc.id,
            ...data,
          };
          playlists.add(PlaylistModel.fromJson(playlistData));
          print('✅ Found playlist: ${data['name']}');
          
          if (playlists.length >= 10) break;
        }
      } catch (e) {
        print('❌ Error processing playlist: $e');
      }
    }

    // Load URLs for all playlists
    final playlistsWithUrls = await _loadUrlsForPlaylists(playlists);

    print('🎵 Final playlists count: ${playlistsWithUrls.length}');
    return playlistsWithUrls;
  } catch (e) {
    print('❌ Error searching playlists: $e');
    return [];
  }
}

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final String searchQuery = query.toLowerCase().trim();
      
      if (searchQuery.isEmpty) return [];

      // Get suggestions from popular searches or recent queries
      final querySnapshot = await _firestore
          .collection('search_suggestions')
          .where('term', isGreaterThanOrEqualTo: searchQuery)
          .where('term', isLessThan: searchQuery + '\uf8ff')
          .orderBy('term')
          .orderBy('popularity', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['term'] as String)
          .toList();
    } catch (e) {
      print('Error getting suggestions: ${e.toString()}');
      // Return empty list on error for suggestions
      return [];
    }
  }
} // Đóng class ở đây