import 'package:flutter/material.dart';
import 'package:palm_diagnose/shared/widgets/custom_top_appbar.dart';
import 'package:palm_diagnose/features/auth/pages/auth_gate.dart';
import 'package:palm_diagnose/features/auth/controllers/auth_controller.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataUserPage extends StatelessWidget {
  const DataUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    // ignore: unused_local_variable
    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<Map<String, dynamic>?>(
      future: firebaseService.getCurrentUserData(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        final userData = snapshot.data;
        final role = userData?['role'] ?? 'user';
        final rawDisplayName = userData?['displayName'];
        final displayName = (rawDisplayName == null || rawDisplayName.isEmpty)
            ? (role == 'admin' ? 'Admin' : 'User')
            : rawDisplayName;
        final photoUrl = userData?['photoURL'];

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                CustomTopAppBar(
                  title: isLoading ? 'Loading...' : displayName,
                  upperTitle: 'Data Pengguna',
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Daftar Semua Pengguna:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                /// 🔥 Firestore Stream dari FirebaseService
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: firebaseService.getAllUsersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        debugPrint('🔥 ERROR STREAM: ${snapshot.error}');
                        return const Center(
                            child:
                                Text('Terjadi kesalahan saat mengambil data.'));
                      }

                      final users = snapshot.data ?? [];

                      if (users.isEmpty) {
                        return const Center(child: Text('Belum ada pengguna.'));
                      }

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final name = user['displayName']
                                      ?.toString()
                                      .trim()
                                      .isNotEmpty ==
                                  true
                              ? user['displayName']
                              : (user['role'] == 'admin' ? 'Admin' : 'User');
                          final email = user['email'] ?? '-';
                          final photoURL = user['photoURL'];

                          return ListTile(
                            leading: photoURL != null && photoURL.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(photoURL),
                                  )
                                : const CircleAvatar(
                                    backgroundImage: AssetImage(
                                      'assets/images/default_avatar.jpg',
                                    ),
                                  ),
                            title: Text(name),
                            subtitle: Text(email),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
