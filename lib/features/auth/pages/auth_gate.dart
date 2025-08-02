import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palm_diagnose/features/auth/pages/signin_page.dart';
import 'package:palm_diagnose/features/main/pages/home_gate.dart';
import 'package:palm_diagnose/features/main/widgets/loading_animation.dart';

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
        // ⏳ Loading saat Firebase sedang mengecek auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: LoadingAnimation(), // ✅ Lottie loading di sini
          );
        }

        // 👤 Belum login
        if (!snapshot.hasData || snapshot.data == null) {
          return const SignInScreen();
        }

        final user = snapshot.data!;
        debugPrint("✅ User logged in: ${user.email}");

        return FutureBuilder<String?>(
          future: _getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            // ⏳ Loading saat ambil role dari Firestore
            if (roleSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: LoadingAnimation(), // ✅ Ganti dengan Lottie
              );
            }

            final role = roleSnapshot.data;

            if (role == 'admin' || role == 'user') {
              return HomeGate(role: role!);
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
