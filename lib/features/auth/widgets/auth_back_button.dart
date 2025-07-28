import 'package:flutter/material.dart';
import 'package:palm_diagnose/features/auth/pages/login_page.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            size: 22, color: Colors.black87),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          );
        },
      ),
    );
  }
}
