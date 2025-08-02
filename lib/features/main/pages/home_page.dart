import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/constants/gradient_scaffold.dart';
import 'package:palm_diagnose/core/utils/user_utils.dart';
import 'package:palm_diagnose/core/utils/detect_navigator.dart';
import 'package:palm_diagnose/features/main/widgets/custom_buttom_bar.dart';
import 'package:palm_diagnose/features/main/widgets/custom_top_appbar.dart';
import 'package:palm_diagnose/features/admin/pages/admin_dashboard_page.dart';
import 'package:palm_diagnose/features/admin/pages/data_user.dart';
import 'package:palm_diagnose/features/user/pages/user_dashboard_page.dart';
import 'package:palm_diagnose/features/user/pages/history_detect_page.dart';
import 'package:palm_diagnose/features/profile/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final String role;
  final int initialIndex;

  const HomePage({super.key, required this.role, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _displayName = '';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final result = await UserUtils.loadUserInfo(widget.role);
    setState(() {
      _displayName = result['name'];
      _photoUrl = result['photoUrl'];
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    DetectNavigator.startDetection(context);
  }

  List<Widget> _buildPages() {
    final isAdmin = widget.role == "admin";

    return [
      GradientScaffold(
        appBar: CustomTopAppBar(
          upperTitle: "Selamat Datang",
          title: _displayName,
          profileImageUrl: _photoUrl,
          onTapProfile: () {
            setState(() {
              _selectedIndex = 3;
            });
          },
        ),
        body: isAdmin ? const AdminDashboardPage() : const UserHomePage(),
      ),
      isAdmin
          ? GradientScaffold(
              appBar: CustomTopAppBar(
                upperTitle: "Kelola",
                title: "Data User",
                profileImageUrl: _photoUrl,
                onTapProfile: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),
              body: const DataUserPage(),
            )
          : GradientScaffold(
              appBar: CustomTopAppBar(
                upperTitle: "Riwayat",
                title: _displayName,
                profileImageUrl: _photoUrl,
                onTapProfile: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),
              body: HistoryDetectPage(displayName: _displayName),
            ),
      GradientScaffold(
        appBar: CustomTopAppBar(
          upperTitle: "Fitur",
          title: "Belum Tersedia",
          profileImageUrl: _photoUrl,
          onTapProfile: () {
            setState(() {
              _selectedIndex = 3;
            });
          },
        ),
        body: const Center(
          child: Text(
            "Fitur ini akan hadir di versi berikutnya.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      GradientScaffold(
        appBar: CustomTopAppBar(
          upperTitle: "Akun",
          title: _displayName,
          profileImageUrl: _photoUrl,
          onTapProfile: () {}, // sudah di halaman profile
        ),
        body: const ProfilePage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavBarCurvedFb1(
        currentIndex: _selectedIndex,
        onItemTapped: _onTabSelected,
        onFabPressed: _onFabPressed,
      ),
    );
  }
}
