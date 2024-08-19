import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Dio _dio = Dio();
  String? _firstName;
  var myData;

  @override
  void initState() {
    super.initState();
    _initializeCookies();
  }

  Future<void> _initializeCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cookieString = prefs.getString('cookies');
    if (cookieString != null) {
      // Adding cookies to Dio
      _dio.options.headers['Cookie'] = cookieString;
      // Fetch user profile data
      await _fetchUserProfile();
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await _dio.get(
          'https://api.fayidaacademy.com/login_register/profile'); // Update with your endpoint
      if (response.statusCode == 200) {
        setState(() {
          myData = response.data;
          _firstName = response.data[
              'firstName']; // Adjust according to your API response structure
        });
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to fetch profile: ${response.data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(
        child: _firstName != null
            ? Text(
                'Hello, $_firstName!',
                style: TextStyle(fontSize: 24),
              )
            : CircularProgressIndicator(), // Show loading indicator until data is fetched
      ),
    );
  }
}
