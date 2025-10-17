import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/google_sign_in_service.dart';
import 'package:app_nghenhac/presentation/auth/pages/signin.dart';
import 'package:app_nghenhac/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:app_nghenhac/presentation/profile/pages/profile.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final googleSignInService = sl<GoogleSignInService>();
    
    return Drawer(
      child: Column(
        children: [
          // Header với thông tin user
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            accountName: Text(
              currentUser?.displayName ?? 'Người dùng',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              currentUser?.email ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: currentUser?.photoURL != null
                  ? NetworkImage(currentUser!.photoURL!)
                  : null,
              child: currentUser?.photoURL == null
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    )
                  : null,
            ),
          ),
          
          // Dark Mode Toggle
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, state) {
              final isDark = state == ThemeMode.dark;
              return ListTile(
                leading: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.yellow : Colors.orange,
                ),
                title: Text(
                  isDark ? 'Chế độ tối' : 'Chế độ sáng',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    context.read<ThemeCubit>().updateTheme(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: () {
                  context.read<ThemeCubit>().updateTheme(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
                },
              );
            },
          ),
          
          const Divider(),
          
          // Profile
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Hồ sơ'),
            onTap: () {
              Navigator.pop(context); // Đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          
          // Settings
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Settings page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng cài đặt đang phát triển')),
              );
            },
          ),
          
          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Giới thiệu'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          
          // Help
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Trợ giúp'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng trợ giúp đang phát triển')),
              );
            },
          ),
          
          const Divider(),
          
          const Spacer(),
          
          // Sign Out
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _showSignOutDialog(context, googleSignInService),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Giới thiệu'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Nghe Nhạc',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text('Phiên bản: 1.0.0'),
              SizedBox(height: 8),
              Text(
                'Ứng dụng nghe nhạc trực tuyến với nhiều tính năng hấp dẫn.',
              ),
              SizedBox(height: 16),
              Text(
                'Phát triển bởi: Nhóm i',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, GoogleSignInService googleSignInService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Đóng drawer
                
                try {
                  await googleSignInService.signOut();
                  
                  // Chuyển về trang đăng nhập
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => SigninPage()),
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi đăng xuất: $e')),
                  );
                }
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}