import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';

class DetectionStatCardsRow extends StatefulWidget {
  final VoidCallback onStatTap;
  final VoidCallback onDetectTap;
  final String uid; // Tambahkan uid

  const DetectionStatCardsRow({
    super.key,
    required this.onStatTap,
    required this.onDetectTap,
    required this.uid,
  });

  @override
  State<DetectionStatCardsRow> createState() => _DetectionStatCardsRowState();
}

class _DetectionStatCardsRowState extends State<DetectionStatCardsRow> {
  int totalDeteksi = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTotalDeteksi();
  }

  Future<void> _loadTotalDeteksi() async {
    final total = await FirebaseService().getDetectionCountByUser(widget.uid);
    setState(() {
      totalDeteksi = total;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final subtitleText = isLoading ? 'Memuat...' : '$totalDeteksi total';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _CardFb1(
              text: "Hasil Deteksi",
              subtitle: subtitleText,
              imageUrl:
                  "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/illustrations%2Fundraw_Designer_re_5v95%201.png?alt=media&token=5d053bd8-d0ea-4635-abb6-52d87539b7e",
              onPressed: widget.onStatTap,
              useGradient: false,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _CardFb1(
              text: "Deteksi",
              subtitle: "Akses cepat",
              imageUrl:
                  "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/illustrations%2Fundraw_Designer_re_5v95%201.png?alt=media&token=5d053bd8-d0ea-4635-abb6-52d87539b7e",
              onPressed: widget.onDetectTap,
              useGradient: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFb1 extends StatelessWidget {
  final String text;
  final String imageUrl;
  final String subtitle;
  final VoidCallback onPressed;
  final bool useGradient;

  const _CardFb1({
    required this.text,
    required this.imageUrl,
    required this.subtitle,
    required this.onPressed,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: useGradient
              ? null
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          gradient: useGradient
              ? const LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12.5),
          boxShadow: [
            if (!isDark && !useGradient)
              BoxShadow(
                offset: const Offset(2, 6),
                blurRadius: 10,
                color: Colors.grey.withAlpha(26),
              ),
          ],
        ),
        child: Column(
          children: [
            Image.network(imageUrl, height: 70),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: useGradient ? Colors.white : null,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: useGradient ? Colors.white.withAlpha(230) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
