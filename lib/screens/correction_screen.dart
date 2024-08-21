import 'package:flutter/material.dart';

class CorrectionScreen extends StatelessWidget {
  final List<String> incorrectQuestions;
  final List<String> allQuestions;
  final String resultText;

  CorrectionScreen({
    Key? key,
    required this.incorrectQuestions,
    required this.allQuestions,
    required this.resultText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Correction Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Result: $resultText',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Incorrect Questions:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: incorrectQuestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(incorrectQuestions[index]),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'All Questions:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: allQuestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(allQuestions[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
