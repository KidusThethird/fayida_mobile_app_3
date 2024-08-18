import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:online_course/models/bloglist.dart';

class BlogListServices {
  // Base URL for the API
  String baseUrl = "https://api.fayidaacademy.com/";

  // Method to get all blogs
  Future<List<Blog>> getAllBlogs() async {
    List<Blog> allBlogs = [];

    try {
      // Sending a GET request to fetch blogs
      var response = await http.get(Uri.parse(baseUrl + 'blogs/displayhome'));

      // Checking if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        // Decoding the response body
        var data = response.body;
        var decodedData = jsonDecode(data);

        // Looping through the decoded data and creating Blog objects
        for (var blogData in decodedData) {
          Blog newBlog = Blog.fromJson(blogData);
          allBlogs.add(newBlog);
        }

        // Printing the list of all blogs (optional)
        print(allBlogs);
        return allBlogs;
      } else {
        // Handle unexpected status code
        throw Exception(
            'Failed to load blogs. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catching and printing any errors that occur
      print("Error from catch: " + e.toString());
      throw Exception(e.toString());
    }
  }
}
