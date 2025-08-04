import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:palm_diagnose/core/services/user_service.dart';
import 'package:palm_diagnose/core/services/location_service.dart';
import 'package:palm_diagnose/features/admin/widgets/banner_carousel.dart';
import 'package:palm_diagnose/features/admin/widgets/news_carousel.dart';
import 'package:palm_diagnose/features/admin/widgets/callender.dart';
import 'package:palm_diagnose/features/admin/widgets/location_section.dart';
import 'package:palm_diagnose/features/admin/widgets/notification_stack_card.dart';
import 'package:palm_diagnose/features/admin/widgets/detection_stat_cards_row.dart';
import 'package:palm_diagnose/core/utils/detect_navigator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:palm_diagnose/features/main/pages/home_page.dart';

import 'package:palm_diagnose/features/admin/widgets/shimmer/banner_carousel_shimmer.dart';
import 'package:palm_diagnose/features/admin/widgets/shimmer/calender_shimmer.dart';
import 'package:palm_diagnose/features/admin/widgets/shimmer/detection_stat_cards_row_shimmer.dart';
import 'package:palm_diagnose/features/admin/widgets/shimmer/notification_stack_card_shimmer.dart';
import 'package:palm_diagnose/features/admin/widgets/shimmer/news_carousel_shimmer.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final userService = UserService();
  final locationService = LocationService();
  DateTime selectedDate = DateTime.now();
  String _locationText = 'Belum tersedia';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeDateFormatting('id_ID'),
      builder: (context, localeSnapshot) {
        if (localeSnapshot.connectionState != ConnectionState.done) {
          return _buildShimmerLayout();
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: userService.getCurrentUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLayout();
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Gagal memuat data pengguna'));
            }

            final uid = snapshot.data!['uid'] ?? '';
            final role = snapshot.data!['role'] ?? 'user';
            return _buildContent(uid: uid, role: role);
          },
        );
      },
    );
  }

  Widget _buildContent({required String uid, required String role}) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationSection(
              locationName: _locationText,
              onDetectLocation: _detectLocation,
            ),
            const SizedBox(height: 20),
            SimpleCalendarRow(selectedDate: selectedDate),
            const SizedBox(height: 20),
            const BannerCarousel(),
            const SizedBox(height: 24),
            DetectionStatCardsRow(
              uid: uid,
              onStatTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomePage(role: role, initialIndex: 1),
                  ),
                );
              },
              onDetectTap: () {
                DetectNavigator.startDetection(context);
              },
            ),
            const SizedBox(height: 35),
            const NotificationStackCard(),
            const SizedBox(height: 20),
            const NewsCarousel(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLayout() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationSection(
              locationName: "Memuat lokasi...",
              onDetectLocation: () {},
            ),
            const SizedBox(height: 20),
            const SimpleCalendarRowShimmer(),
            const SizedBox(height: 20),
            const BannerCarouselShimmer(),
            const SizedBox(height: 24),
            const DetectionStatCardsRowShimmer(),
            const SizedBox(height: 35),
            const NotificationStackCardShimmer(),
            const SizedBox(height: 20),
            const NewsCarouselShimmer(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _detectLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      final address = await LocationService.getAddressFromPosition(position);
      if (!mounted) return;
      setState(() => _locationText = address);
      AppLocationState.update(position, address);
    } else {
      if (!mounted) return;
      setState(() => _locationText = '❌ Lokasi tidak tersedia');
      _showLocationErrorDialog();
    }
  }

  void _showLocationErrorDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Lokasi Tidak Terdeteksi',
      desc: 'GPS atau izin lokasi tidak aktif. Ingin coba lagi?',
      btnCancelText: 'Tidak',
      btnOkText: 'Coba Lagi',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final retryPos = await LocationService.getCurrentLocation();
        if (retryPos != null) {
          final address = await LocationService.getAddressFromPosition(
            retryPos,
          );
          if (!mounted) return;
          setState(() => _locationText = address);
          AppLocationState.update(retryPos, address);
        }
      },
    ).show();
  }
}
