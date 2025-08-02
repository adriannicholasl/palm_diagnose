import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommonInfoPage extends StatelessWidget {
  const CommonInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_InfoItem> items = [
      _InfoItem(
        title: 'Kebijakan Privasi',
        subtitle: 'Bagaimana data Anda dikumpulkan dan digunakan.',
        icon: FontAwesomeIcons.userShield,
        onTap: () {
          // TODO: Navigasi ke halaman detail
        },
      ),
      _InfoItem(
        title: 'Syarat & Ketentuan',
        subtitle: 'Aturan penggunaan aplikasi Palm Diagnose.',
        icon: FontAwesomeIcons.fileContract,
        onTap: () {
          // TODO: Navigasi ke halaman detail
        },
      ),
      _InfoItem(
        title: 'Kontak Kami',
        subtitle: 'Hubungi tim support kami untuk bantuan.',
        icon: FontAwesomeIcons.solidEnvelope,
        onTap: () {
          // TODO: Arahkan ke form atau email
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Umum'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Material(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: item.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: FaIcon(item.icon,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _InfoItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
