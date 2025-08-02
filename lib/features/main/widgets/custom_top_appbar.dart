import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String upperTitle;
  final VoidCallback onTapProfile;
  final String? profileImageUrl;
  final bool showBackButton;
  final VoidCallback? onBack;

  const CustomTopAppBar({
    super.key,
    required this.title,
    required this.upperTitle,
    required this.onTapProfile,
    this.profileImageUrl,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // final statusBarHeight = MediaQuery.of(context).padding.top;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: null,

      // ✅ INI PENTING
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle
                .light // Putih untuk status bar icon (dark background)
          : SystemUiOverlayStyle
                .dark, // Hitam untuk status bar icon (light background)

      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: showBackButton ? 0 : 12,
            bottom: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.iconTheme.color,
                      size: 32,
                    ),
                    iconSize: 32,
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onTapProfile,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            profileImageUrl != null &&
                                profileImageUrl!.isNotEmpty
                            ? Image.network(
                                profileImageUrl!,
                                height: 44,
                                width: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint(
                                    '⚠️ Error load profile image: $error',
                                  );
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        upperTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodySmall?.color?.withAlpha(
                            153,
                          ),
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
            ],
          ),
        ),
      ),
    );
  }

  /// Kembalikan nilai besar agar cukup menampung semua konten
  @override
  Size get preferredSize => Size.fromHeight(showBackButton ? 140 : 80);
  // Size get preferredSize => const Size.fromHeight(140);
}
