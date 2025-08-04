import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palm_diagnose/core/constants/gradient_scaffold.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:palm_diagnose/features/admin/widgets/shimmer/detection_history_item_shimmer.dart';
import 'package:palm_diagnose/routers/app_routes.dart';
import 'package:palm_diagnose/features/admin/widgets/search.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HistoryDetectPage extends StatefulWidget {
  final String displayName;

  const HistoryDetectPage({super.key, required this.displayName});

  @override
  State<HistoryDetectPage> createState() => _HistoryDetectPageState();
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}

class _HistoryDetectPageState extends State<HistoryDetectPage>
    with SingleTickerProviderStateMixin {
  final firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("User belum login."));
    }

    return GradientScaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchInput(
              textController: _searchController,
              hintText: 'Cari label, model, atau tanggal (mis. 2 Aug, 2025)...',
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firebaseService.getUserDetections(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 100),
                    itemCount: 5,
                    itemBuilder: (_, __) => const DetectionHistoryItemShimmer(),
                  );
                }

                if (snapshot.hasError) {
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

                final items = docs.expand((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final filename = data['filename'] ?? '';
                  final locationName =
                      data['location']?['name'] ??
                      ''; // ✅ ambil lokasi jika ada
                  final createdAt = data['createdAt'];
                  final date = (createdAt is Timestamp)
                      ? createdAt.toDate()
                      : DateTime.now();

                  final results = List<Map<String, dynamic>>.from(
                    data['results'] ?? [],
                  );

                  return results.map(
                    (result) => {
                      'model': result['model'],
                      'label': result['label'],
                      'confidence':
                          (result['confidence'] as num?)?.toDouble() ?? 0.0,
                      'imageUrl':
                          'https://f72cc3896f6e.ngrok-free.app/uploads/$filename',
                      'date': date,
                      'location': locationName, // ✅ sertakan lokasi
                    },
                  );
                }).toList();

                final filteredItems = items.where((item) {
                  final label = (item['label'] ?? '').toString().toLowerCase();
                  final model = (item['model'] ?? '').toString().toLowerCase();
                  final date = item['date'] as DateTime;

                  final query = _searchQuery.toLowerCase();

                  // Format tanggal ke berbagai versi
                  final dateFormats = [
                    DateFormat('dd MMM yyyy'), // 02 Aug 2025
                    DateFormat('d MMM yyyy'), // 2 Aug 2025
                    DateFormat('MMMM d, yyyy'), // August 2, 2025
                    DateFormat('d MMMM yyyy'), // 2 August 2025
                    DateFormat('dd/MM/yyyy'), // 02/08/2025
                    DateFormat('d/M/yyyy'), // 2/8/2025
                    DateFormat('yyyy'), // 2025
                    DateFormat('MMM'), // Aug
                  ];

                  final dateStrings = dateFormats.map(
                    (f) => f.format(date).toLowerCase(),
                  );

                  return label.contains(query) ||
                      model.contains(query) ||
                      dateStrings.any(
                        (formattedDate) => formattedDate.contains(query),
                      );
                }).toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text("🔍 Tidak ada hasil yang cocok."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 100),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
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
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeOut,
                          ),
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
                              // 👉 Card utama
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.detailHistory,
                                    arguments: {
                                      'imageUrl': imageUrl,
                                      'label': label,
                                      'model': model,
                                      'confidence': confidence,
                                      'date': date,
                                      'location':
                                          item['location'] ??
                                          '', // ✅ pastikan dikirim
                                    },
                                  );
                                },
                                child: Container(
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
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(14),
                                          bottomLeft: Radius.circular(14),
                                        ),
                                        child: SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            headers: const {
                                              'ngrok-skip-browser-warning':
                                                  'true',
                                            },
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.broken_image),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                model,
                                                style: theme
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Poppins',
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    const TextSpan(
                                                      text: 'Hasil: ',
                                                    ),
                                                    TextSpan(
                                                      text: label,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                    ],
                                  ),
                                ),
                              ),

                              // 🔘 Chart Badge di luar card
                              Positioned(
                                top: -8,
                                right: 20,
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
                                                ChartData(
                                                  'Confidence',
                                                  confidence,
                                                ),
                                              ],
                                              maximumValue: 100,
                                              radius: '90%',
                                              innerRadius: '75%',
                                              cornerStyle:
                                                  CornerStyle.bothCurve,
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
                                              xValueMapper: (data, _) => data.x,
                                              yValueMapper: (data, _) => data.y,
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
          ),
        ],
      ),
    );
  }
}

// ✅ Radial Chart
class CustomRadialChart extends StatelessWidget {
  final double value;

  const CustomRadialChart({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 40),
      painter: RadialChartPainter(value),
    );
  }
}

class RadialChartPainter extends CustomPainter {
  final double value;

  RadialChartPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 4.0;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final foregroundPaint = Paint()
      ..color = value >= 70
          ? Colors.green
          : value >= 40
          ? Colors.orange
          : Colors.red
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final sweepAngle = 2 * pi * (value / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
