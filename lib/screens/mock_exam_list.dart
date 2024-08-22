import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:getwidget/getwidget.dart';

import 'mock_exam_assessment.dart';

class MockExamDetails extends StatefulWidget {
  final String packageId;

  const MockExamDetails({Key? key, required this.packageId}) : super(key: key);

  @override
  _MockExamDetailsState createState() => _MockExamDetailsState();
}

class _MockExamDetailsState extends State<MockExamDetails> {
  Map<String, dynamic>? mockExamData;

  @override
  void initState() {
    super.initState();
    fetchMockExamData();
  }
//            'https://api.fayidaacademy.com/mockexampackagepurchase/accessexam/00110011/${widget.mockPackageId}/${widget.assessmentId}');

  Future<void> fetchMockExamData() async {
    final url = Uri.parse(
        'https://api.fayidaacademy.com/mockexampackage/${widget.packageId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        mockExamData = jsonDecode(response.body);
      });
    } else {
      // Handle error
      print('Error fetching mock exam data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mockExamData == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(mockExamData!['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            GFImageOverlay(
              height: 200,
              width: double.infinity,
              image: NetworkImage(mockExamData!['imgUrl'][0]),
              borderRadius: BorderRadius.circular(12.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Exams',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: mockExamData?['Exams']?.length ?? 0,
                itemBuilder: (context, index) {
                  final exam = mockExamData!['Exams'][index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MockExamAssessmentScreen(
                            assessmentId: mockExamData!['Exams'][index]['id'],
                            mockPackageId: mockExamData!['id'],
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(exam['assesmentTitle']),
                      subtitle: Text('Duration: ${exam['duration']} minutes'),
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
