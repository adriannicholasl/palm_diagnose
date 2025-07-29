import 'package:flutter/material.dart';

class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String upperTitle;
  final VoidCallback onTapProfile;
  final String? profileImageUrl;

  const CustomTopAppBar({
    super.key,
    required this.title,
    required this.upperTitle,
    required this.onTapProfile,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: kToolbarHeight + 16,
      title: Padding(
        padding: const EdgeInsets.only(
          top: 12, // padding agar tidak mentok status bar
          left: 8,
          right: 8,
          bottom: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Avatar Profile + Border
            GestureDetector(
              onTap: onTapProfile,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                      ? Image.network(
                          profileImageUrl!,
                          height: 44,
                          width: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('⚠️ Error load profile image: $error');
                            return Image.asset(
                              'assets/images/default_avatar.jpg',
                              height: 44,
                              width: 44,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/default_avatar.jpg',
                          height: 44,
                          width: 44,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),

            /// Teks Judul
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  upperTitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color?.withAlpha(153),
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
