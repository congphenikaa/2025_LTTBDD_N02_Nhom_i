import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_nghenhac/core/services/google_sign_in_service.dart';
import 'package:app_nghenhac/service_locator.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final GoogleSignInService _googleSignInService = sl<GoogleSignInService>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _googleSignInService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // User is signed in
          final user = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user.photoURL == null
                    ? Icon(Icons.person)
                    : null,
              ),
              SizedBox(height: 8),
              Text('Xin chào, ${user.displayName ?? 'User'}!'),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _signOut,
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Đăng xuất'),
              ),
            ],
          );
        } else {
          // User is not signed in
          return ElevatedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.login),
            label: Text('Đăng nhập với Google'),
          );
        }
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    try {
      final userCredential = await _googleSignInService.signInWithGoogle();
      if (userCredential != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập bị hủy')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng nhập: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    
    try {
      await _googleSignInService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đăng xuất')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng xuất: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}