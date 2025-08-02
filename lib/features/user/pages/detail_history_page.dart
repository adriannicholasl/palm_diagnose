import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palm_diagnose/core/constants/gradient_scaffold.dart';
import 'package:palm_diagnose/features/main/widgets/custom_top_appbar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';

class DetailHistoryPage extends StatelessWidget {
  final String imageUrl;
  final String label;
  final String model;
  final double confidence;
  final DateTime date;
  final FirebaseService firebaseService = FirebaseService();

  DetailHistoryPage({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.model,
    required this.confidence,
    required this.date,
  });

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

    return GradientScaffold(
      appBar: CustomTopAppBar(
        upperTitle: 'Detail',
        title: 'Hasil Deteksi',
        showBackButton: true,
        onTapProfile: () {},
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: firebaseService.getDiseaseInfo(label),
        builder: (context, snapshot) {
          final diseaseInfo = snapshot.data ?? {};
          final deskripsi = diseaseInfo['deskripsi'] ?? 'Tidak ada deskripsi.';
          final treatment =
              diseaseInfo['treatment'] ?? 'Tidak ada rekomendasi.';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 200,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Metode Deteksi: $model',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tanggal: ${DateFormat('dd MMMM yyyy, HH:mm').format(date)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  height: 160,
                  width: 160,
                  child: SfCircularChart(
                    margin: EdgeInsets.zero,
                    series: <CircularSeries>[
                      RadialBarSeries<_ChartData, String>(
                        dataSource: [_ChartData('Confidence', confidence)],
                        maximumValue: 100,
                        radius: '100%',
                        innerRadius: '75%',
                        gap: '3%',
                        cornerStyle: CornerStyle.bothCurve,
                        trackOpacity: 0.15,
                        pointShaderMapper: (_, __, ___, rect) =>
                            _getConfidenceGradient(
                              confidence,
                            ).createShader(rect),
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: false,
                        ),
                        xValueMapper: (_ChartData data, _) => data.x,
                        yValueMapper: (_ChartData data, _) => data.y,
                      ),
                    ],
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(
                        widget: Text(
                          '${confidence.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Deskripsi Penyakit',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(deskripsi, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              Text(
                'Rekomendasi Penanganan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(treatment, style: theme.textTheme.bodyMedium),
            ],
          );
        },
      ),
    );
  }
}

class _ChartData {
  final String x;
  final double y;
  _ChartData(this.x, this.y);
}
