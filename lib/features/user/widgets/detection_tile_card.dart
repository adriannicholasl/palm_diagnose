import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetectionTileCard extends StatelessWidget {
  final String diseaseName;
  final String modelUsed;
  final double confidence;
  final String? imageUrl;
  final String? displayName;
  final VoidCallback onTap;
  final DateTime? createdAt;

  const DetectionTileCard({
    super.key,
    required this.diseaseName,
    required this.modelUsed,
    required this.confidence,
    required this.onTap,
    this.imageUrl,
    this.displayName,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final hasDisplayName = displayName?.isNotEmpty ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null
                    ? const Icon(Icons.image, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasDisplayName)
                      Text(
                        displayName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    Text(
                      diseaseName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Model: $modelUsed | Akurasi: ${confidence.toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy – HH:mm').format(createdAt!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
