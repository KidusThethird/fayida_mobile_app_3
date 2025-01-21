import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
//import 'course_materials.dart';
import 'localcoursematerialscreen.dart'; // Assuming this file exists and is used for showing materials

class LocalCoursesList extends StatefulWidget {
  @override
  _LocalCoursesListState createState() => _LocalCoursesListState();
}

class _LocalCoursesListState extends State<LocalCoursesList> {
  List<dynamic> localData = [];
  String message = "";

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/specificStudentCourses.json');

      if (await file.exists()) {
        final fileContents = await file.readAsString();
        final data = jsonDecode(fileContents);

        setState(() {
          localData = data; // Store the data fetched from the JSON
        });
      } else {
        setState(() {
          message = "No local data found. Please fetch data first.";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error loading data: $e";
      });
    }
  }

  int getCompletedMaterials(List<dynamic> materials, String studentId) {
    return materials
        .where((material) =>
            material['StudentMaterial']?.any((item) =>
                item['StudentId'] == studentId && item['Done'] == true) ??
            false)
        .length;
  }

  int getTotalMaterials(List<dynamic>? materials) {
    return materials?.length ?? 0;
  }

  double calculateProgressValue(int completedMaterials, int totalMaterials) {
    return totalMaterials > 0
        ? double.parse(
            ((completedMaterials) * 100 / totalMaterials).toStringAsFixed(1))
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses from Local JSON'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: localData.isNotEmpty
          ? ListView.builder(
              itemCount: localData.length,
              itemBuilder: (context, index) {
                int completedMaterials = getCompletedMaterials(
                    localData[index]['Courses']['materials'] ?? [],
                    localData[index]['studentsId']);
                int totalMaterials =
                    getTotalMaterials(localData[index]['Courses']['materials']);
                double progressValue =
                    calculateProgressValue(completedMaterials, totalMaterials);

                bool completed = progressValue == 100.0;

                return GestureDetector(
                  onTap: () {
                    // Navigate to Course Materials Screen
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         CourseMaterialsFromLocalStorageScreen(
                    //               id: localData[index]['coursesId'],
                    //             ),
                    //   ),
                    // );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10, top: 10),
                    padding: EdgeInsets.all(10),
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Assuming you have a custom image widget
                        Image.network(
                          localData[index]['packageImgUrl'][0],
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_not_supported);
                          },
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localData[index]['Courses']['courseName'].length >
                                      15
                                  ? localData[index]['Courses']['courseName']
                                          .substring(0, 15) +
                                      '...'
                                  : localData[index]['Courses']['courseName'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text("$progressValue%"),
                            const SizedBox(height: 15),
                            LinearProgressIndicator(
                              value: progressValue / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(child: Text(message)),
    );
  }
}
