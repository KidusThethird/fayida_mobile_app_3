import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../theme/color.dart';

class BlogDetailsScreen extends StatefulWidget {
  final String blogId;
  final String blogImage;
  final String blogTitle;

  const BlogDetailsScreen({
    Key? key,
    required this.blogId,
    required this.blogImage,
    required this.blogTitle,
  }) : super(key: key);

  @override
  State<BlogDetailsScreen> createState() => _BlogDetailsScreenState();
}

class _BlogDetailsScreenState extends State<BlogDetailsScreen> {
  late Future<Map<String, dynamic>> _blogDetailsFuture;

  @override
  void initState() {
    super.initState();
    _blogDetailsFuture = fetchBlogDetails();
  }

  Future<Map<String, dynamic>> fetchBlogDetails() async {
    final response = await http
        .get(Uri.parse('https://api.fayidaacademy.com/blogs/${widget.blogId}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load blog details');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Details'),
        backgroundColor: AppColor.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Centered Blog Image with Rounded Corners
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    widget.blogImage,
                    fit: BoxFit.cover,
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.3,
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // Blog Title
              Text(
                widget.blogTitle,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),

              // Fetch and display subtitle, author, and main content
              FutureBuilder<Map<String, dynamic>>(
                future: _blogDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Failed to load blog details'));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Blog Subtitle
                        Text(
                          data['subTitle'] ?? 'No subtitle available',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.0),

                        // Written By
                        Text(
                          'Written by ${data['writtenBy'] ?? 'Unknown Author'}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16.0),

                        // Main Text
                        Text(
                          data['text'] ?? 'No content available',
                          style: TextStyle(
                            fontSize: 16.0,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
