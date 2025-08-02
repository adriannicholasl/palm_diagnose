import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:palm_diagnose/features/detect/pages/detect_page.dart';
import 'package:palm_diagnose/core/utils/dialog_utils.dart';

class DetectNavigator {
  static void startDetection(BuildContext context) {
    DialogUtils.showImageSourceActionSheet(context, (source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        if (!context.mounted) return;

        if (kIsWeb) {
          final Uint8List imageBytes = await pickedFile.readAsBytes();
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (_) => DetectPage(imageBytesWeb: imageBytes),
            ),
          );
        } else {
          final io.File file = io.File(pickedFile.path);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetectPage(imageFile: file)),
          );
        }
      }
    });
  }
}
