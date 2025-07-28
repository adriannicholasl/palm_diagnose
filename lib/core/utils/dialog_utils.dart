import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class DialogUtils {
  /// Menampilkan bottom sheet untuk memilih sumber gambar
  static void showImageSourceActionSheet(
    BuildContext context,
    Function(ImageSource source) onImageSourceSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  onImageSourceSelected(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  onImageSourceSelected(ImageSource.gallery);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Batal'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Optional: Menampilkan dialog info umum
  static void showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }
}
