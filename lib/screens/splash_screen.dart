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

    // Set up the animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Check login and navigate after the splash screen duration
    Timer(const Duration(seconds: 2), () async {
      bool isLoggedIn = await checkLogin();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isLoggedIn ? RootApp() : LoginScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to check if the user is logged in
  Future<bool> checkLogin() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? authToken =
          prefs.getString('accessToken'); // Retrieve the token

      if (authToken != null) {
        final Dio dio = Dio();
        dio.options.headers['Authorization'] =
            'Bearer $authToken'; // Add Bearer token to headers

        // Perform GET request to fetch profile
        final response =
            await dio.get('https://api.fayidaacademy.com/newlogin/profile');

        // Print response for debugging
        print("Response data: ${response.data}");

        // Check for the presence of 'id' in the response data
        if (response.statusCode == 200 && response.data['id'] != null) {
          return true; // User is logged in
        }
      }
    } catch (e) {
      // Handle any errors during the request
      print("Error checking login: $e");
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
            'assets/images/icon.png', // Replace with your app logo
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
