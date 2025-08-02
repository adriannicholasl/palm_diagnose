import 'dart:math';
import 'package:flutter/material.dart';

class NotificationStackCard extends StatefulWidget {
  const NotificationStackCard({super.key});

  @override
  State<NotificationStackCard> createState() => _NotificationStackCardState();
}

class _NotificationStackCardState extends State<NotificationStackCard> {
  bool isExpanded = false;

  final List<_NotifItem> items = [
    _NotifItem(
      title: "Model AI diperbarui",
      subtitle: "Versi terbaru dirilis 1 Agustus 2025",
      icon: Icons.notifications_active_outlined,
    ),
    _NotifItem(
      title: "Lengkapi Data Anda",
      subtitle: "Profil pengguna belum lengkap",
      icon: Icons.info_outline_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => isExpanded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Transform.rotate(
            angle: pi,
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                final scale = isExpanded
                    ? 1.0
                    : 1 - (items.length - 1.0 * index) / 25;

                return AnimatedAlign(
                  duration: const Duration(milliseconds: 450),
                  alignment: Alignment.center,
                  heightFactor: isExpanded ? 1.05 : 0.5,
                  child: AnimatedScale(
                    scale: scale,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: Transform.rotate(
                      angle: pi,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color.fromARGB(211, 38, 38, 38)
                                    : Colors.green.withAlpha(26),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item.icon,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color.fromARGB(210, 64, 64, 64)
                    : const Color.fromARGB(255, 123, 123, 123).withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: () => setState(() => isExpanded = !isExpanded),
                icon: Icon(
                  isExpanded
                      ? Icons.expand_less
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                label: Text(
                  isExpanded ? 'Sembunyikan' : 'Lihat Semua',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.0, // 🔥 ini bikin teks lebih slim
                    fontSize: 13, // opsional, bisa kecilin font
                    color: isDark
                        ? Colors.grey[400]
                        : const Color.fromARGB(255, 101, 101, 101),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4, // 🔥 ini bikin tombol lebih slim
                  ),
                  tapTargetSize: MaterialTapTargetSize
                      .shrinkWrap, // 🔥 hilangkan ruang ekstra
                  minimumSize:
                      Size.zero, // 🔥 wajib buat padding benar-benar ramping
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final String title;
  final String subtitle;
  final IconData icon;

  _NotifItem({required this.title, required this.subtitle, required this.icon});
}
