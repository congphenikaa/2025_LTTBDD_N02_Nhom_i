import 'package:flutter/material.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';

class SongListTitle extends StatelessWidget {
  final SongEntity song;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final bool showArtist;
  final bool showAlbum;
  final bool showDuration;

  const SongListTitle({
    Key? key,
    required this.song,
    this.onTap,
    this.onFavoritePressed,
    this.showArtist = true,
    this.showAlbum = false,
    this.showDuration = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Song Cover
            _buildCover(),
            const SizedBox(width: 12),
            
            // Song Info
            Expanded(
              child: _buildSongInfo(context),
            ),
            
            // Duration
            if (showDuration) _buildDuration(context),
            
            // Favorite Button
            _buildFavoriteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: song.coverUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Builder(
                builder: (context) {
                  print('🖼️ Loading cover URL: ${song.coverUrl}');
                  return Image.network(
                    song.coverUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ Error loading cover URL: ${song.coverUrl}');
                      print('❌ Error: $error');
                      return _buildDefaultCover();
                    },
                  );
                }
              ),
            )
          : _buildDefaultCover(),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.7),
            AppColors.primary,
          ],
        ),
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Song Title
        Text(
          song.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        
        // Artist and Album
        Row(
          children: [
            if (showArtist) ...[
              Flexible(
                child: Text(
                  song.artist,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (showArtist && showAlbum && song.album != null) ...[
              Text(
                ' • ',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
            if (showAlbum && song.album != null) ...[
              Flexible(
                child: Text(
                  song.album!,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDuration(BuildContext context) {
    // ✅ Thêm debug để kiểm tra
    print('🎵 Song: ${song.title}');
    print('🕐 Duration from Firebase: ${song.duration}');
    
    if (song.duration == null) {
      print('⚠️ Duration is null for song: ${song.title}');
      return const SizedBox.shrink();
    }
    
    final formattedDuration = _formatDuration(song.duration!);
    print('✅ Formatted duration: $formattedDuration');
    
    return Text(
      formattedDuration,
      style: TextStyle(
        fontSize: 14,
        color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return IconButton(
      onPressed: onFavoritePressed,
      icon: Icon(
        song.isFavorite ? Icons.favorite : Icons.favorite_border,
        color: song.isFavorite ? Colors.red : (context.isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        size: 22,
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 0) return '0:00';
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    // ✅ Format đẹp hơn
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}