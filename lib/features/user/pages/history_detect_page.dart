import 'dart:math';
import 'package:palm_diagnose/global.dart';

class HistoryDetectPage extends StatelessWidget {
  final String displayName;

  const HistoryDetectPage({super.key, required this.displayName});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text("User belum login."));
    }

    final firebaseService = FirebaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: firebaseService.getUserDetections(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint("❌ Firestore error: ${snapshot.error}");
          return const Center(
            child: Text("❌ Terjadi kesalahan saat memuat data."),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text("📭 Belum ada hasil deteksi."));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            try {
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
                      'https://cad0f9e558f6.ngrok-free.app/uploads/$filename';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        headers: const {
                          'ngrok-skip-browser-warning':
                              'true', // ⬅️ WAJIB agar tidak kena halaman warning
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                      title: Text("Model: $model"),
                      subtitle: Text(
                        "Label: $label\nConfidence: ${confidence.toStringAsFixed(1)}%",
                      ),
                    ),
                  );
                }).toList(),
              );
            } catch (e) {
              // ⛔ Jika error parsing satu dokumen, tampilkan warning dan skip
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "⚠️ Gagal menampilkan hasil deteksi tertentu.",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
          },
        );
      },
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
