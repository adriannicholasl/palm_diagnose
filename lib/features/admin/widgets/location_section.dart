import 'package:flutter/material.dart';

class LocationSection extends StatelessWidget {
  final String locationName;
  final VoidCallback onDetectLocation;

  const LocationSection({
    super.key,
    required this.locationName,
    required this.onDetectLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 30, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  locationName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onDetectLocation,
            icon: const Icon(Icons.gps_fixed, size: 16),
            label: const Text("Deteksi"),
          ),
        ],
      ),
    );
  }
}
