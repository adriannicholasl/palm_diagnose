import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palm_diagnose/features/auth/pages/signin_page.dart';
import 'package:palm_diagnose/features/main/pages/home_page.dart';

/// Pastikan file ini sudah ada

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<String?> _getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      return data?['role'];
    } catch (e) {
      debugPrint("❌ Error mengambil role user: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SignInScreen(); // belum login
        }

        final user = snapshot.data!;
        debugPrint("✅ User logged in: ${user.email}");

        return FutureBuilder<String?>(
          future: _getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;

            if (role == 'admin' || role == 'user') {
              return HomePage(role: role!); // arahkan ke MainNavigation
            } else {
              return const Scaffold(
                body: Center(
                  child: Text('Peran tidak dikenali atau belum diatur.'),
                ),
              );
            }
          },
        );
      },
    );
  }
}
