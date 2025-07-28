import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/constants/fitness_app_theme.dart';

class CustomAnimatedAppBar extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> topBarAnimation;
  final double topBarOpacity;
  final String? title;
  final VoidCallback? onBackTap;
  final VoidCallback? onTitleTap; // ✅ Tambahkan ini

  const CustomAnimatedAppBar({
    Key? key,
    required this.animationController,
    required this.topBarAnimation,
    required this.topBarOpacity,
    this.title,
    this.onBackTap,
    required this.onTitleTap, // ✅ ubah di sini juga
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 60 * (1.0 - topBarAnimation.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: FitnessAppTheme.background,
                        // offset: const Offset(1.1, 1.1),
                        // blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 12,
                          // top: 16 - 8.0 * topBarOpacity,
                          // bottom: 12 - 8.0 * topBarOpacity,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: onTitleTap,
                                child: Text(
                                  title ?? '',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                              // Text(
                              //   title ?? '',
                              //   textAlign: TextAlign.left,
                              //   style: TextStyle(
                              //     fontFamily: FitnessAppTheme.fontName,
                              //     fontWeight: FontWeight.w700,
                              //     fontSize: 22 + 6 - 6 * topBarOpacity,
                              //     letterSpacing: 1.2,
                              //     color: FitnessAppTheme.darkerText,
                              //   ),
                              // ),
                            ),
                            // SizedBox(
                            //   height: 38,
                            //   width: 38,
                            //   child: InkWell(
                            //     highlightColor: Colors.transparent,
                            //     borderRadius: const BorderRadius.all(
                            //         Radius.circular(32.0)),
                            //     onTap: onBackTap,
                            //     child: const Center(
                            //       child: Icon(
                            //         Icons.keyboard_arrow_left,
                            //         color: FitnessAppTheme.grey,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: <Widget>[
                                  // Icon(
                                  //   Icons.calendar_today,
                                  //   color: FitnessAppTheme.grey,
                                  //   size: 18,
                                  // ),
                                  SizedBox(width: 4),
                                  const Text(
                                    'Adrian',
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontSize: 18,
                                      color: FitnessAppTheme.darkerText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(
                            //   height: 38,
                            //   width: 38,
                            //   child: Center(
                            //     child: Icon(
                            //       Icons.keyboard_arrow_right,
                            //       color: FitnessAppTheme.grey,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
