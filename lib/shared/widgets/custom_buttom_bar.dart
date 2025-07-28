import 'package:flutter/material.dart';

/// Warna tema aplikasi
const Color primaryColor = Color(0xFF3AC35B);
const Color secondaryColor = Color(0xFF9E9E9E);

/// Tinggi area navigasi bawah
const double bottomBarHeight = 60;

/// Radius FAB untuk lengkungan
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

    return BottomAppBar(
      elevation: 0,
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: bottomBarHeight + 35, // Atur tinggi keseluruhan
        child: Stack(
          children: [
            // Jadikan background di posisi paling bawah layar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, bottomBarHeight),
                painter: BottomNavCurvePainter(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),

            // FAB tetap di tengah
            Positioned(
              bottom: bottomBarHeight / 2 - fabRadius / 3,
              left: MediaQuery.of(context).size.width / 2 - fabRadius,
              child: SizedBox(
                width: fabRadius * 2,
                height: fabRadius * 2,
                child: FloatingActionButton(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                  elevation: 4,
                  onPressed: onFabPressed,
                  child: const Icon(Icons.camera_enhance),
                ),
              ),
            ),
            // Ikon bar tetap di posisi tengah
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
                    const SizedBox(width: 56), // Space for FAB
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
    final color = selected ? primaryColor : secondaryColor;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          // Bisa aktifkan teks label jika diinginkan
          // Text(text, style: TextStyle(fontSize: 12, color: color)),
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
    final bottomRadius = 20.0;

    // Mulai dari kiri atas dengan radius
    path.moveTo(0, topRadius);
    path.arcToPoint(
      Offset(topRadius, 0),
      radius: Radius.circular(topRadius),
      clockwise: true,
    );

    // Garis ke sisi kiri dari notch
    path.lineTo(notchStart - fabNotchSide, 0);

    // Mulai lengkungan FAB
    path.quadraticBezierTo(notchStart, 0, notchStart + 10, fabCurveDepth);
    path.arcToPoint(
      Offset(notchEnd - 10, fabCurveDepth),
      radius: Radius.circular(fabRadius + 30),
      clockwise: false,
    );
    path.quadraticBezierTo(notchEnd, 0, notchEnd + fabNotchSide, 0);

    // Garis ke kanan atas, lalu radius ke bawah
    path.lineTo(size.width - topRadius, 0);
    path.arcToPoint(
      Offset(size.width, topRadius),
      radius: Radius.circular(topRadius),
      clockwise: true,
    );

    // Sisi kanan ke bawah
    path.lineTo(size.width, size.height - bottomRadius);
    path.arcToPoint(
      Offset(size.width - bottomRadius, size.height),
      radius: Radius.circular(bottomRadius),
      clockwise: true,
    );

    // Sisi kiri bawah
    path.lineTo(bottomRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - bottomRadius),
      radius: Radius.circular(bottomRadius),
      clockwise: true,
    );

    path.lineTo(0, topRadius);

    path.close();

    canvas.drawShadow(path, Colors.black, 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
