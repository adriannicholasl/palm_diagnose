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
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: kToolbarHeight + 16,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Foto Profil
            GestureDetector(
              onTap: onTapProfile,
              child: profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        profileImageUrl!,
                        fit: BoxFit.cover,
                        height: 44,
                        width: 44,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/default_avatar.jpg',
                          height: 44,
                          width: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Image.asset(
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
