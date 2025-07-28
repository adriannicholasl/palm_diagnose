import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:palm_diagnose/routers/app_routes.dart';
import 'package:palm_diagnose/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:palm_diagnose/shared/widgets/custom_buttom_bar.dart';

// Sesuaikan pathnya
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Tambahkan ini untuk development biar tidak error
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Gunakan debug saat development
    webProvider: ReCaptchaV3Provider('6Le...'), // Opsional kalau support web
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palm Diagnose',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      initialRoute: AppRoutes.authGate,
      routes: AppRoutes.routes, // <-- ini penting
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int currentIndex = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    // Navigasi bisa kamu atur di sini berdasarkan index
  }

  void onFabPressed() {
    // Aksi ketika FAB di tengah ditekan
    _incrementCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // ✅ penting agar navbar transparan menempel ke bawah

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),

      // ✅ Tidak pakai floatingActionButton bawaan
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ✅ Ganti pakai custom bottom nav bar milikmu
      bottomNavigationBar: BottomNavBarCurvedFb1(
        currentIndex: currentIndex,
        onItemTapped: onItemTapped,
        onFabPressed: onFabPressed,
      ),
    );
  }
}
