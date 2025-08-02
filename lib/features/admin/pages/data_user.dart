import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/services/user_service.dart';
import 'package:palm_diagnose/features/admin/pages/user_detection_history_page.dart';
import 'package:palm_diagnose/features/admin/widgets/search.dart';
import 'package:palm_diagnose/features/admin/widgets/user_tile_card.dart';
import 'package:palm_diagnose/features/admin/widgets/shimmer_loading.dart';
import 'package:palm_diagnose/features/admin/widgets/user_greeting_header.dart';

class DataUserPage extends StatefulWidget {
  const DataUserPage({super.key});

  @override
  State<DataUserPage> createState() => _DataUserPageState();
}

class _DataUserPageState extends State<DataUserPage> {
  final userService = UserService();
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
      future: userService.getCurrentUserData(),
      builder: (context, snapshot) {
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
              UserGreetingHeader(displayName: displayName),
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
                  future: userService.getAllUsersWithDetectionCounts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ShimmerLoading();
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Terjadi kesalahan saat mengambil data.'),
                      );
                    }

                    return _buildUserList(snapshot.data ?? []);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users) {
    final filteredUsers = users.where((user) {
      final name = (user['displayName'] ?? '').toString();
      return name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredUsers.isEmpty) {
      return const Center(child: Text('Tidak ada pengguna.'));
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        final name =
            (user['displayName']?.toString().trim().isNotEmpty ?? false)
            ? user['displayName']
            : (user['role'] == 'admin' ? 'Admin' : 'User');
        final email = user['email'] ?? '-';
        final photoURL = user['photoURL'];
        final uid = user['uid'];
        final totalDeteksi = user['totalDeteksi'] ?? 0;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: UserTileCard(
            key: ValueKey(uid),
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
  }
}
