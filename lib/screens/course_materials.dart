import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseMaterialsScreen extends StatefulWidget {
  final String id;

  // Constructor to accept the ID
  CourseMaterialsScreen({required this.id});

  @override
  State<CourseMaterialsScreen> createState() => _CourseMaterialsScreenState();
}

class _CourseMaterialsScreenState extends State<CourseMaterialsScreen> {
  List<dynamic> courseData = [];
  String message = "";
  bool isLoading = true; // Loading state indicator
  List materials = [];

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchCourses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cookieString = prefs.getString('cookies');

    if (cookieString != null) {
      final Dio dio = Dio();
      dio.options.headers['Cookie'] = cookieString;

      try {
        final response = await dio.get(
            'https://api.fayidaacademy.com/purchaselist/specificStudentSingleCourse/${widget.id}');

        if (response.statusCode == 200) {
          print("Fetched data: ${response.data}");
          setState(() {
            courseData = response.data;
            materials = courseData[0]['Courses']['materials'];

            isLoading = false; // Set loading to false after data is fetched
          });
        } else {
          print("Error: NO data fetched");
          setState(() {
            message = "Error: ${response.statusMessage}";
            isLoading = false; // Set loading to false even on error
          });
        }
      } catch (e) {
        setState(() {
          message = "Error: $e";
          isLoading = false; // Set loading to false on exception
        });
      }
    } else {
      setState(() {
        message = "No cookies found. Please log in.";
        isLoading = false; // Set loading to false if no cookies
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData getIconForMaterial(String materialType) {
      switch (materialType) {
        case 'video':
          return Icons.play_arrow; // Play icon
        case 'assessment':
          return Icons.assignment; // Assessment icon
        case 'link':
          return Icons.link; // Link icon
        case 'file':
        default:
          return Icons.attach_file; // File icon
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show loading spinner
            : message.isNotEmpty
                ? Text(message) // Show error message if needed
                : ListView.builder(
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      var material = materials[index];
                      String title;

                      // Determine the title based on material type
                      switch (material['materialType']) {
                        case 'video':
                          title = (material['video'] != null &&
                                  material['video'].containsKey('vidTitle'))
                              ? material['video']['vidTitle'] ?? ''
                              : '';
                          break;
                        case 'assessment':
                          title = (material['assementId'] != null &&
                                  material['assementId']
                                      .containsKey('assesmentTitle'))
                              ? material['assementId']['assesmentTitle'] ?? ''
                              : '';
                          break;
                        case 'link':
                          title = (material['link'] != null &&
                                  material['link'].containsKey('title'))
                              ? material['link']['title'] ?? ''
                              : '';
                          break;
                        case 'file':
                        default:
                          title = (material['file'] != null &&
                                  material['file'].containsKey('title'))
                              ? material['file']['title'] ?? ''
                              : '';
                          break;
                      }

                      return ListTile(
                        leading:
                            Icon(getIconForMaterial(material['materialType'])),
                        title: Text(title),
                      );
                    },
                  ),
      ),
    );
  }
}
