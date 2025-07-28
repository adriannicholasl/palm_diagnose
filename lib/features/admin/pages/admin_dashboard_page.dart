import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:palm_diagnose/shared/widgets/custom_top_appbar.dart';
import 'package:palm_diagnose/features/auth/pages/auth_gate.dart';
import 'package:palm_diagnose/features/auth/controllers/auth_controller.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: _firebaseService.getCurrentUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Gagal memuat data pengguna')),
          );
        }

        final userData = snapshot.data!;
        final displayName = userData['displayName'] ?? 'Admin';
        final photoUrl = userData['photoURL']?.isNotEmpty == true
            ? userData['photoURL']
            : null;

        return SafeArea(
          child: Column(
            children: [
              CustomTopAppBar(
                title: displayName,
                upperTitle: 'Welcome',
                profileImageUrl: photoUrl,
                onTapProfile: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Keluar'),
                      content: const Text('Yakin ingin logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await AuthController().logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthGate()),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
              Center(child: Text('Halo, $displayName!')),
            ],
          ),
        );
      },
    );
  }
}
