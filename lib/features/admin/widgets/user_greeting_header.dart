import 'package:flutter/material.dart';

class UserGreetingHeader extends StatelessWidget {
  final String displayName;

  const UserGreetingHeader({super.key, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Halo, $displayName\nDaftar Semua Pengguna:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
