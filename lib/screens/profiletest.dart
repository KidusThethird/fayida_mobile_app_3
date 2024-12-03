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
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      // Retrieve accessToken from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No access token found. Please log in again.')),
        );
        return;
      }

      // Add the accessToken to the Authorization header
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      // Perform GET request
      final response = await _dio.get(
        'https://api.fayidaacademy.com/newlogin/profile',
      );

      if (response.statusCode == 200) {
        setState(() {
          myData = response.data;
          _firstName =
              response.data['firstName']; // Adjust based on your API structure
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to fetch profile: ${response.data['message']}'),
          ),
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
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: _firstName != null
            ? Text(
                'Hello, $_firstName!',
                style: const TextStyle(fontSize: 24),
              )
            : const CircularProgressIndicator(), // Show loading indicator until data is fetched
      ),
    );
  }
}
