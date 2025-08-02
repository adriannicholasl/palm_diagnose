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

  Map<String, dynamic> toJson() {
    return {'model': model, 'label': label, 'confidence': confidence};
  }
}

class DetectionResponse {
  final String filename;
  final List<DetectionResult> results;

  DetectionResponse({required this.filename, required this.results});
}

class DetectionService {
  static const String _baseUrl = "https://cad0f9e558f6.ngrok-free.app/predict";

  // 🔍 Untuk Android/iOS/Desktop
  static Future<DetectionResponse> predict(File imageFile) async {
    final uri = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DetectionResponse(
        filename: data['filename'],
        results: (data['results'] as List)
            .map((item) => DetectionResult.fromJson(item))
            .toList(),
      );
    } else {
      throw Exception(
        "Gagal mendeteksi gambar: ${response.statusCode} - ${response.body}",
      );
    }
  }

  static Future<DetectionResponse> predictWeb(Uint8List imageBytes) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'web_$timestamp.jpg';

    final uri = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: filename, // ini dikirim ke backend
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DetectionResponse(
        filename: data['filename'], // <-- ini diambil dari backend!
        results: (data['results'] as List)
            .map((item) => DetectionResult.fromJson(item))
            .toList(),
      );
    } else {
      throw Exception("Gagal deteksi (web): ${response.statusCode}");
    }
  }
}
