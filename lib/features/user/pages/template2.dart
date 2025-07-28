// // ignore_for_file: deprecated_member_use

// import 'package:palm_diagnose/features/user/widgets/body_measurement.dart';
// import 'package:palm_diagnose/features/user/widgets/glass_view.dart';
// import 'package:palm_diagnose/features/user/widgets/mediterranean_diet_view.dart';
// import 'package:palm_diagnose/features/user/widgets/title_view.dart';
// import 'package:palm_diagnose/core/constants/fitness_app_theme.dart';
// import 'package:palm_diagnose/features/user/widgets/meals_list_view.dart';
// import 'package:palm_diagnose/features/user/widgets/water_view.dart';
// import 'package:palm_diagnose/features/user/widgets/bottom_bar_view.dart';
// import 'package:palm_diagnose/features/user/widgets/tabIcon_data.dart';
// import 'package:palm_diagnose/shared/widgets/custom_animated_appbar.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:palm_diagnose/core/utils/dialog_utils.dart';
// import 'package:palm_diagnose/routers/app_routes.dart';
// import 'package:flutter/material.dart';
// // import 'package:palm_diagnose/features/user/detection/pages/detect_page.dart';

// import 'package:palm_diagnose/features/auth/controllers/auth_controller.dart';

// // import 'package:palm_diagnose/features/user/pages/history_page.dart';
// import 'package:palm_diagnose/features/profile/pages/profile_page.dart';

// class UserHomePage extends StatefulWidget {
//   const UserHomePage({
//     Key? key,
//     this.animationController,
//   }) : super(key: key);

//   final AnimationController? animationController;
//   @override
//   _UserHomePageState createState() => _UserHomePageState();
// }

// class _UserHomePageState extends State<UserHomePage>
//     with TickerProviderStateMixin {
//   Animation<double>? topBarAnimation;

//   List<TabIconData> tabIconsList = TabIconData.tabIconsList;

//   int selectedIndex = 0; // untuk track tab aktif

//   List<Widget> listViews = <Widget>[];
//   final ScrollController scrollController = ScrollController();
//   double topBarOpacity = 0.0;
//   late AnimationController _controller;

//   @override
//   void initState() {
//     assert(widget.animationController != null,
//         'AnimationController tidak boleh null!');
//     super.initState();

//     _controller = widget.animationController ??
//         AnimationController(
//           vsync: this,
//           duration: const Duration(milliseconds: 600),
//         );

//     topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
//       ),
//     );
//     addAllListData();

//     scrollController.addListener(() {
//       if (scrollController.offset >= 24) {
//         if (topBarOpacity != 1.0) {
//           setState(() {
//             topBarOpacity = 1.0;
//           });
//         }
//       } else if (scrollController.offset <= 24 &&
//           scrollController.offset >= 0) {
//         if (topBarOpacity != scrollController.offset / 24) {
//           setState(() {
//             topBarOpacity = scrollController.offset / 24;
//           });
//         }
//       } else if (scrollController.offset <= 0) {
//         if (topBarOpacity != 0.0) {
//           setState(() {
//             topBarOpacity = 0.0;
//           });
//         }
//       }
//     });
//   }

//   void addAllListData() {
//     const int count = 9;

//     listViews.add(
//       TitleView(
//         titleTxt: 'Mediterranean diet',
//         subTxt: 'Details',
//         animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
//             parent: _controller,
//             curve: const Interval((1 / count) * 0, 1.0,
//                 curve: Curves.fastOutSlowIn))),
//         animationController: widget.animationController!,
//       ),
//     );
//     listViews.add(
//       MediterranesnDietView(
//         animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
//             parent: _controller,
//             curve: const Interval((1 / count) * 1, 1.0,
//                 curve: Curves.fastOutSlowIn))),
//         animationController: widget.animationController!,
//       ),
//     );
//     listViews.add(
//       TitleView(
//         titleTxt: 'Meals today',
//         subTxt: 'Customize',
//         animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
//             parent: _controller,
//             curve: const Interval((1 / count) * 2, 1.0,
//                 curve: Curves.fastOutSlowIn))),
//         animationController: widget.animationController!,
//       ),
//     );

//     listViews.add(
//       MealsListView(
//         mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
//             CurvedAnimation(
//                 parent: _controller,
//                 curve: const Interval((1 / count) * 3, 1.0,
//                     curve: Curves.fastOutSlowIn))),
//         mainScreenAnimationController: widget.animationController,
//       ),
//     );

//     listViews.add(
//       TitleView(
//         titleTxt: 'Body measurement',
//         subTxt: 'Today',
//         animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
//             parent: _controller,
//             curve: const Interval((1 / count) * 4, 1.0,
//                 curve: Curves.fastOutSlowIn))),
//         animationController: widget.animationController!,
//       ),
//     );

