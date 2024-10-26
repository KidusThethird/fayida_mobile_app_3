import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/mybutton.dart'; // Add this import

class FileDetailScreen extends StatefulWidget {
  final String fileId;

  FileDetailScreen({Key? key, required this.fileId}) : super(key: key);

  @override
  _FileDetailScreenState createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> {
  String fileId = '';
  String fileTitle = 'Loading...';
  String fileDescription = 'Loading...';
  String pdfUrl = ''; // URL for the PDF
  String message = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFileDetails();
  }

  Future<void> fetchFileDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cookieString = prefs.getString('cookies');

    if (cookieString != null) {
      final Dio dio = Dio();
      dio.options.headers['Cookie'] = cookieString;

      try {
        final response = await dio
            .get('https://api.fayidaacademy.com/materials/${widget.fileId}');

        if (response.statusCode == 200) {
          setState(() {
            var fileData = response.data;

            if (fileData is Map<String, dynamic>) {
              fileId = widget.fileId;
              fileTitle = fileData['file']['title'] ?? 'No title available';
              fileDescription = fileData['file']['fileDescription'] ??
                  'No description available';
              pdfUrl = fileData['fileUrl'][0] ?? ''; // Fetch the PDF URL
            } else {
              message = 'Unexpected response format';
            }
            isLoading = false;
          });
        } else {
          setState(() {
            message = "Error: ${response.statusMessage}";
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          message = "Error: $e";
          isLoading = false;
        });
      }
    } else {
      setState(() {
        message = "No cookies found. Please log in.";
        isLoading = false;
      });
    }
  }

  void _launchPDF() async {
    if (await canLaunch(pdfUrl)) {
      await launch(pdfUrl);
    } else {
      throw 'Could not launch $pdfUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Details'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : message.isNotEmpty
              ? Center(child: Text(message))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileTitle,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        fileDescription,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _launchPDF,
                        child: Text('View PDF'),
                      ),
                      (1 == 1)
                          ? MyCustomButton(
                              materialId: widget.fileId,
                            )
                          : Text("Seen"),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
    );
  }
}
