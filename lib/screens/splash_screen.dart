import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:online_course/screens/root_app.dart';
import 'package:online_course/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Navigate after the splash screen duration
    Timer(const Duration(seconds: 2), () async {
      bool isLoggedIn = await checkLogin();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => isLoggedIn ? RootApp() : LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cookieString = prefs.getString('cookies');

    if (cookieString != null) {
      final Dio dio = Dio();
      dio.options.headers['Cookie'] = cookieString;

      try {
        final response = await dio
            .get('https://api.fayidaacademy.com/login_register/profile');

        if (response.statusCode == 200 && response.data['id'] != null) {
          return true; // User is logged in
        }
      } catch (e) {
        // Handle error if needed
      }
    }
    return false; // User is not logged in
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/images/icon.png', // Replace with your image path
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          )
              .animate()
              .scale(
                  duration: 800.ms,
                  begin: Offset(0.8, 0.8),
                  end: Offset(1.1, 1.1))
              .fadeIn(duration: 800.ms),
        ),
      ),
    );
  }
}