//     listViews.add(
//       BodyMeasurementView(
//         animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
//             parent: _controller,
//             curve: const Interval((1 / count) * 5, 1.0,
//                 curve: Curves.fastOutSlowIn))),
//         animationController: widget.animationController!,
//       ),
//     );
//     listViews.add(
//       TitleView(
//         titleTxt: 'Water',
//         subTxt: 'Aqua SmartBottle',
//         animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
//             parent: _controller,
//             curve: const Interval((1 / count) * 6, 1.0,
//                 curve: Curves.fastOutSlowIn))),
//         animationController: widget.animationController!,
//       ),
//     );

//     listViews.add(
//       WaterView(
//         mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
//             CurvedAnimation(
//                 parent: _controller,
//                 curve: const Interval((1 / count) * 7, 1.0,
//                     curve: Curves.fastOutSlowIn))),
//         mainScreenAnimationController: widget.animationController!,
//       ),
//     );
//     listViews.add(
//       GlassView(
//           animation: Tween<double>(begin: 0.0, end: 1.0).animate(
//               CurvedAnimation(
//                   parent: _controller,
//                   curve: const Interval((1 / count) * 8, 1.0,
//                       curve: Curves.fastOutSlowIn))),
//           animationController: widget.animationController!),
//     );
//   }

