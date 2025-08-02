import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyStateAnimation extends StatelessWidget {
  final String title;
  final String description;

  const EmptyStateAnimation({
    super.key,
    this.title = 'Oops!',
    this.description = 'Maaf halaman ini masih dikembangkan',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animations/error_404.json',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
