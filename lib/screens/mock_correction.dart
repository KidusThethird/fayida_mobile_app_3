import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCorrectionScreen extends StatefulWidget {
  final String examId;
  final String apiUrl;

  MockCorrectionScreen({Key? key, required this.examId, required this.apiUrl})
      : super(key: key);

  @override
  _MockCorrectionScreenState createState() => _MockCorrectionScreenState();
}

class _MockCorrectionScreenState extends State<MockCorrectionScreen> {
  Map<String, dynamic>? examData;
  List<dynamic>? questions;

  @override
  void initState() {
    super.initState();
    fetchExamDetails();
  }

  Future<void> fetchExamDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cookieString = prefs.getString('cookies');

    if (cookieString != null) {
      final Dio dio = Dio();
      dio.options.headers['Cookie'] = cookieString;

      try {
        final response = await dio.get(
          widget.apiUrl,
        );

        if (response.statusCode == 200) {
          setState(() {
            examData = response.data;
            questions = examData?['question'];
          });
        } else {
          _showErrorSnackbar(
              'Failed to load exam details: ${response.statusCode}');
        }
      } catch (e) {
        _showErrorSnackbar('An error occurred: $e');
      }
    } else {
      _showErrorSnackbar('No cookie found.');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: examData == null || questions == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examData?['assesmentTitle'] ?? 'No Title',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: questions?.length,
                      itemBuilder: (context, index) {
                        final question = questions?[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Q${question?['questionIndex']}: ${question?['question']}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Text('A: ${question?['choiseA']}'),
                                Text('B: ${question?['choiseB']}'),
                                Text('C: ${question?['choiseC']}'),
                                Text('D: ${question?['choiseD']}'),
                                SizedBox(height: 10),
                                Text(
                                  'Correct Choice: ${question?['correctChoice'].toUpperCase()}',
                                  style: TextStyle(color: Colors.green),
                                ),
                                Text(
                                  'Exp: ${question?['correction'].toUpperCase()}',
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 25, 37, 26)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
