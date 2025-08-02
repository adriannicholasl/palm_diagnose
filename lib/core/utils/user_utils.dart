import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/services/user_service.dart';

class UserUtils {
  static Future<Map<String, dynamic>> loadUserInfo(String role) async {
    final user = UserService.currentUser;
    String name = role == 'admin' ? 'Admin' : 'User';
    String? photoUrl;

    if (user != null) {
      try {
        final data = await UserService().getCurrentUserData();
        name = data?['displayName'] ?? name;
        photoUrl = user.photoURL;
      } catch (e) {
        debugPrint('❌ Gagal memuat data user: $e');
      }
    }

    return {'name': name, 'photoUrl': photoUrl};
  }
}
