import 'dart:io';
import 'package:flutter/material.dart';

// AUTH
import 'package:palm_diagnose/features/auth/pages/login_page.dart';
import 'package:palm_diagnose/features/auth/pages/register_page.dart';
import 'package:palm_diagnose/features/auth/pages/auth_gate.dart';

// ADMIN
import 'package:palm_diagnose/features/admin/pages/admin_dashboard_page.dart';

// USER
import 'package:palm_diagnose/features/user/pages/user_home_page.dart';
// import 'package:palm_diagnose/features/user/history/pages/history_page.dart';

import 'package:palm_diagnose/features/user/detection/pages/detect_page.dart';
import 'package:palm_diagnose/features/user/detection/pages/detection_result_page.dart';
import 'package:palm_diagnose/features/user/detection/controllers/detection_service.dart'; // ⬅️ Import model DetectionResult

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String authGate = '/auth';
  static const String adminDashboard = '/admin/dashboard';
  static const String userHome = '/user/home';

  static const String detect = '/user/detect';
  static const String detectResult = '/user/detect/result';

  static const String history = '/user/history';
  static const String profile = '/user/profile';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const SignInScreen(),
    register: (_) => const SignUpScreen(),
    authGate: (_) => const AuthGate(),
    adminDashboard: (_) => const AdminDashboardPage(),
    userHome: (_) => const UserHomePage(),

    // 🔁 Halaman deteksi, butuh imageFile
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

    // 🔁 Halaman hasil deteksi, butuh imageFile + List<DetectionResult>
    detectResult: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> &&
          args['imageFile'] != null &&
          args['results'] != null &&
          args['results'] is List<DetectionResult>) {
        return DetectionResultPage(
          imageFile: args['imageFile'],
          results: args['results'] as List<DetectionResult>, // ✅ ini benar
        );
      } else {
        return const Scaffold(
          body: Center(child: Text("Data hasil deteksi tidak ditemukan")),
        );
      }
    },

    // history: (_) => const HistoryPage(), // aktifkan nanti
  };
}
