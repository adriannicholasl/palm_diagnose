import 'dart:typed_data';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:palm_diagnose/routers/app_routes.dart';
import 'package:palm_diagnose/core/services/detection_service.dart';

class DetectPage extends StatefulWidget {
  final File? imageFile; // For mobile
  final Uint8List? imageBytesWeb; // For web

  const DetectPage({Key? key, this.imageFile, this.imageBytesWeb})
    : super(key: key);

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startPrediction();
  }

  Future<void> _startPrediction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = kIsWeb
          ? await DetectionService.predictWeb(widget.imageBytesWeb!)
          : await DetectionService.predict(widget.imageFile!);

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.detectResult,
        arguments: {
          'imageFile': widget.imageFile,
          'imageBytesWeb': widget.imageBytesWeb,
          'results': results,
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mendeteksi Gambar...')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '❌ $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
            : const Text('Selesai memproses gambar.'),
      ),
    );
  }
}
