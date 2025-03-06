import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../bottom_bar/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Ensuring navigation works properly using post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFEF4),
      //backgroundColor: Colors.white,
      body: Stack(
        children:[
          Center(
          child: Lottie.asset(
            'assets/splash.json', // ✅ Ensure correct path in pubspec.yaml
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
          Center(child: Text("Snow Plow"))
        ]
      ),
    );
  }
}
