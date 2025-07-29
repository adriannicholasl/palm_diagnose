import 'package:palm_diagnose/global.dart';
import 'dart:math';

class HistoryDetectPage extends StatelessWidget {
  const HistoryDetectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseService.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("User belum login."));
    }

    final firebaseService = FirebaseService();

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Deteksi Anda:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firebaseService.getUserDetections(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Terjadi kesalahan saat memuat data."),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  print(snapshot.data!.docs);
                  return const Center(child: Text("Belum ada hasil deteksi."));
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

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withAlpha(
                                (0.95 * 255).toInt(),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withAlpha(
                                    (0.95 * 255).toInt(),
                                  ), // 0.95 = 95% transparan
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 48,
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          model,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          label,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            CustomRadialChart(
                                              value: confidence,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${confidence.toStringAsFixed(1)}%",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }
}

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
      ..color = Colors.green
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
