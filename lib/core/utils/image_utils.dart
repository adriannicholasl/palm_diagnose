import 'dart:typed_data';
import 'dart:ui' as ui;

class ImageUtils {
  static Future<ui.Image> loadImageFromBytes(Uint8List imgBytes) async {
    final codec = await ui.instantiateImageCodec(imgBytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  // Tambahkan utilitas lain sesuai kebutuhan
}
