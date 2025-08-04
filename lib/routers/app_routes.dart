import 'package:flutter/material.dart';

// AUTH
import 'package:palm_diagnose/features/auth/pages/signin_page.dart';
import 'package:palm_diagnose/features/auth/pages/signup_page.dart';
import 'package:palm_diagnose/features/auth/pages/auth_gate.dart';

// DETECTION
import 'package:palm_diagnose/features/detect/pages/detect_page.dart';
import 'package:palm_diagnose/features/detect/pages/detection_result_page.dart';
import 'package:palm_diagnose/core/services/detection_service.dart';

// USER
import 'package:palm_diagnose/features/user/pages/history_detect_page.dart';
import 'package:palm_diagnose/features/user/pages/detail_history_page.dart';

// ADMIN
import 'package:palm_diagnose/features/admin/pages/user_detection_history_page.dart';
import 'package:palm_diagnose/features/admin/pages/detail_history_page.dart'
    as admin_detail;

class AppRoutes {
  // ─── Route Name ─────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String authGate = '/auth';

  static const String detect = '/user/detect';
  static const String detectResult = '/user/detect/result';

  static const String history = '/user/history';
  static const String detailHistory = '/history/detail';

  static const String adminUserHistory = '/admin/user/history';
  static const String adminDetailHistory = '/admin/user/history/detail';

  // ─── Route Mapping ──────────────────────
  static Map<String, WidgetBuilder> routes = {
    login: (_) => const SignInScreen(),
    register: (_) => const SignUpScreen(),
    authGate: (_) => const AuthGate(),

    // 🔍 Halaman Deteksi
    detect: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['imageFile'] != null) {
        return DetectPage(imageFile: args['imageFile']);
      } else {
        return const Scaffold(
          body: Center(child: Text("Data gambar tidak ditemukan")),
        );
      }
    },

    // // ✅ Hasil Deteksi AWAL
    detectResult: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['results'] != null) {
        return DetectionResultPage(
          imageFile: args['imageFile'],
          imageBytesWeb: args['imageBytesWeb'],
          results: (args['results'] as List)
              .map(
                (e) => e is DetectionResult
                    ? e
                    : DetectionResult.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
          filename: args['filename'] ?? 'noname.jpg',
        );
      } else {
        return const Scaffold(
          body: Center(child: Text("Data hasil deteksi tidak ditemukan")),
        );
      }
    },

    // 📜 History untuk USER
    history: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['displayName'] != null) {
        return HistoryDetectPage(displayName: args['displayName']);
      } else {
        return const Scaffold(
          body: Center(child: Text("Nama pengguna tidak ditemukan")),
        );
      }
    },

    // 📄 Detail History untuk USER
    detailHistory: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        return DetailHistoryPage(
          imageUrl: args['imageUrl'],
          label: args['label'],
          model: args['model'],
          confidence: args['confidence'],
          date: args['date'],
          location: args['location'],
        );
      } else {
        return const Scaffold(
          body: Center(child: Text("Data history tidak ditemukan")),
        );
      }
    },

    // 👤 Riwayat Deteksi 1 User (ADMIN)
    adminUserHistory: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> &&
          args['uid'] != null &&
          args['displayName'] != null) {
        return UserDetectionHistoryPage(
          uid: args['uid'],
          displayName: args['displayName'],
          photoUrl: args['photoUrl'], // optional
        );
      } else {
        return const Scaffold(
          body: Center(child: Text("Data pengguna tidak lengkap")),
        );
      }
    },

    // 📄 Detail History Deteksi (ADMIN)
    adminDetailHistory: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        return admin_detail.DetailHistoryPage(
          imageUrl: args['imageUrl'],
          label: args['label'],
          model: args['model'],
          confidence: args['confidence'],
          date: args['date'],
          location: args['location'],
          data: {},
        );
      } else {
        return const Scaffold(
          body: Center(child: Text("Data history tidak ditemukan")),
        );
      }
    },
  };
}
