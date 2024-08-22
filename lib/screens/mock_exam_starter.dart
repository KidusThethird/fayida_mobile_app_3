import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:http/http.dart' as http;

import 'mock_exam_list.dart';

class MockExamStart extends StatefulWidget {
  const MockExamStart({Key? key}) : super(key: key);

  @override
  State<MockExamStart> createState() => _MockExamStartState();
}

class _MockExamStartState extends State<MockExamStart> {
  List<dynamic> folderData = [];

  @override
  void initState() {
    super.initState();
    fetchFolderData();
  }

  Future<void> fetchFolderData() async {
    final url =
        Uri.parse('https://api.fayidaacademy.com/pacakgefolder/mockmain');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        folderData = jsonDecode(response.body);
      });
    } else {
      // Handle error
      print('Error fetching folder data: ${response.statusCode}');
    }
  }

  void navigateToMockExamList(String folderName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MockExamListScreen(folderName: folderName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Exam'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: folderData.length,
          itemBuilder: (context, index) {
            final folder = folderData[index];
            return ElevatedButton(
                onPressed: () {
                  navigateToMockExamList(folder["folderName"]);
                },
                child: Text(folder["folderName"]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 13, 82,
                      17), // Make the button background transparent
                  shape: RoundedRectangleBorder(),
                ));
          },
        ),
      ),
    );
  }
}

class MockExamListScreen extends StatefulWidget {
  final String folderName;

  const MockExamListScreen({Key? key, required this.folderName})
      : super(key: key);

  @override
  _MockExamListScreenState createState() => _MockExamListScreenState();
}

class _MockExamListScreenState extends State<MockExamListScreen> {
  List<dynamic> mockExamData = [];

  @override
  void initState() {
    super.initState();
    fetchMockExamData();
  }

  Future<void> fetchMockExamData() async {
    final url = Uri.parse(
        'https://api.fayidaacademy.com/mockexampackage/tostudentselectmain/${widget.folderName}');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: mockExamData.length,
                itemBuilder: (context, index) {
                  final mockExam = mockExamData[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MockExamDetails(
                            packageId: mockExam['id'],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        GFImageOverlay(
                          height: 200,
                          width: 300,
                          borderRadius: BorderRadius.circular(16.0),
                          image: NetworkImage(mockExam['imgUrl'][0]),
                        ),
                        Text(
                          mockExam['title'],
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
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
