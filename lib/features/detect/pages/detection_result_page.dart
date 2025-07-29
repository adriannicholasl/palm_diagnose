import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/constants/app_colors.dart';
import 'package:palm_diagnose/core/services/detection_service.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:palm_diagnose/features/main/widgets/custom_top_appbar.dart';
import 'package:palm_diagnose/features/main/widgets/custom_buttom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DetectionResultPage extends StatefulWidget {
  final File? imageFile;
  final Uint8List? imageBytesWeb;
  final List<DetectionResult> results;

  const DetectionResultPage({
    Key? key,
    this.imageFile,
    this.imageBytesWeb,
    required this.results,
  }) : super(key: key);

  @override
  State<DetectionResultPage> createState() => _DetectionResultPageState();
}

class _DetectionResultPageState extends State<DetectionResultPage> {
  bool _isSaving = false;
  String _displayName = 'User';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final data = await FirebaseService().getCurrentUserData();
      setState(() {
        _displayName = data?['displayName'] ?? 'User';
        _photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
      });
    } catch (e) {
      debugPrint('❌ Gagal ambil data: $e');
    }
  }

  Future<void> _saveResultsToFirestore() async {
    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gagal menyimpan: User tidak ditemukan'),
        ),
      );
      return;
    }

    final filename = widget.imageFile != null
        ? widget.imageFile!.path.split('/').last
        : 'web_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final resultsMap = widget.results.map((result) {
      return {
        'model': result.model,
        'label': result.label,
        'confidence': result.confidence,
      };
    }).toList();

    try {
      await FirebaseService().saveDetectionResults(
        uid: uid,
        filename: filename,
        results: resultsMap,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Hasil berhasil disimpan ke Firestore'),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Gagal simpan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Gagal menyimpan hasil')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildDetectionCard(DetectionResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 10.0,
            animation: true,
            percent: result.confidence / 100,
            center: Text(
              "${result.confidence.toStringAsFixed(1)}%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.green,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Model: ${result.model}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Label: ${result.label}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gambar yang digunakan tergantung platform
    final imageWidget = kIsWeb
        ? (widget.imageBytesWeb != null
              ? Image.memory(widget.imageBytesWeb!, fit: BoxFit.cover)
              : const Icon(Icons.image_not_supported))
        : (widget.imageFile != null
              ? Image.file(widget.imageFile!, fit: BoxFit.cover)
              : const Icon(Icons.image_not_supported));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Top Bar dengan cached profile image
            CustomTopAppBar(
              upperTitle: "Hasil",
              title: _displayName,
              profileImageUrl: _photoUrl,
              onTapProfile: () {},
            ),

            /// Body utama
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    /// Gambar yang diprediksi
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: imageWidget,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Hasil prediksi per model
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.results.length,
                        itemBuilder: (context, index) {
                          return _buildDetectionCard(widget.results[index]);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Tombol simpan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveResultsToFirestore,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving ? "Menyimpan..." : "Simpan Hasil",
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// Bottom navigation
      bottomNavigationBar: BottomNavBarCurvedFb1(
        currentIndex: 1,
        onItemTapped: (index) {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        onFabPressed: () {
          // Optional: Arahkan ke halaman deteksi ulang jika diinginkan
        },
      ),
    );
  }
}
