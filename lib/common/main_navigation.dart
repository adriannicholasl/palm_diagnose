import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:palm_diagnose/shared/widgets/custom_buttom_bar.dart';
import 'package:palm_diagnose/features/admin/pages/admin_dashboard_page.dart';
import 'package:palm_diagnose/features/admin/pages/data_user.dart';
import 'package:palm_diagnose/features/user/pages/user_home_page.dart';
import 'package:palm_diagnose/features/user/pages/history_detect_page.dart';
import 'package:palm_diagnose/features/user/detection/pages/detect_page.dart';
import 'package:palm_diagnose/features/profile/pages/profile_page.dart';
import 'package:palm_diagnose/core/utils/dialog_utils.dart';

class MainNavigation extends StatefulWidget {
  final String role;

  const MainNavigation({Key? key, required this.role}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    DialogUtils.showImageSourceActionSheet(
      context,
      (source) async {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: source,
          imageQuality: null, // ⛔ Jangan dikompres
          maxWidth: null,
          maxHeight: null,
          preferredCameraDevice: CameraDevice.rear,
        );

        if (pickedFile != null) {
          final file = File(pickedFile.path);
          debugPrint('📸 Gambar dipilih: ${file.path}');
          debugPrint('📏 Ukuran file: ${await file.length()} bytes');

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetectPage(imageFile: file)),
          );
        } else {
          debugPrint("⚠️ Tidak ada gambar dipilih");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == "admin";

    final List<Widget> _pages = [
      isAdmin ? const AdminDashboardPage() : const UserHomePage(),
      isAdmin ? const DataUserPage() : const HistoryDetectPage(),
      const Placeholder(), // Tombol ke-4 bisa diganti
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBarCurvedFb1(
        currentIndex: _selectedIndex,
        onItemTapped: _onTabSelected,
        onFabPressed: _onFabPressed,
      ),
    );
  }
}
