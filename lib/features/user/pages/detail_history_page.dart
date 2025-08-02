import 'package:flutter/material.dart';

class DetailHistoryPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailHistoryPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Riwayat (User)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Data Deteksi User:\n${data.toString()}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
