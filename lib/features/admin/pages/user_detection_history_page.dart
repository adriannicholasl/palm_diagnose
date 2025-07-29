import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:palm_diagnose/features/main/widgets/custom_top_appbar.dart';
import 'package:palm_diagnose/features/main/widgets/custom_buttom_bar.dart';
import 'package:palm_diagnose/core/constants/gradient_scaffold.dart';
import 'package:palm_diagnose/features/main/pages/home_page.dart';

class UserDetectionHistoryPage extends StatefulWidget {
  final String uid;
  final String displayName;
  final String? photoUrl;

  const UserDetectionHistoryPage({
    super.key,
    required this.uid,
    required this.displayName,
    this.photoUrl,
  });

  @override
  State<UserDetectionHistoryPage> createState() =>
      _UserDetectionHistoryPageState();
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}

class _UserDetectionHistoryPageState extends State<UserDetectionHistoryPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 1;
  final firebaseService = FirebaseService();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  void onItemTapped(int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Delay sebentar agar pop selesai sebelum push
    Future.delayed(const Duration(milliseconds: 50), () {
      // Kirim tab index ke HomePage lewat arguments atau global
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            role: 'admin',
            initialIndex: 1, // atau index yang kamu inginkan
          ),
        ),
      );
    });
  }

  LinearGradient _getConfidenceGradient(double confidence) {
    if (confidence >= 70) {
      return const LinearGradient(
        colors: [Color(0xFFA2EBA6), Color(0xFF28782C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (confidence >= 40) {
      return const LinearGradient(
        colors: [Color(0xFFE6D969), Color(0xFFF7BC25)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFFF77270), Color(0xFFCB2626)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GradientScaffold(
      appBar: CustomTopAppBar(
        upperTitle: "Riwayat",
        title: widget.displayName,
        profileImageUrl: widget.photoUrl,
        onTapProfile: () {},
        showBackButton: true,
        onBack: () {
          Navigator.pop(context); // custom aksi
        },
      ),
      bottomNavigationBar: BottomNavBarCurvedFb1(
        currentIndex: currentIndex,
        onItemTapped: onItemTapped,
        onFabPressed: () {}, // TODO: implement
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getUserDetections(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("❌ Terjadi kesalahan saat memuat data."),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("📭 Belum ada hasil deteksi."));
          }

          // Flattened list: 1 result = 1 card
          final items = docs.expand((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final filename = data['filename'] ?? '';
            final results = List<Map<String, dynamic>>.from(
              data['results'] ?? [],
            );
            return results.map(
              (result) => {
                'model': result['model'] ?? '-',
                'label': result['label'] ?? '-',
                'confidence': (result['confidence'] as num?)?.toDouble() ?? 0.0,
                'imageUrl':
                    'https://d8a7804a7815.ngrok-free.app/uploads/$filename',
              },
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final model = item['model'];
              final label = item['label'];
              final confidence = item['confidence'];
              final imageUrl = item['imageUrl'];

              final fade = CurvedAnimation(
                parent: _controller,
                curve: Curves.easeIn,
              );
              final scale = CurvedAnimation(
                parent: _controller,
                curve: Curves.decelerate,
              );

              return FadeTransition(
                opacity: fade,
                child: ScaleTransition(
                  scale: scale,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withAlpha(51)
                                  : Colors.grey.withAlpha(21),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
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
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                          title: Text(
                            model,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withAlpha(150),
                            ),
                          ),
                        ),
                      ),

                      // 🎯 Confidence Chart Badge
                      Positioned(
                        top: -12,
                        right: 12,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 72,
                              width: 72,
                              child: SfCircularChart(
                                margin: EdgeInsets.zero,
                                series: <CircularSeries>[
                                  RadialBarSeries<ChartData, String>(
                                    dataSource: [
                                      ChartData('Confidence', confidence),
                                    ],
                                    maximumValue: 100,
                                    radius: '90%',
                                    innerRadius: '75%',
                                    cornerStyle: CornerStyle.bothCurve,
                                    trackOpacity: 0.2,
                                    gap: '3%',
                                    pointShaderMapper: (data, _, color, rect) {
                                      return _getConfidenceGradient(
                                        confidence,
                                      ).createShader(rect);
                                    },
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: false,
                                    ),
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${confidence.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
