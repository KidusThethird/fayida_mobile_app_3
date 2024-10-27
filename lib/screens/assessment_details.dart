import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/color.dart';
import '../widgets/mybutton.dart';
import 'exam_screen.dart'; // Make sure to import your ExamScreen here

class AssessmentScreen extends StatefulWidget {
  final String assessmentId;

  AssessmentScreen({Key? key, required this.assessmentId}) : super(key: key);

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  String assessmentTitle = '';
  String assessmentDescription = '';
  String duration = '';
  String message = '';
  bool isLoading = true;
  String points = '';
  String examId = ''; // Add examId variable

  @override
  void initState() {
    super.initState();
    fetchAssessmentDetails();
  }

  Future<void> fetchAssessmentDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cookieString = prefs.getString('cookies');

    if (cookieString != null) {
      final Dio dio = Dio();
      dio.options.headers['Cookie'] = cookieString;

      try {
        final response = await dio.get(
            'https://api.fayidaacademy.com/materials/${widget.assessmentId}');

        if (response.statusCode == 200) {
          setState(() {
            var assessmentData = response.data['assementId'];
            assessmentTitle = assessmentData['assesmentTitle'] ?? 'No Title';
            assessmentDescription =
                assessmentData['assesmentDescription'] ?? 'No Description';
            duration = assessmentData['duration'] ?? 'No Duration';
            points = assessmentData['assesmentPoints'] ?? '';
            examId = assessmentData['id'] ?? ''; // Get examId from API
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

  void _takeExam() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExamScreen(examId: examId), // Navigate to ExamScreen with examId
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment Details'),
        backgroundColor: AppColor.primary,
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
                        'Title: $assessmentTitle',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Description: $assessmentDescription',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Duration: $duration minutes',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'You can collect up to $points Points in this assessment!',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Note: Once you start taking the assessment, you cannot return without submitting! If you do, your result may be taken as invalid permanently.',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      // Add spacing for button
                      ElevatedButton(
                          onPressed: _takeExam, // Call the function on pressed
                          child: Text('Take Exam'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16.0),
                            backgroundColor: Colors
                                .transparent, // Make the button background transparent
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          )),
                      SizedBox(
                        height: 10.0,
                      ),
                      MyCustomButton(materialId: widget.assessmentId),
                    ],
                  ),
                ),
    );
  }
}
