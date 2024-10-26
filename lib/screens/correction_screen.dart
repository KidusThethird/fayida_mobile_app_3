import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/custom_text_widget.dart';
import '../utils/imageloader.dart';

class CorrectionScreen extends StatefulWidget {
  final String examId;

  CorrectionScreen({Key? key, required this.examId}) : super(key: key);

  @override
  _ExamDetailsScreenState createState() => _ExamDetailsScreenState();
}

class _ExamDetailsScreenState extends State<CorrectionScreen> {
  String examTitle = '';
  List<dynamic> questions = [];

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
          'https://api.fayidaacademy.com/purchaselist/specificStudentSingleAssessment/${widget.examId}',
        );

        if (response.statusCode == 200) {
          List<dynamic> examData = response.data;

          if (examData.isNotEmpty) {
            setState(() {
              var examInfo = examData[0];
              examTitle = examInfo['assesmentTitle'] ?? 'No Title';
              questions = examInfo['question'] ?? [];
            });
          }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              examTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   'Q${question['questionIndex']}: ${question['question']}',
                          //   style: TextStyle(
                          //       fontSize: 18, fontWeight: FontWeight.bold),
                          // ),
                          CustomTextWidget(
                            text:
                                'Q${question['questionIndex']}: ${question['question']}',
                            baseStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          //  Text('A: ${question['choiseA']}'),
                          CustomTextWidget(
                            text: 'A: ${question['choiseA']}',
                            baseStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          //Text('B: ${question['choiseB']}'),
                          CustomTextWidget(
                            text: 'B: ${question['choiseB']}',
                            baseStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          //Text('C: ${question['choiseC']}'),
                          CustomTextWidget(
                            text: 'C: ${question['choiseC']}',
                            baseStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          //Text('D: ${question['choiseD']}'),
                          CustomTextWidget(
                            text: 'D: ${question['choiseD']}',
                            baseStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Correct Choice: ${question['correctChoice'].toUpperCase()}',
                            style: TextStyle(color: Colors.green),
                          ),
                          NetworkImageSection(
                              imageUrl: question['correctionImageUrl']),
                          // Text(
                          //   'Exp: ${question['correction'].toUpperCase()}',
                          //   style: TextStyle(
                          //       color: const Color.fromARGB(255, 25, 37, 26)),
                          // ),

                          CustomTextWidget(
                            text: 'Exp: ${question['correction']}',
                            baseStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
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
