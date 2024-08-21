import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/coursedetails.dart'; // Ensure you have a Course model

class CourseService {
  // Base URL for the API
  final String baseUrl = "https://api.fayidaacademy.com/";

  // Method to get specific student courses
  Future<List<CourseDetails>> getSpecificStudentCourses(String cookie) async {
    List<CourseDetails> courses = [];

    try {
      // Set up headers with cookies
      var response = await http.get(
        Uri.parse(baseUrl + 'purchaselist/specificStudentCourses'),
        headers: {
          'Cookie': cookie,
        },
      );

      // Checking if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Loop through the response data and create Course objects
        for (var courseData in data['inProgress']) {
          courses.add(CourseDetails.fromJson(courseData));
        }

        for (var courseData in data['completed']) {
          courses.add(CourseDetails.fromJson(courseData));
        }

        // Optionally print the list of courses
        print(courses);
        return courses;
      } else {
        throw Exception(
            'Failed to load courses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catching any errors that occur
      print("Error from catch: " + e.toString());
      throw Exception(e.toString());
    }
  }
}
