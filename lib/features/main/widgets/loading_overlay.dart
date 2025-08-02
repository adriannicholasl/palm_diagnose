import 'package:flutter/material.dart';
import 'loading_animation.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        child: const LoadingAnimation(size: 160),
      ),
    );
  }
}
