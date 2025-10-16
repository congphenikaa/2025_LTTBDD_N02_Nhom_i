import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/button/basic_app_button.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/core/services/google_sign_in_service.dart';
import 'package:app_nghenhac/data/models/auth/signin_user_req.dart';
import 'package:app_nghenhac/domain/usecases/auth/signin.dart';
import 'package:app_nghenhac/presentation/auth/pages/signup.dart';
import 'package:app_nghenhac/presentation/home/pages/home.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SigninPage extends StatefulWidget {
  SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GoogleSignInService _googleSignInService = sl<GoogleSignInService>();
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signupText(context),
      appBar: BasicAppbar(
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 40,
          width: 40,
        ),
      ),
      body: SingleChildScrollView(       
          padding: const EdgeInsets.symmetric(
            vertical: 50,
            horizontal: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _registerText(),
              SizedBox(height: 50,),
              _emailField(context),
              SizedBox(height: 20,),
              _passwordField(context),
              SizedBox(height: 20,),
              BasicAppButton(
                onPressed: () async {
                  var result = await sl<SigninUseCase>().call(
                    params: SigninUserReq( 
                      email: _email.text.toString(), 
                      password: _password.text.toString()
                    )
                  );
                  result.fold(
                    (l){
                      var snackbar = SnackBar(content: Text(l), behavior: SnackBarBehavior.floating,);
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    }, 
                    (r){
                      Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (BuildContext context) => HomePage()), 
                        (route) => false
                      );
                    }
                  );
                }, 
                title: 'Sign In'
              ),
              SizedBox(height: 20,),
              _orDivider(),
              SizedBox(height: 20,),
              _googleSignInButton(),
            ],
          ),
        )
    );
  }

  Widget _registerText() {
    return const Text(
      'Sign In',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(
        hintText: 'Enter Email'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: _obscurePassword, // Thêm dòng này
      decoration: InputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _googleSignInButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isGoogleLoading ? null : _signInWithGoogle,
        icon: _isGoogleLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : SvgPicture.asset(
                'assets/vectors/google_logo.svg',
                height: 20,
                width: 20,
              ),
        label: Text(
          _isGoogleLoading ? 'Đang đăng nhập...' : 'Đăng nhập với Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    
    try {
      final userCredential = await _googleSignInService.signInWithGoogle();
      if (userCredential != null) {
        // Đăng nhập thành công, chuyển về trang chính
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (BuildContext context) => HomePage()), 
          (route) => false
        );
      } else {
        // Người dùng hủy đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập bị hủy'), 
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng nhập Google: $e'), 
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }


  Widget _signupText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Not A Member?',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                 builder: (BuildContext context) => SignupPage()
                )
              );
            }, 
            child: Text(
              'Register Now',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            )
          )
        ],
      ),
    );
  }
}