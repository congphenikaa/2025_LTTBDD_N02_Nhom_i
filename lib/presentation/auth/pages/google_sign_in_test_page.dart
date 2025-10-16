import 'package:flutter/material.dart';
import 'package:app_nghenhac/presentation/auth/widgets/google_sign_in_button.dart';

class GoogleSignInTestPage extends StatelessWidget {
  const GoogleSignInTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Google Sign-In'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 32),
              Text(
                'Chào mừng đến với App Nghe Nhạc',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Đăng nhập để trải nghiệm đầy đủ tính năng',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              GoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}