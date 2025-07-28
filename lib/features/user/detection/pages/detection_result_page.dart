import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/constants/fitness_app_theme.dart';
import 'package:palm_diagnose/features/auth/controllers/auth_controller.dart';
import 'package:palm_diagnose/features/user/detection/widgets/detection_result_card.dart';
import 'package:palm_diagnose/shared/widgets/custom_animated_appbar.dart';
import 'package:palm_diagnose/features/user/detection/controllers/detection_service.dart'; // ⬅️ Import DetectionResult

class DetectionResultPage extends StatefulWidget {
  final File imageFile;
  final List<DetectionResult> results; // ✅ perbaikan: bukan Map lagi

  const DetectionResultPage({
    super.key,
    required this.imageFile,
    required this.results,
  });

  @override
  State<DetectionResultPage> createState() => _DetectionResultPageState();
}

class _DetectionResultPageState extends State<DetectionResultPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    print('>>> Hasil Deteksi dibuka');
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.results;

    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAnimatedAppBar(
          animationController: _animationController,
          topBarAnimation: _animation,
          topBarOpacity: 1.0,
          title: 'Hasil Deteksi',
          onTitleTap: () async {
            final auth = AuthController();
            await auth.logout();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
              height: 280,
            ),
          ),
          Positioned.fill(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 5,
                  right: 5,
                  top: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DetectionResultCardAnimated(
                        modelUsed: results[0].model,
                        label: results[0].label,
                        confidence: results[0].confidence,
                        animation: _animation,
                        animationController: _animationController,
                      ),
                      const SizedBox(height: 16),
                      ...results.skip(1).map((result) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: DetectionResultCardAnimated(
                            modelUsed: result.model,
                            label: result.label,
                            confidence: result.confidence,
                            animation: _animation,
                            animationController: _animationController,
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                      const Text(
                        '🩺 Deskripsi Penyakit:\n\n'
                        'Deskripsi penyakit yang terdeteksi akan ditampilkan di sini.\n'
                        'Bisa memuat informasi gejala, penyebab, serta langkah pencegahan.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
