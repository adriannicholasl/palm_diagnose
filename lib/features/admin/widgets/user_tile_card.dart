import 'dart:math';
import 'package:flutter/material.dart';

class UserTileCard extends StatefulWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final int totalDeteksi;
  final VoidCallback onTap;

  const UserTileCard({
    super.key,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.totalDeteksi,
    required this.onTap,
  });

  @override
  State<UserTileCard> createState() => _UserTileCardState();
}

class _UserTileCardState extends State<UserTileCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  Color getRandomColor(String input) {
    final hash = input.codeUnits.fold(0, (prev, e) => prev + e);
    final random = Random(hash);
    return Color.fromARGB(
      255,
      100 + random.nextInt(155),
      100 + random.nextInt(155),
      100 + random.nextInt(155),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = Tween<double>(
      begin: 0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(); // animasi muncul saat build pertama
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildInitialAvatar(String initials) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: getRandomColor(initials),
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.name.isNotEmpty
        ? widget.name.trim().split(' ').map((e) => e[0]).take(2).join()
        : '?';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withAlpha(51)
                        : Colors.grey.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                onTap: widget.onTap,
                leading: widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          widget.photoUrl!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildInitialAvatar(initials),
                        ),
                      )
                    : _buildInitialAvatar(initials),
                title: Text(
                  widget.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  widget.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                  ),
                ),
              ),
            ),

            // Badge Deteksi
            Positioned(
              top: -4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: widget.totalDeteksi > 0
                      ? const Color(0xFF43A047) // hijau
                      : const Color(0xFFE53935), // merah
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.totalDeteksi > 99
                      ? '99+'
                      : '${widget.totalDeteksi > 0 ? widget.totalDeteksi : '-'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
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
  }
}
