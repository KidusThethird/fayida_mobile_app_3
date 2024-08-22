import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'correction_screen.dart';
import 'mock_correction.dart';

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
  int _totalDuration = 0;
  late Timer _timer;
  int _timeRemaining = 0;

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
        _totalDuration = int.parse(assessmentData['duration']);
        _timeRemaining = _totalDuration * 60;
        isLoading = false;
        startTimer();
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error fetching assessment data: ${response.statusCode}');
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
        if (_timeRemaining == 0) {
          _timer.cancel();
          // Implement the logic to submit the assessment automatically
          print('Assessment time expired!');
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _handleAnswerSelection(int index, String? value) {
    setState(() {
      selectedAnswers[index] = value;
    });
  }

  bool _hasUnansweredQuestions() {
    return selectedAnswers.length < assessmentData['question'].length;
  }

  Future<void> _submitAssessment() async {
    if (_hasUnansweredQuestions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all the questions.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      try {
        final url = Uri.parse(
            'https://api.fayidaacademy.com/assesments/submit-exam-answers/${widget.assessmentId}');
        final body = json.encode({
          'answers': selectedAnswers.values.toList(),
        });
        final response = await http.post(url, body: body, headers: {
          'Content-Type': 'application/json',
        });

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Submission Successful'),
              content: Text(responseData['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MockCorrectionScreen(
                          examId: widget.assessmentId,
                          apiUrl:
                              'https://api.fayidaacademy.com/mockexampackagepurchase/accessexam/00110011/${widget.mockPackageId}/${widget.assessmentId}',
                        ),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting assessment. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mock Exam Assessment'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time Remaining: ${_formatTimeRemaining(_timeRemaining)}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Answered: ${selectedAnswers.length}/${assessmentData['question'].length}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
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
                            if (question['questionImage'] != null &&
                                question['questionImageUrl'][0].isNotEmpty &&
                                _isImageLoaded(question['questionImageUrl'][0]))
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Image.network(
                                    question['questionImageUrl'][0]),
                              ),
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
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitAssessment,
          child: Text('Submit'),
        ),
      ),
    );
  }

  bool _isImageLoaded(String imageUrl) {
    // Add your image loading check logic here
    return true;
  }

  String _formatTimeRemaining(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}
