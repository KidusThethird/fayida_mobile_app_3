import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:online_course/screens/root_app.dart';
import 'package:online_course/screens/video_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      home: FutureBuilder(
        future: checkLogin(),
        builder: (context, snapshot) {
          // Wait for the response
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            // If firstName is present, navigate to ProfileScreen
            if (snapshot.data == true) {
              return RootApp();
              // return MyAppx();
            }
          }
          // By default or if firstName is absent, go to LoginScreen
          return LoginScreen();
        },
      ),
    );
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
}
