import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DetectionStatCardsRowShimmer extends StatelessWidget {
  const DetectionStatCardsRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _shimmerCard()),
          const SizedBox(width: 20),
          Expanded(child: _shimmerCard()),
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.5),
        ),
      ),
    );
  }
}
