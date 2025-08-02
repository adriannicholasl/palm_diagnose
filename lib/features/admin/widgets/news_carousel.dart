import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsCarousel extends StatelessWidget {
  const NewsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, String>> news = [
      {
        'title': 'Throwback: Cari Burung Nyangkut di Pohon Kelapa',
        'url':
            'https://www.detik.com/jabar/berita/d-7739937/throwback-cari-burung-berujung-nyangkut-di-pohon-kelapa',
        'imageUrl': 'assets/images/news/news_5.jpeg', // manual
      },
      {
        'title': 'Kenapa Pohon Kelapa di Pantai Bali Tak Berbuah?',
        'url':
            'https://travel.detik.com/travel-news/d-7237333/kenapa-pohon-kelapa-di-pantai-bali-tak-berbuah',
        'imageUrl': 'assets/images/news/news_3.jpeg',
      },
      {
        'title': 'Pohon Kelapa Tumbang di Gorontalo, Timpa Mobil!',
        'url':
            'https://www.detik.com/sulsel/berita/d-7880251/pohon-kelapa-tumbang-di-gorontalo-timpa-mobil-di-jalan-gegara-angin-kencang',
        'imageUrl': 'assets/images/news/news_1.jpeg',
      },
      {
        'title': 'Inovasi Olah Kelapa Jadi Obat Oles oleh Warga Papua',
        'url':
            'https://daerah.sindonews.com/read/1124845/174/inovasi-masyarakat-manokwari-selatan-mampu-olah-kelapa-jadi-obat-oles-1686582388',
        'imageUrl': 'assets/images/news/news_4.webp', // dari Sindonews
      },
    ];

    // HAPUS PADDING dari luar
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Berita Terkait',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ), // dipertahankan di sini
            itemCount: news.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = news[index];
              return GestureDetector(
                onTap: () async {
                  final url = Uri.parse(item['url']!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  width: 260,
                  height: 150,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.grey.withAlpha(13),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['imageUrl']!,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            item['title']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
