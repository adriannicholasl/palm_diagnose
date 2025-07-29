import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:palm_diagnose/features/main/widgets/custom_top_appbar.dart';
import 'package:palm_diagnose/features/main/widgets/custom_buttom_bar.dart';

class UserDetectionHistoryPage extends StatefulWidget {
  final String uid;
  final String displayName;
  final String? photoUrl;

  const UserDetectionHistoryPage({
    Key? key,
    required this.uid,
    required this.displayName,
    this.photoUrl,
  }) : super(key: key);

  @override
  State<UserDetectionHistoryPage> createState() =>
      _UserDetectionHistoryPageState();
}

class _UserDetectionHistoryPageState extends State<UserDetectionHistoryPage> {
  int currentIndex = 1; // Sesuaikan index-nya (0 = home, 1 = history, dst)
  final firebaseService = FirebaseService();

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });

    // Navigasi berdasarkan index
    if (index == 0) {
      Navigator.pop(context); // Misalnya balik ke halaman sebelumnya
    } else if (index == 2) {
      // Close or Cancel
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 3) {
      // Navigasi ke halaman profil
      // Navigator.pushNamed(context, '/user/profile'); // contoh
    }
  }

  void onFabPressed() {
    // Navigasi ke halaman deteksi gambar
    // Navigator.pushNamed(context, '/user/detect'); // contoh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            CustomTopAppBar(
              upperTitle: "Riwayat",
              title: widget.displayName,
              onTapProfile: () {},
              profileImageUrl: widget.photoUrl,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firebaseService.getUserDetections(widget.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    debugPrint(
                      "🔥 Firestore snapshot error: ${snapshot.error}",
                    );
                    return const Center(
                      child: Text("❌ Terjadi kesalahan saat memuat data."),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("📭 Belum ada hasil deteksi."),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final filename = data['filename'] ?? '';
                      final results = List<Map<String, dynamic>>.from(
                        data['results'] ?? [],
                      );

                      return Column(
                        children: results.map((result) {
                          final model = result['model'] ?? '-';
                          final label = result['label'] ?? '-';
                          final confidence =
                              (result['confidence'] as num?)?.toDouble() ?? 0.0;
                          final imageUrl =
                              'https://d8a7804a7815.ngrok-free.app/uploads/$filename';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  headers: const {
                                    'ngrok-skip-browser-warning': 'true',
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('❌ Image load error: $error');
                                    return const Icon(Icons.broken_image);
                                  },
                                ),
                              ),
                              title: Text("Model: $model"),
                              subtitle: Text(
                                "Label: $label\nConfidence: ${confidence.toStringAsFixed(1)}%",
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// ✅ Bottom Navigation Custom Curved
      bottomNavigationBar: BottomNavBarCurvedFb1(
        currentIndex: currentIndex,
        onItemTapped: onItemTapped,
        onFabPressed: onFabPressed,
      ),
    );
  }
}
