import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import '../theme/color.dart';
import '../widgets/custom_image.dart';
import 'course_materials.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<dynamic> inProgressCourses = [];
  List<dynamic> completedCourses = [];
  List<dynamic> packages = [];
  String message = "";
  List<dynamic> mainData = [];
  List<dynamic> packageListData = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchCourses();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> fetchCourses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('accessToken');

    if (authToken != null) {
      final Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $authToken';

      try {
        final response = await dio.get(
            'https://api.fayidaacademy.com/purchaselist/specificStudentCourses');
        final packageResponse = await dio
            .get('https://api.fayidaacademy.com/purchaselist/getpuchasedlist');

        if (response.statusCode == 200) {
          print("Fetched data: ${response.data}");

          // Save JSON response to permanent storage
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/specificStudentCourses.json');
          await file.writeAsString(jsonEncode(response.data));

          print("Data saved to ${file.path}");

          setState(() {
            mainData = response.data;
            inProgressCourses = response.data['inProgress'] ?? [];
            completedCourses = response.data['completed'] ?? [];
            packages = response.data['packages'] ?? [];
          });
        } else {
          print("data: NO data fetched");
          setState(() {
            message = "Error: ${response.statusMessage}";
          });
        }

        if (packageResponse.statusCode == 200) {
          print("Fetched data: ${packageResponse.data}");
          setState(() {
            packageListData = packageResponse.data;
          });
        } else {
          print("data: NO data fetched");
          setState(() {
            message = "Error: ${response.statusMessage}";
          });
        }
      } catch (e) {
        setState(() {
          message = "Error: $e";
        });
      }
    } else {
      setState(() {
        message = "No cookies found. Please log in.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchCourses,
        child: TabBarView(
          controller: tabController,
          children: [
            Center(child: _inProgressCourses()),
            Center(child: _completedCourses()),
          ],
        ),
      ),
    );
  }

  Widget _inProgressCourses() {
    return mainData.isNotEmpty
        ? ListView.builder(
            itemCount: mainData.length,
            itemBuilder: (context, index) {
              int completedMaterials = getCompletedMaterials(
                  mainData[index]['Courses']['materials'] ?? [],
                  mainData[index]['studentsId']);
              int totalMaterials =
                  getTotalMaterials(mainData[index]['Courses']['materials']);
              double progressValue =
                  calculateProgressValue(completedMaterials, totalMaterials);

              bool completed = progressValue == 100.0;

              if (!completed) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseMaterialsScreen(
                          id: mainData[index]['coursesId'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
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
                        CustomImage(
                          mainData[index]['packageImgUrl'][0],
                          radius: 15,
                          height: 80,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mainData[index]['Courses']['courseName'].length >
                                      15
                                  ? mainData[index]['Courses']['courseName']
                                          .substring(0, 15) +
                                      '...'
                                  : mainData[index]['Courses']['courseName'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColor.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text("$progressValue%"),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Text("");
              }
            })
        : Center(child: Text('No data available'));
  }

  Widget _completedCourses() {
    return mainData.isNotEmpty
        ? ListView.builder(
            itemCount: mainData.length,
            itemBuilder: (context, index) {
              int completedMaterials = getCompletedMaterials(
                  mainData[index]['Courses']['materials'] ?? [],
                  mainData[index]['studentsId']);
              int totalMaterials =
                  getTotalMaterials(mainData[index]['Courses']['materials']);
              double progressValue =
                  calculateProgressValue(completedMaterials, totalMaterials);

              bool completed = progressValue == 100.0;

              if (completed) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseMaterialsScreen(
                          id: mainData[index]['coursesId'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
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
                        CustomImage(
                          mainData[index]['packageImgUrl'][0],
                          radius: 15,
                          height: 80,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mainData[index]['Courses']['courseName'].length >
                                      15
                                  ? mainData[index]['Courses']['courseName']
                                          .substring(0, 15) +
                                      '...'
                                  : mainData[index]['Courses']['courseName'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColor.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text("$progressValue%"),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Text("");
              }
            })
        : Center(child: Text('No data available'));
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
}
