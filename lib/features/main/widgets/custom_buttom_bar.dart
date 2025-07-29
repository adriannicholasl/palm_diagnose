import 'package:flutter/material.dart';

/// Warna tema aplikasi
const Color selectedColor = Color(0xFF43A047); // hijau elegan
const Color unselectedColor = Color(0xFF9E9E9E); // abu
const double bottomBarHeight = 60;
const double fabRadius = 24;

class BottomNavBarCurvedFb1 extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onFabPressed;

  const BottomNavBarCurvedFb1({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomAppBar(
      elevation: 0,
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: bottomBarHeight + 35,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, bottomBarHeight),
                painter: BottomNavCurvePainter(
                  backgroundColor: isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                ),
              ),
            ),
            // FAB dengan gradasi hijau
            Positioned(
              bottom: bottomBarHeight / 2 - fabRadius / 3,
              left: size.width / 2 - fabRadius,
              child: SizedBox(
                width: fabRadius * 2,
                height: fabRadius * 2,
                child: GestureDetector(
                  onTap: onFabPressed,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // 💡 Atur radius di sini
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_enhance, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: bottomBarHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NavBarIcon(
                      icon: Icons.home_filled,
                      selected: currentIndex == 0,
                      onPressed: () => onItemTapped(0),
                    ),
                    NavBarIcon(
                      icon: Icons.history,
                      selected: currentIndex == 1,
                      onPressed: () => onItemTapped(1),
                    ),
                    const SizedBox(width: 56), // ruang untuk FAB
                    NavBarIcon(
                      icon: Icons.close_sharp,
                      selected: currentIndex == 2,
                      onPressed: () => onItemTapped(2),
                    ),
                    NavBarIcon(
                      icon: Icons.person_2_rounded,
                      selected: currentIndex == 3,
                      onPressed: () => onItemTapped(3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  const NavBarIcon({
    super.key,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class BottomNavCurvePainter extends CustomPainter {
  final Color backgroundColor;

  BottomNavCurvePainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path();

    final fabNotchWidth = fabRadius * 3.0;
    final fabNotchSide = 50.0;
    final notchStart = (size.width / 2) - (fabNotchWidth / 2);
    final notchEnd = (size.width / 2) + (fabNotchWidth / 2);
    final fabCurveDepth = 15.0;
    final topRadius = 25.0;
    final bottomRadius = 0.0;

    path.moveTo(0, topRadius);
    path.arcToPoint(
      Offset(topRadius, 0),
      radius: Radius.circular(topRadius),
      clockwise: true,
    );

    path.lineTo(notchStart - fabNotchSide, 0);
    path.quadraticBezierTo(notchStart, 0, notchStart + 10, fabCurveDepth);
    path.arcToPoint(
      Offset(notchEnd - 10, fabCurveDepth),
      radius: Radius.circular(fabRadius + 30),
      clockwise: false,
    );
    path.quadraticBezierTo(notchEnd, 0, notchEnd + fabNotchSide, 0);

    path.lineTo(size.width - topRadius, 0);
    path.arcToPoint(
      Offset(size.width, topRadius),
      radius: Radius.circular(topRadius),
      clockwise: true,
    );

    path.lineTo(size.width, size.height - bottomRadius);
    path.arcToPoint(
      Offset(size.width - bottomRadius, size.height),
      radius: Radius.circular(bottomRadius),
      clockwise: true,
    );

    path.lineTo(bottomRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - bottomRadius),
      radius: Radius.circular(bottomRadius),
      clockwise: true,
    );

    path.lineTo(0, topRadius);
    path.close();

    canvas.drawShadow(path, Colors.black.withAlpha(51), 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
