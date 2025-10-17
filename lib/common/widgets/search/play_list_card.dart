import 'package:app_nghenhac/domain/entities/search/playlist.dart';
import 'package:flutter/material.dart';
import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistEntity playlist;
  final VoidCallback? onTap;
  final bool isHorizontal;
  final double? width;

  const PlaylistCard({
    Key? key,
    required this.playlist,
    this.onTap,
    this.isHorizontal = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: isHorizontal ? null : (width ?? 160),
        padding: const EdgeInsets.all(8),
        child: isHorizontal ? _buildHorizontalLayout(context) : _buildVerticalLayout(context),
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // ✅ Chỉ chiếm space cần thiết
      children: [
        // Playlist Cover
        Flexible( // ✅ Cho phép cover resize nếu cần
          child: _buildPlaylistCover(),
        ),
        const SizedBox(height: 12),
        
        // Playlist Name
        Text(
          playlist.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
          maxLines: 2, // ✅ Cho phép 2 dòng cho tên dài
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        
        // Creator Name
        if (playlist.creatorName != null)
          Text(
            'By ${playlist.creatorName}',
            style: TextStyle(
              fontSize: 14,
              color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        
        // Track Count
        if (playlist.trackCount != null) ...[
          const SizedBox(height: 4),
          Text(
            '${playlist.trackCount} songs',
            style: TextStyle(
              fontSize: 12,
              color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      children: [
        // Playlist Cover
        SizedBox(
          width: 80,
          height: 80,
          child: _buildPlaylistCover(),
        ),
        const SizedBox(width: 12),
        
        // Playlist Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlist.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              if (playlist.creatorName != null)
                Text(
                  'By ${playlist.creatorName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              
              if (playlist.trackCount != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${playlist.trackCount} songs',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistCover() {
    return AspectRatio(
      aspectRatio: 1.0, 
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[300],
        ),
        child: playlist.coverUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Builder(
                  builder: (context) {
                    print('🎵 Playlist Cover URL: ${playlist.coverUrl}');
                    return Image.network(
                      playlist.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Error loading playlist cover: ${playlist.coverUrl}');
                        print('❌ Error: $error');
                        return _buildDefaultCover();
                      },
                    );
                  }
                ),
              )
            : _buildDefaultCover(),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.7),
            AppColors.primary,
          ],
        ),
      ),
      child: const Icon(
        Icons.queue_music,
        color: Colors.white,
        size: 50,
      ),
    );
  }
}