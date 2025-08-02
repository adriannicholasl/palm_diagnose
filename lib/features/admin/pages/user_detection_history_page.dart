import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:palm_diagnose/features/main/widgets/custom_top_appbar.dart';
import 'package:palm_diagnose/core/constants/gradient_scaffold.dart';
import 'package:intl/intl.dart';

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

// ... (import tetap sama)

class _UserDetectionHistoryPageState extends State<UserDetectionHistoryPage>
    with SingleTickerProviderStateMixin {
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
    final double fixedImageHeight = 60;

    return GradientScaffold(
      appBar: CustomTopAppBar(
        upperTitle: "Riwayat",
        title: widget.displayName,
        profileImageUrl: widget.photoUrl,
        onTapProfile: () {},
        showBackButton: true,
        onBack: () => Navigator.pop(context),
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

          final items = docs.expand((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final filename = data['filename'] ?? '';
            final createdAt = data['createdAt']; // <== ambil dari firestore
            final date = (createdAt is Timestamp)
                ? createdAt.toDate()
                : DateTime.now(); // fallback kalau null

            final results = List<Map<String, dynamic>>.from(
              data['results'] ?? [],
            );
            return results.map(
              (result) => {
                'model': result['model'] ?? '-',
                'label': result['label'] ?? '-',
                'confidence': (result['confidence'] as num?)?.toDouble() ?? 0.0,
                'imageUrl':
                    'https://cad0f9e558f6.ngrok-free.app/uploads/$filename',
                'date': date, // kirim ke UI
              },
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 100),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final model = item['model'];
              final label = item['label'];
              final confidence = item['confidence'];
              final imageUrl = item['imageUrl'];
              final date = item['date'] as DateTime;
              final formattedDate = DateFormat(
                'dd MMM yyyy, HH:mm',
              ).format(date);

              final fade = CurvedAnimation(
                parent: _controller,
                curve: Curves.easeIn,
              );
              final scale = CurvedAnimation(
                parent: _controller,
                curve: Curves.decelerate,
              );
              final slide =
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                  );

              return FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position: slide,
                  child: ScaleTransition(
                    scale: scale,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
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
                                    : Colors.grey.withAlpha(26),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Row(
                              children: [
                                // Gambar kiri dengan tinggi tetap dan radius
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    bottomLeft: Radius.circular(14),
                                  ),
                                  child: SizedBox(
                                    width: 80,
                                    height: fixedImageHeight, // fix height
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      headers: const {
                                        'ngrok-skip-browser-warning': 'true',
                                      },
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Konten teks
                                Expanded(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight:
                                          fixedImageHeight, // agar teks nggak terlalu kecil
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            model,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Poppins',
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(text: 'Hasil: '),
                                                TextSpan(
                                                  text: label,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontFamily: 'Poppins',
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formattedDate,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? Colors.grey[500]
                                                      : Colors.grey[700],
                                                  fontFamily: 'Poppins',
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Chart badge
                        Positioned(
                          top: -10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(13),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 66,
                                  width: 66,
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
                                        pointShaderMapper:
                                            (data, _, color, rect) {
                                              return _getConfidenceGradient(
                                                confidence,
                                              ).createShader(rect);
                                            },
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                              isVisible: false,
                                            ),
                                        xValueMapper: (ChartData data, _) =>
                                            data.x,
                                        yValueMapper: (ChartData data, _) =>
                                            data.y,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${confidence.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface
                                        .withAlpha(178),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
