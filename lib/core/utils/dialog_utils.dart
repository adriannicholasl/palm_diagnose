import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DialogUtils {
  static void showImageSourceActionSheet(
    BuildContext context,
    Function(ImageSource source) onImageSourceSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih Sumber Gambar',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Silakan pilih dari kamera atau galeri',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                _buildOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Ambil dari Kamera',
                  onTap: () {
                    Navigator.of(context).pop();
                    onImageSourceSelected(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                _buildOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: 'Pilih dari Galeri',
                  onTap: () {
                    Navigator.of(context).pop();
                    onImageSourceSelected(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 16),
                Divider(
                  thickness: 1,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: colorScheme.error),
                  label: Text(
                    'Batal',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceVariant.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 24, color: colorScheme.primary),
              const SizedBox(width: 16),
              Text(label, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
