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

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final userService = UserService();
  final locationService = LocationService();
  DateTime selectedDate = DateTime.now();

  String _locationText = 'Belum tersedia';

  void _detectLocation() async {
    final position = await LocationService.getCurrentLocation();

    if (position != null) {
      final address = await LocationService.getAddressFromPosition(position);
      if (mounted) {
        setState(() {
          _locationText = address;
        });

        // ✅ Simpan ke state global
        AppLocationState.update(position, address);
      }
    } else {
      setState(() {
        _locationText = '❌ Lokasi tidak tersedia';
      });

      if (context.mounted) {
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
              if (context.mounted) {
                setState(() {
                  _locationText = address;
                });

                // ✅ Simpan ke state global juga
                AppLocationState.update(retryPos, address);
              }
            }
          },
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeDateFormatting('id_ID'),
      builder: (context, localeSnapshot) {
        if (localeSnapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: userService.getCurrentUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Gagal memuat data pengguna'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🧭 Lokasi Live
                  LocationSection(
                    locationName: _locationText,
                    onDetectLocation: _detectLocation,
                  ),

                  const SizedBox(height: 20),

                  /// 📅 Kalender Custom
                  SimpleCalendarRow(selectedDate: selectedDate),

                  const SizedBox(height: 20),

                  const BannerCarousel(),

                  const SizedBox(height: 24),

                  DetectionStatCardsRow(
                    onStatTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomePage(
                            role: 'admin',
                            initialIndex:
                                1, // <-- Ini langsung buka tab DataUserPage
                          ),
                        ),
                      );
                    },
                    onDetectTap: () {
                      DetectNavigator.startDetection(context);
                    },
                  ),
                  const SizedBox(height: 35),

                  /// 📷 Quick Action Button - Deteksi
                  const NotificationStackCard(),

                  const SizedBox(height: 20),

                  /// 📰 Berita Terkait
                  const NewsCarousel(),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
