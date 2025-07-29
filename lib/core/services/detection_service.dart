import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // ⬅️ Untuk web
import 'package:http/http.dart' as http;

class DetectionResult {
  final String model;
  final String label;
  final double confidence;

  DetectionResult({
    required this.model,
    required this.label,
    required this.confidence,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      model: json['model_name'] ?? '-', // Pastikan sesuai backend
      label: json['predicted_label'] ?? '-',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DetectionService {
  static const String _baseUrl = "https://d8a7804a7815.ngrok-free.app/predict";

  // 🔍 Untuk Android/iOS/Desktop
  static Future<List<DetectionResult>> predict(File imageFile) async {
    final uri = Uri.parse(_baseUrl);

    try {
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final resultList = data['results'] as List;
        return resultList
            .map((item) => DetectionResult.fromJson(item))
            .toList();
      } else {
        throw HttpException(
          "Gagal mendeteksi gambar: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat prediksi gambar: $e");
    }
  }

  // 🌐 Untuk Web
  static Future<List<DetectionResult>> predictWeb(Uint8List imageBytes) async {
    final uri = Uri.parse(_baseUrl);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'web_$timestamp.jpg';

      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: filename, // ✅ nama unik
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('📩 Status: ${response.statusCode}');
      print('📩 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final resultList = data['results'] as List;
        return resultList
            .map((item) => DetectionResult.fromJson(item))
            .toList();
      } else {
        throw HttpException(
          "Gagal mendeteksi gambar (web): ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat prediksi gambar (web): $e");
    }
  }
}
