import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/color.dart';

class MyCustomButton extends StatelessWidget {
  final String materialId;

  MyCustomButton({required this.materialId});

  Future<void> _markAsDone(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cookieString = await _getCookie();

    final String? authToken = prefs.getString('accessToken');

    if (authToken != null) {
      final Dio dio = Dio();
      final String? authToken = prefs.getString('accessToken');

      final String apiUrl =
          'https://api.fayidaacademy.com/studentmaterial/'; // Replace with your actual API URL
      final postData = {
        'MaterialId': materialId, // Set the MaterialId from the parameter
      };
      dio.options.headers['Authorization'] = 'Bearer $authToken';
      try {
        final response = await dio.post(apiUrl, data: postData);

        if (response.statusCode == 200 || response.statusCode == 201) {
          _showDialog(context, "Success", "Marked as done successfully!");
        } else {
          _showDialog(context, "Error",
              "Failed to mark as done: ${response.statusMessage}");
        }
      } catch (e) {
        _showDialog(context, "Error", "Error: $e");
      }
    } else {
      _showDialog(context, "Error", "No cookies found. Please log in.");
    }
  }

  Future<String?> _getCookie() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cookies');
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _markAsDone(context); // Pass context to the function to show dialog
      },
      child: Text('Mark Done'),
      style: TextButton.styleFrom(
        // primary: AppColor.primary, // Text color
        backgroundColor: Colors.white, // Button background color
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding
        textStyle: TextStyle(fontSize: 16), // Font size
      ),
    );
  }
}
