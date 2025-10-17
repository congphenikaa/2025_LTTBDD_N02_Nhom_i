import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:flutter/material.dart';
import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';

class AlbumCard extends StatelessWidget {
  final AlbumEntity album;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final bool isHorizontal;
  final double? width;

  const AlbumCard({
    Key? key,
    required this.album,
    this.onTap,
    this.onFavoritePressed,
    this.isHorizontal = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = isHorizontal ? null : (width ?? _getResponsiveWidth(screenWidth));
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(8),
        child: isHorizontal 
            ? _buildHorizontalLayout(context) 
            : _buildVerticalLayout(context),
      ),
    );
  }

  double _getResponsiveWidth(double screenWidth) {
    if (screenWidth < 400) return 140;
    if (screenWidth < 600) return 160;
    return 180;
  }

  Widget _buildVerticalLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 400 ? 14.0 : 16.0;
    final titleFontSize = screenWidth < 400 ? 15.0 : 16.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Album Cover
        Stack(
        children: [
          _buildAlbumCover(context),
          Positioned(
              top: 6,
              right: 6,
              child: _buildFavoriteButton(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Album Title
        Flexible(
          child: Text(
            album.title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? Colors.white : Colors.black,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        
        // Artist Name
        Flexible(
          child: Text(
            album.artist,
            style: TextStyle(
              fontSize: fontSize - 1,
              color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Release Year & Track Count
        if (album.releaseDate != null || album.trackCount != null) ...[
          const SizedBox(height: 4),
          Flexible(
            child: _buildAlbumInfo(context, fontSize - 3),
          ),
        ],
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final coverSize = screenWidth < 400 ? 60.0 : 80.0;
    final fontSize = screenWidth < 400 ? 13.0 : 14.0;
    final titleFontSize = screenWidth < 400 ? 14.0 : 16.0;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Cover
          SizedBox(
            width: coverSize,
            height: coverSize,
            child: _buildAlbumCover(context),
          ),
          SizedBox(width: screenWidth < 400 ? 8 : 12),
          
          // Album Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  album.title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                
                Text(
                  album.artist,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (album.releaseDate != null || album.trackCount != null) ...[
                  const SizedBox(height: 2),
                  _buildAlbumInfo(context, fontSize - 2),
                ],
              ],
            ),
          ),
          
          // Favorite Button
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildFavoriteButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumInfo(BuildContext context, double fontSize) {
    return Row(
      children: [
        if (album.releaseDate != null) ...[
          Flexible(
            child: Text(
              album.releaseDate!.year.toString(),
              style: TextStyle(
                fontSize: fontSize,
                color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (album.releaseDate != null && album.trackCount != null)
          Text(
            ' • ',
            style: TextStyle(
              fontSize: fontSize,
              color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        if (album.trackCount != null)
          Flexible(
            child: Text(
              '${album.trackCount} tracks',
              style: TextStyle(
                fontSize: fontSize,
                color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildAlbumCover(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final coverHeight = isHorizontal 
        ? (screenWidth < 400 ? 60.0 : 80.0)
        : (screenWidth < 400 ? 120.0 : 144.0);
    
    return Container(
      width: double.infinity,
      height: coverHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: album.coverUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Builder(
                builder: (context) {
                  print('💿 Album Cover URL: ${album.coverUrl}');
                  return Image.network(
                    album.coverUrl!,
                    width: double.infinity,
                    height: coverHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ Error loading album cover: ${album.coverUrl}');
                      print('❌ Error: $error');
                      return _buildDefaultCover(context);
                    },
                  );
                }
              ),
            )
          : _buildDefaultCover(context),
    );
  }

  Widget _buildDefaultCover(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final coverHeight = isHorizontal 
        ? (screenWidth < 400 ? 60.0 : 80.0)
        : (screenWidth < 400 ? 120.0 : 144.0);
    final iconSize = isHorizontal 
        ? (screenWidth < 400 ? 30.0 : 40.0)
        : (screenWidth < 400 ? 45.0 : 60.0);
    
    return Container(
      width: double.infinity,
      height: coverHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.7),
            AppColors.primary,
          ],
        ),
      ),
      child: Icon(
        Icons.album,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    if (onFavoritePressed == null) return const SizedBox.shrink();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth < 400 ? 28.0 : 32.0;
    final iconSize = screenWidth < 400 ? 16.0 : 18.0;
    
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onFavoritePressed,
        icon: Icon(
          album.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: album.isFavorite ? Colors.red : Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}