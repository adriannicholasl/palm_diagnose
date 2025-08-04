// detection_result_page.dart (FINAL REFACTORED VERSION)

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:palm_diagnose/core/services/detection_service.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:palm_diagnose/core/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geolocator/geolocator.dart' as geo;

class DetectionResultPage extends StatefulWidget {
  final File? imageFile;
  final Uint8List? imageBytesWeb;
  final List<DetectionResult> results;
  final String filename;

  const DetectionResultPage({
    super.key,
    this.imageFile,
    this.imageBytesWeb,
    required this.results,
    required this.filename,
  });

  @override
  State<DetectionResultPage> createState() => _DetectionResultPageState();
}

class _DetectionResultPageState extends State<DetectionResultPage> {
  final FirebaseService _firebaseService = FirebaseService();
  geo.Position? _lastPosition;
  String? _locationName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (AppLocationState.isAvailable) {
      _lastPosition = AppLocationState.position;
      _locationName = AppLocationState.locationName;
    }
  }

  String getMostConfidentLabel() {
    if (widget.results.isEmpty) return '';
    widget.results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return widget.results.first.label;
  }

  LinearGradient _getGradient(double confidence) {
    if (confidence >= 70) {
      return const LinearGradient(
        colors: [Color(0xFFA2EBA6), Color(0xFF28782C)],
      );
    } else if (confidence >= 40) {
      return const LinearGradient(
        colors: [Color(0xFFE6D969), Color(0xFFF7BC25)],
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFFF77270), Color(0xFFCB2626)],
      );
    }
  }

  String _getConfidenceStatus(double value) {
    if (value >= 70) return '🟢 Sangat Yakin';
    if (value >= 40) return '🟠 Cukup Yakin';
    return '🔴 Kurang Yakin';
  }

  Future<void> _saveToFirestore() async {
    if (_lastPosition == null) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: 'GPS Tidak Aktif',
        desc: 'Aktifkan GPS terlebih dahulu sebelum menyimpan.',
        btnOkText: 'Buka Pengaturan',
        btnCancelText: 'Batal',
        btnOkOnPress: () async {
          final pos = await LocationService.getCurrentLocation();
          if (pos != null) {
            final name = await LocationService.getAddressFromPosition(pos);
            if (!mounted) return;
            setState(() {
              _lastPosition = pos;
              _locationName = name;
            });
            AppLocationState.update(pos, name);
            _saveToFirestore(); // Retry
          }
        },
      ).show();
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User tidak login");

      await _firebaseService.saveDetectionResults(
        uid: uid,
        filename: widget.filename,
        results: widget.results.map((e) => e.toJson()).toList(),
        location: {
          'latitude': _lastPosition!.latitude,
          'longitude': _lastPosition!.longitude,
          'name': _locationName ?? '',
        },
      );

      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: 'Berhasil',
        desc: 'Hasil deteksi berhasil disimpan.',
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Gagal',
        desc: 'Terjadi kesalahan saat menyimpan hasil.',
        btnOkOnPress: () {},
      ).show();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildRadialChart(DetectionResult result) {
    return Column(
      children: [
        SizedBox(
          height: 90,
          width: 90,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            series: <CircularSeries>[
              RadialBarSeries<_ChartData, String>(
                dataSource: [_ChartData('Confidence', result.confidence)],
                maximumValue: 100,
                radius: '100%',
                innerRadius: '75%',
                cornerStyle: CornerStyle.bothCurve,
                trackColor: const Color.fromARGB(168, 196, 196, 196),
                pointShaderMapper: (_, __, ___, rect) =>
                    _getGradient(result.confidence).createShader(rect),
                xValueMapper: (data, _) => data.x,
                yValueMapper: (data, _) => data.y,
              ),
            ],
            annotations: [
              CircularChartAnnotation(
                widget: Text(
                  '${result.confidence.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getConfidenceStatus(result.confidence),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Metode: ${result.model}', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDiseaseInfo(String label) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('disease_info')
          .doc(label)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Informasi penyakit tidak ditemukan.');
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🦠 Deskripsi Penyakit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(data['description'] ?? '-'),
            const SizedBox(height: 16),
            const Text(
              '💊 Rekomendasi Penanganan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(data['treatment'] ?? '-'),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = kIsWeb
        ? (widget.imageBytesWeb != null
              ? Image.memory(widget.imageBytesWeb!, fit: BoxFit.cover)
              : const Icon(Icons.broken_image))
        : (widget.imageFile != null
              ? Image.file(widget.imageFile!, fit: BoxFit.cover)
              : const Icon(Icons.broken_image));

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 240,
                automaticallyImplyLeading: false, // 👈 tambahkan ini
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(tag: widget.filename, child: image),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🩺 Hasil Deteksi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '🗓️ Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                      ),
                      if (_locationName != null)
                        Text('📍 Lokasi: $_locationName'),
                      const SizedBox(height: 12),
                      ...widget.results.map((r) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('🧪 ${r.model} → ${r.label}'),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: widget.results
                            .map((r) => _buildRadialChart(r))
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                      _buildDiseaseInfo(getMostConfidentLabel()),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 36,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveToFirestore,
              icon: const Icon(Icons.save),
              label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Hasil'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final String x;
  final double y;
  _ChartData(this.x, this.y);
}
