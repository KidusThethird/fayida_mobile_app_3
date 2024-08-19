import 'package:flutter/material.dart';
import 'package:online_course/screens/login.dart';
import 'package:online_course/screens/profiletest.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Course App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      // home: ProfileScreen()
      // Directly maps to the LoginScreen
    );
  }
}
