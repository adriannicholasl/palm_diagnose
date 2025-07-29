// lib/features/admin/pages/data_user_page.dart

import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:palm_diagnose/features/admin/pages/user_detection_history_page.dart';

class DataUserPage extends StatelessWidget {
  const DataUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

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

        return Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isLoading
                        ? 'Loading...'
                        : 'Halo, $displayName\nDaftar Semua Pengguna:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                        child: Text('Terjadi kesalahan saat mengambil data.'),
                      );
                    }

                    final users = snapshot.data ?? [];

                    if (users.isEmpty) {
                      return const Center(child: Text('Belum ada pengguna.'));
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final name =
                            user['displayName']?.toString().trim().isNotEmpty ==
                                true
                            ? user['displayName']
                            : (user['role'] == 'admin' ? 'Admin' : 'User');
                        final email = user['email'] ?? '-';
                        final photoURL = user['photoURL'];

                        return ListTile(
                          leading: photoURL != null && photoURL.isNotEmpty
                              ? CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: Image.network(
                                      photoURL,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/default_avatar.jpg',
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                    ),
                                  ),
                                )
                              : const CircleAvatar(
                                  backgroundImage: AssetImage(
                                    'assets/images/default_avatar.jpg',
                                  ),
                                ),
                          title: Text(name),
                          subtitle: Text(email),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            final uid = user['uid'];
                            if (uid == null) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserDetectionHistoryPage(
                                  uid: uid,
                                  displayName: name,
                                  photoUrl: photoURL,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
