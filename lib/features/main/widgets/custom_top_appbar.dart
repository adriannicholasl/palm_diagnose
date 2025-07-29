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
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: kToolbarHeight + 16,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Foto Profil tanpa cache
            GestureDetector(
              onTap: onTapProfile,
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

            /// Teks
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  upperTitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