//   Future<bool> getData() async {
//     await Future<dynamic>.delayed(const Duration(milliseconds: 50));
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: FitnessAppTheme.background,
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Stack(
//           children: <Widget>[
//             Positioned.fill(
//               child: getMainListViewUI(), // Konten utama
//             ),

//             if (selectedIndex == 0)
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: CustomAnimatedAppBar(
//                   title: 'My Diary',
//                   animationController: widget.animationController!,
//                   topBarAnimation: topBarAnimation!,
//                   topBarOpacity: topBarOpacity,
//                   onTitleTap: () async {
//                     final auth = AuthController();
//                     await auth.logout();
//                     if (context.mounted) {
//                       Navigator.pushReplacementNamed(context, '/login');
//                     }
//                   },
//                 ), // AppBar hanya untuk Diary
//               ),

//             // 👇 Ini pengganti bottomNavigationBar
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).padding.bottom,
//                 ),
//                 child: SafeArea(
//                   top: false,
//                   child: SizedBox(
//                     height: 72, // atur sesuai tinggi BottomBarView kamu
//                     child: BottomBarView(
//                       tabIconsList: tabIconsList,
//                       changeIndex: (index) {
//                         setState(() {
//                           selectedIndex = index;
//                         });
//                       },
//                       addClick: () {
//                         DialogUtils.showImageSourceActionSheet(
//                           context,
//                           (source) async {
//                             final picker = ImagePicker();
//                             final pickedFile =
//                                 await picker.pickImage(source: source);

//                             if (pickedFile != null) {
//                               final file = File(pickedFile.path);
//                               debugPrint('📸 Gambar dipilih: ${file.path}');

//                               if (!context.mounted) return;
//                               if (!file.existsSync()) {
//                                 debugPrint(
//                                     "❌ File tidak ditemukan setelah ambil dari kamera!");
//                                 return;
//                               }

//                               Navigator.pushNamed(
//                                 context,
//                                 AppRoutes.detect,
//                                 arguments: {
//                                   'imageFile': file,
//                                 },
//                               );
//                             } else {
//                               debugPrint("⚠️ Tidak ada gambar dipilih");
//                             }
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget getMainListViewUI() {
//   //   return FutureBuilder<bool>(
//   //     future: getData(),
//   //     builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
//   //       if (!snapshot.hasData) {
//   //         return const SizedBox();
//   //       } else {
//   //         return ListView.builder(
//   //           controller: scrollController,
//   //           padding: EdgeInsets.only(
//   //             top: AppBar().preferredSize.height +
//   //                 MediaQuery.of(context).padding.top +
//   //                 24,
//   //             bottom: 62 + MediaQuery.of(context).padding.bottom,
//   //           ),
//   //           itemCount: listViews.length,
//   //           scrollDirection: Axis.vertical,
//   //           itemBuilder: (BuildContext context, int index) {
//   //             widget.animationController?.forward();
//   //             return listViews[index];
//   //           },
//   //         );
//   //       }
//   //     },
//   //   );
//   // }

//   Widget _getDiaryView() {
//     return FutureBuilder<bool>(
//       future: getData(),
//       builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
//         if (!snapshot.hasData) {
//           return const SizedBox();
//         } else {
//           return ListView.builder(
//             controller: scrollController,
//             padding: EdgeInsets.only(
//               top: AppBar().preferredSize.height +
//                   MediaQuery.of(context).padding.top +
//                   24,
//               bottom: 62 + MediaQuery.of(context).padding.bottom,
//             ),
//             itemCount: listViews.length,
//             scrollDirection: Axis.vertical,
//             itemBuilder: (BuildContext context, int index) {
//               widget.animationController?.forward();
//               return listViews[index];
//             },
//           );
//         }
//       },
//     );
//   }

//   Widget getMainListViewUI() {
//     if (selectedIndex == 0) {
//       return _getDiaryView(); // Halaman Diary
//     } else if (selectedIndex == 1) {
//       return const ProfilePage(); // Misalnya ubah jadi Riwayat
//     } else {
//       return const ProfilePage(); // Halaman Profil
//     }
//   }

//   Widget getAppBarUI() {
//     return Column(
//       children: <Widget>[
//         AnimatedBuilder(
//           animation: widget.animationController!,
//           builder: (BuildContext context, Widget? child) {
//             return FadeTransition(
//               opacity: topBarAnimation!,
//               child: Transform(
//                 transform: Matrix4.translationValues(
//                     0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: FitnessAppTheme.white.withOpacity(topBarOpacity),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(32.0),
//                     ),
//                     boxShadow: <BoxShadow>[
//                       BoxShadow(
//                           color: FitnessAppTheme.grey
//                               .withOpacity(0.4 * topBarOpacity),
//                           offset: const Offset(1.1, 1.1),
//                           blurRadius: 10.0),
//                     ],
//                   ),
//                   child: Column(
//                     children: <Widget>[
//                       SizedBox(
//                         height: MediaQuery.of(context).padding.top,
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(
//                             left: 16,
//                             right: 16,
//                             top: 16 - 8.0 * topBarOpacity,
//                             bottom: 12 - 8.0 * topBarOpacity),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: GestureDetector(
//                                   onTap: () async {
//                                     final auth = AuthController();
//                                     await auth.logout();
//                                   },
//                                   child: Text(
//                                     'My Diary',
//                                     textAlign: TextAlign.left,
//                                     style: TextStyle(
//                                       fontFamily: FitnessAppTheme.fontName,
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 22 + 6 - 6 * topBarOpacity,
//                                       letterSpacing: 1.2,
//                                       color: FitnessAppTheme.darkerText,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             // Expanded(
//                             //   child: Padding(
//                             //     padding: const EdgeInsets.all(8.0),
//                             //     child: Text(
//                             //       'My Diary',
//                             //       textAlign: TextAlign.left,
//                             //       style: TextStyle(
//                             //         fontFamily: FitnessAppTheme.fontName,
//                             //         fontWeight: FontWeight.w700,
//                             //         fontSize: 22 + 6 - 6 * topBarOpacity,
//                             //         letterSpacing: 1.2,
//                             //         color: FitnessAppTheme.darkerText,
//                             //       ),
//                             //     ),
//                             //   ),
//                             // ),
//                             SizedBox(
//                               height: 38,
//                               width: 38,
//                               child: InkWell(
//                                 highlightColor: Colors.transparent,
//                                 borderRadius: const BorderRadius.all(
//                                     Radius.circular(32.0)),
//                                 onTap: () {},
//                                 child: const Center(
//                                   child: Icon(
//                                     Icons.keyboard_arrow_left,
//                                     color: FitnessAppTheme.grey,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const Padding(
//                               padding: EdgeInsets.only(
//                                 left: 8,
//                                 right: 8,
//                               ),
//                               child: Row(
//                                 children: <Widget>[
//                                   Padding(
//                                     padding: EdgeInsets.only(right: 8),
//                                     child: Icon(
//                                       Icons.calendar_today,
//                                       color: FitnessAppTheme.grey,
//                                       size: 18,
//                                     ),
//                                   ),
//                                   Text(
//                                     '15 May',
//                                     textAlign: TextAlign.left,
//                                     style: TextStyle(
//                                       fontFamily: FitnessAppTheme.fontName,
//                                       fontWeight: FontWeight.normal,
//                                       fontSize: 18,
//                                       letterSpacing: -0.2,
//                                       color: FitnessAppTheme.darkerText,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               height: 38,
//                               width: 38,
//                               child: InkWell(
//                                 highlightColor: Colors.transparent,
//                                 borderRadius: const BorderRadius.all(
//                                     Radius.circular(32.0)),
//                                 onTap: () {},
//                                 child: const Center(
//                                   child: Icon(
//                                     Icons.keyboard_arrow_right,
//                                     color: FitnessAppTheme.grey,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         )
//       ],
//     );
//   }
// }
