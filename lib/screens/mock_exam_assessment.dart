import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MockExamAssessmentScreen extends StatefulWidget {
  final String mockPackageId;
  final String assessmentId;

  MockExamAssessmentScreen({
    required this.mockPackageId,
    required this.assessmentId,
  });

  @override
  _MockExamAssessmentScreenState createState() =>
      _MockExamAssessmentScreenState();
}

class _MockExamAssessmentScreenState extends State<MockExamAssessmentScreen> {
  late Map<String, dynamic> assessmentData;
  bool isLoading = true;
  Map<int, String?> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    fetchAssessmentData();
  }

  Future<void> fetchAssessmentData() async {
    final url = Uri.parse(
        'https://api.fayidaacademy.com/mockexampackagepurchase/accessexam/00110011/${widget.mockPackageId}/${widget.assessmentId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        assessmentData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error fetching assessment data: ${response.statusCode}');
    }
  }

  void _handleAnswerSelection(int index, String? value) {
    setState(() {
      selectedAnswers[index] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mock Exam Assessment'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: assessmentData['question'].length,
              itemBuilder: (context, index) {
                final question = assessmentData['question'][index];
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${question['questionIndex']}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(question['question']),
                      SizedBox(height: 16.0),
                      RadioListTile(
                        title: Text(question['choiseA']),
                        value: 'a',
                        groupValue: selectedAnswers[index],
                        onChanged: (value) {
                          _handleAnswerSelection(index, value.toString());
                        },
                      ),
                      RadioListTile(
                        title: Text(question['choiseB']),
                        value: 'b',
                        groupValue: selectedAnswers[index],
                        onChanged: (value) {
                          _handleAnswerSelection(index, value.toString());
                        },
                      ),
                      RadioListTile(
                        title: Text(question['choiseC']),
                        value: 'c',
                        groupValue: selectedAnswers[index],
                        onChanged: (value) {
                          _handleAnswerSelection(index, value.toString());
                        },
                      ),
                      RadioListTile(
                        title: Text(question['choiseD']),
                        value: 'd',
                        groupValue: selectedAnswers[index],
                        onChanged: (value) {
                          _handleAnswerSelection(index, value.toString());
                        },
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        question['correction'],
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
