import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/custom_text_widget.dart';
import '../utils/custom_text_2.dart';
import '../utils/imageloader.dart';
import 'correction_screen.dart';

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
  late Timer _timer;
  int _start = 0; // Countdown in seconds

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
        print("Iddd :" + widget.examId);
        if (response.statusCode == 200) {
          List<dynamic> examData = response.data;

          if (examData.isNotEmpty) {
            setState(() {
              var examInfo = examData[0];
              print("This is printed : " + response.toString());
              examTitle = examInfo['assesmentTitle'] ?? 'No Title';
              questions = (examInfo['question'] as List)
                  .map((q) => Question.fromJson(q))
                  .toList();
              questionCount = questions.length;
              selectedAnswers = List.filled(questionCount, null);
              _start = int.parse(examInfo['duration'].toString()) * 60;

              isLoading = false;
            });
            startTimer();
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

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
        } else {
          _timer.cancel();
          submitAnswers(context, autoSubmit: true); // Automatically submit
        }
      });
    });
  }

  Future<void> submitAnswers(BuildContext context,
      {bool autoSubmit = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cookieString = prefs.getString('cookies');

    if (cookieString == null) {
      final snackBar = SnackBar(
        content: Text("No credentials found. Please log in again."),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    // Check for unanswered questions only if not auto-submit
    if (!autoSubmit) {
      if (selectedAnswers.contains(null)) {
        final snackBar = SnackBar(
          content: Text("Please answer all questions before submitting."),
          backgroundColor: Colors.orange,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }

    // Fill unanswered questions with 'x' for auto submit
    if (autoSubmit) {
      for (int i = 0; i < selectedAnswers.length; i++) {
        if (selectedAnswers[i] == null) {
          selectedAnswers[i] = 'x'; // Replace unanswered with 'x'
        }
      }
    }

    final Map<String, dynamic> postData = {
      'assessmentId': widget.examId,
      'answers': selectedAnswers,
    };

    try {
      final Dio dio = Dio();
      dio.options.headers['Cookie'] = cookieString;

      final response = await dio.post(
        'https://api.fayidaacademy.com/assesments/submit-answers/${widget.examId}',
        data: postData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Submission Result'),
              content: Text(responseData['message']),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CorrectionScreen(
                          examId: widget.examId,
                        ),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to submit answers. Please try again.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int answeredCount =
        selectedAnswers.where((answer) => answer != null).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Details '),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
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
                          'Time Remaining: ${_start ~/ 60}:${(_start % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 5, 24, 10)),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Number of Questions: $questionCount',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Answered Questions: $answeredCount',
                          style: TextStyle(fontSize: 16),
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

// class Question {
//   final String questionText;
//   final String choicea;
//   final String choiceb;
//   final String choicec;
//   final String choiced;
//   final List<String> choiceContent;
//   final List<String> choices;

//   Question({
//     required this.questionText,
//     required this.choices,
//     required this.choicea,
//     required this.choiceb,
//     required this.choicec,
//     required this.choiced,
//     required this.choiceContent,
//   });

//   factory Question.fromJson(Map<String, dynamic> json) {
//     return Question(
//       questionText: json['question'] as String,
//       choicea: json['choiceA'] as String,
//       choiceb: json['choiceB'] as String,
//       choicec: json['choiceC'] as String,
//       choiced: json['choiceD'] as String,
//       choiceContent: [
//         json['choiceA'] as String,
//         json['choiceB'] as String,
//         json['choiceC'] as String,
//         json['choiceD'] as String,
//       ],
//       choices: ['a', 'b', 'c', 'd'],
//     );
//   }
// }

class Question {
  final String questionText;
  final String choicea;
  final String choiceb;
  final String choicec;
  final String choiced;
  final String questionImage;
  final String correctionImage;
  final List<String> choiceContent;
  final List<String> choices;

  Question({
    required this.questionText,
    required this.choices,
    required this.choicea,
    required this.choiceb,
    required this.choicec,
    required this.choiced,
    required this.choiceContent,
    required this.questionImage,
    required this.correctionImage,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['question'] as String,
      choicea: json['choiseA'],
      choiceb: json['choiseB'],
      choicec: json['choiseC'],
      correctionImage: json['correctionImageUrl'],

      questionImage: json['questionImageUrl'],
      choiced: json['choiseC'],

      choiceContent: [
        json['choiseA'],
        json['choiseB'],
        json['choiseC'],
        json['choiseD']
      ],
      choices: [
        'a',
        'b',
        'c',
        'd'
      ], // Placeholder for choices, adjust as needed
    );
  }
}

class QuestionWidget extends StatefulWidget {
  final Question question;
  final int questionNumber;
  final ValueChanged<String?> onAnswerSelected;

  QuestionWidget({
    required this.question,
    required this.questionNumber,
    required this.onAnswerSelected,
  });

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
            // Text(
            //   'Q${widget.questionNumber}: ${widget.question.questionText}',
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),

            // CustomTextWidget(
            //   text:
            //       ' Q${widget.questionNumber}: ${widget.question.questionText}',
            // ),
//This is an example of a **bold** text. Here is an _underlined_ segment, and here is some *italic* text. Let's include some superscript like x^2^ and some subscript like H***2***O. Also, we can use special characters: &&8 for infinity, &&pi for π, and &&noteq for ≠. For example, the limit as n approaches infinity is expressed as lim_{n->&&8} f(n) ≠ 0. You can also represent mathematical symbols like &&alpha for α, &&beta for β, and &&integral for ∫. Remember to add new lines using &&nl to separate sections: This is the first line.&&nl This is the second line. And here's a long dash: &&dashl. Lastly, we can represent real numbers as &&r and natural numbers as &&nat.

            FilteredText(
              text:
                  ' Q${widget.questionNumber}: ${widget.question.questionText}',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),

            NetworkImageSection(imageUrl: widget.question.questionImage),

            SizedBox(height: 8.0),
            ...List.generate(widget.question.choices.length, (index) {
              String choiceLetter = widget.question.choices[index];
              String choiceText = widget.question.choiceContent[index];
              bool isSelected = selectedChoice == choiceLetter;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedChoice = choiceLetter;
                    widget.onAnswerSelected(selectedChoice);
                  });
                },
                child: Row(
                  children: [
                    Radio<String>(
                      value: choiceLetter,
                      groupValue: selectedChoice,
                      activeColor: Colors.green,
                      onChanged: (String? value) {
                        setState(() {
                          selectedChoice = value;
                          widget.onAnswerSelected(value);
                        });
                      },
                    ),

                    Expanded(
                      child: CustomTextWidget(
                        text: '$choiceLetter : $choiceText',
                        baseStyle: TextStyle(
                          color: isSelected ? Colors.green : Colors.black,
                        ),
                      ),
                    )

                    // Text(
                    //   '$choiceLetter : $choiceText',
                    //   style: TextStyle(
                    //     color: isSelected ? Colors.green : Colors.black,
                    //   ),
                    // ),
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
