import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamScreen extends StatefulWidget {
  final String examId;

  ExamScreen({Key? key, required this.examId}) : super(key: key);

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  String examTitle = '';
  int questionCount = 0;
  List<Question> questions = [];
  bool isLoading = true;
  String message = '';
  List<String?> selectedAnswers = [];

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
              questions = (examInfo['question'] as List)
                  .map((q) => Question.fromJson(q))
                  .toList();
              questionCount = questions.length;
              selectedAnswers = List.filled(questionCount, null);
              isLoading = false;
            });
          }
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

  void submitAnswers(BuildContext context) {
    int unansweredCount =
        selectedAnswers.where((answer) => answer == null).length;

    if (unansweredCount > 0) {
      final snackBar = SnackBar(
        content: Text("$unansweredCount question(s) remaining."),
        backgroundColor: Colors.red,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      // Handle submission logic here
      print('Submitted Answers: $selectedAnswers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : message.isNotEmpty
              ? Center(child: Text(message))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assessment Title: $examTitle',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Number of Questions: $questionCount',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            return QuestionWidget(
                              question: questions[index],
                              questionNumber: index + 1,
                              onAnswerSelected: (String? answer) {
                                setState(() {
                                  selectedAnswers[index] = answer;
                                });
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => submitAnswers(context),
                          child: Text('Submit Answers'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class Question {
  final String questionText;
  final List<String> choices;

  Question({
    required this.questionText,
    required this.choices,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['question'],
      choices: [
        json['choiseA'],
        json['choiseB'],
        json['choiseC'],
        json['choiseD'],
      ],
    );
  }
}

class QuestionWidget extends StatefulWidget {
  final Question question;
  final int questionNumber;
  final ValueChanged<String?> onAnswerSelected;

  QuestionWidget(
      {required this.question,
      required this.questionNumber,
      required this.onAnswerSelected});

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  String? selectedChoice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedChoice = null; // Reset for new questions
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q${widget.questionNumber}: ${widget.question.questionText}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            ...List.generate(widget.question.choices.length, (index) {
              String choiceLetter = ['A', 'B', 'C', 'D'][index];
              bool isSelected =
                  selectedChoice == widget.question.choices[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedChoice = widget.question.choices[index];
                    widget.onAnswerSelected(selectedChoice);
                  });
                },
                child: Row(
                  children: [
                    Radio<String>(
                      value: widget.question.choices[index],
                      groupValue: selectedChoice,
                      activeColor: Colors.green, // Change active color to green
                      onChanged: (String? value) {
                        setState(() {
                          selectedChoice = value;
                          widget.onAnswerSelected(value);
                        });
                      },
                    ),
                    Text(
                      '$choiceLetter. ${widget.question.choices[index]}',
                      style: TextStyle(
                        color: isSelected ? Colors.green : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
