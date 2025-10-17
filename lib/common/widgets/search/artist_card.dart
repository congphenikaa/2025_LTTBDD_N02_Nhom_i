import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:flutter/material.dart';

import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';

class ArtistCard extends StatelessWidget {
  final ArtistEntity artist;
  final VoidCallback? onTap;
  final VoidCallback? onFollowPressed;
  final bool isHorizontal;

  const ArtistCard({
    Key? key,
    required this.artist,
    this.onTap,
    this.onFollowPressed,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = isHorizontal ? null : _calculateCardWidth(screenWidth);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: cardWidth,
        constraints: BoxConstraints(
          minHeight: isHorizontal ? 80 : 120,
          maxHeight: isHorizontal ? 100 : 200,
        ),
        padding: EdgeInsets.all(isHorizontal ? 12 : 8),
        child: isHorizontal ? _buildHorizontalLayout(context) : _buildVerticalLayout(context),
      ),
    );
  }
  
  double _calculateCardWidth(double screenWidth) {
    // Responsive width calculation
    if (screenWidth < 360) {
      return 120; // Small screens
    } else if (screenWidth < 600) {
      return 140; // Medium screens
    } else {
      return 160; // Large screens
    }
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Artist Image
        _buildArtistImage(context),
        const SizedBox(height: 8),
        
        // Artist Name
        Flexible(
          child: Text(
            artist.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        
        // Followers Count
        if (artist.followers != null) ...[
          Text(
            '${_formatFollowers(artist.followers!)} followers',
            style: TextStyle(
              fontSize: 11,
              color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
        ],
        
        // Follow Button
        if (onFollowPressed != null) 
          Flexible(child: _buildFollowButton(context)),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Artist Image
          SizedBox(
            width: 60,
            height: 60,
            child: _buildArtistImage(context),
          ),
          const SizedBox(width: 12),
          
          // Artist Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  artist.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                if (artist.followers != null)
                  Text(
                    '${_formatFollowers(artist.followers!)} followers',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                if (artist.genres != null && artist.genres!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    artist.genres!.take(2).join(', '),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Follow Button
          if (onFollowPressed != null) 
            Flexible(
              flex: 1,
              child: _buildFollowButton(context),
            ),
        ],
      ),
    );
  }

  Widget _buildArtistImage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double radius;
    
    if (isHorizontal) {
      radius = 30;
    } else {
      // Responsive radius for vertical layout
      if (screenWidth < 360) {
        radius = 35;
      } else if (screenWidth < 600) {
        radius = 45;
      } else {
        radius = 50;
      }
    }
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        backgroundImage: artist.imageUrl != null
            ? (() {
                print('👤 Artist Image URL: ${artist.imageUrl}');
                return NetworkImage(artist.imageUrl!);
              })()
            : null,
        child: artist.imageUrl == null
            ? Icon(
                Icons.person,
                size: radius * 0.8,
                color: Colors.grey[600],
              )
            : null,
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      height: isHorizontal ? 36 : 32,
      constraints: BoxConstraints(
        minWidth: isSmallScreen ? 60 : 80,
        maxWidth: isHorizontal ? 100 : 120,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: artist.isFollowed ? Colors.transparent : AppColors.primary,
        border: Border.all(
          color: AppColors.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onFollowPressed,
        borderRadius: BorderRadius.circular(18),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              artist.isFollowed ? 'Following' : 'Follow',
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: artist.isFollowed ? AppColors.primary : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }
  
  // Helper methods for responsive design
  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
  
  bool _isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 600;
  }
  
  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }
}