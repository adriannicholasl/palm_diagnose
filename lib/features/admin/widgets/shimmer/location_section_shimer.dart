import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LocationSectionShimmer extends StatelessWidget {
  const LocationSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 30, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: 60,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 6),
                  ),
                  Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 36,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade300,
            ),
            alignment: Alignment.center,
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(height: 12, width: 50, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
