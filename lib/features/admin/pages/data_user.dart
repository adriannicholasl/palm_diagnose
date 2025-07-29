import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:palm_diagnose/features/admin/pages/user_detection_history_page.dart';
import 'package:palm_diagnose/features/admin/widgets/search.dart';
import 'package:palm_diagnose/features/admin/widgets/user_tile_card.dart';
import 'package:palm_diagnose/features/admin/widgets/shimmer_loading.dart';

class DataUserPage extends StatefulWidget {
  const DataUserPage({super.key});

  @override
  State<DataUserPage> createState() => _DataUserPageState();
}

class _DataUserPageState extends State<DataUserPage> {
  final firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: firebaseService.getCurrentUserData(),
      builder: (context, snapshot) {
        // LOADING SEARC
        // final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final userData = snapshot.data;
        final role = userData?['role'] ?? 'user';
        final rawDisplayName = userData?['displayName'];
        final displayName = (rawDisplayName == null || rawDisplayName.isEmpty)
            ? (role == 'admin' ? 'Admin' : 'User')
            : rawDisplayName;

        return Padding(
          padding: const EdgeInsets.only(top: 24.0, left: 12.0, right: 12.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Halo, $displayName\nDaftar Semua Pengguna:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SearchInput(
                  textController: _searchController,
                  hintText: 'Cari nama pengguna...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: firebaseService.getAllUsersWithDetectionCounts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ShimmerLoading();
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Terjadi kesalahan saat mengambil data.'),
                      );
                    }

                    final users = snapshot.data ?? [];
                    final filteredUsers = users.where((user) {
                      final name = (user['displayName'] ?? '').toString();
                      return name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return const Center(child: Text('Tidak ada pengguna.'));
                    }

                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final name =
                            (user['displayName']
                                    ?.toString()
                                    .trim()
                                    .isNotEmpty ??
                                false)
                            ? user['displayName']
                            : (user['role'] == 'admin' ? 'Admin' : 'User');
                        final email = user['email'] ?? '-';
                        final photoURL = user['photoURL'];
                        final uid = user['uid'];
                        final totalDeteksi = user['totalDeteksi'] ?? 0;

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: UserTileCard(
                            key: ValueKey(user['uid']),
                            name: name,
                            email: email,
                            photoUrl: photoURL,
                            totalDeteksi: totalDeteksi,
                            onTap: () {
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
                          ),
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
