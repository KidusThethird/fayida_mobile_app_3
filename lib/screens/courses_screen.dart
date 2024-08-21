import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import Dio for making API requests
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final String? cookieString = prefs.getString('cookies');

    if (cookieString != null) {
      final Dio dio = Dio();
      dio.options.headers['Cookie'] = cookieString;

      try {
        final response = await dio.get(
            'https://api.fayidaacademy.com/purchaselist/specificStudentCourses');

        if (response.statusCode == 200) {
          print("Fetched data: ${response.data}"); // Inspect the response
          setState(() {
            mainData = response.data; // Update mainData
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
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
            Tab(text: 'Packages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Center(child: _inProgressCourses()),
          Center(child: _completedCourses()),
          Center(child: _packagesSection()),
        ],
      ),
    );
  }

  Widget _inProgressCourses() {
    return mainData.isNotEmpty
        ? ListView.builder(
            itemCount: mainData.length,
            itemBuilder: (context, index) {
              int getCompletedMaterials(
                  List<dynamic> materials, String studentId) {
                return materials
                    .where((material) =>
                        material['StudentMaterial']?.any((item) =>
                            item['StudentId'] == studentId &&
                            item['Done'] == true) ??
                        false)
                    .length;
              }

              int getTotalMaterials(List<dynamic>? materials) {
                return materials?.length ?? 0;
              }

              double calculateProgressValue(
                  int completedMaterials, int totalMaterials) {
                return totalMaterials > 0

                    //Todo: fix here needed. the completedMaterials might need to be subtracted by one
                    ? ((completedMaterials) * 100) / totalMaterials
                    : 0;
              }

              int completedMaterials = getCompletedMaterials(
                  mainData[index]['Courses']['materials'] ?? [],
                  mainData[index]['studentsId']);

              int totalMaterials =
                  getTotalMaterials(mainData[index]['Courses']['materials']);

              var progressValue =
                  calculateProgressValue(completedMaterials, totalMaterials);
              // return ListTile(
              //   title: Text(mainData[index]['Courses']['courseName']),
              // );
              //  var x = (mainData[index].Courses?.materials?.isNotEmpty == true
              //    ? " Yes"
              //   : "No");

              // (mainData[index].Courses?.materials?.isNotEmpty == true

              //     ? (mainData[index].Courses!.materials.where((material) {
              //           return material.StudentMaterial.any((item) =>
              //               item.StudentId == mainData[index].studentsId &&
              //               item.Done == true);
              //         }).length /
              //         mainData[index].Courses!.materials.length)
              //     : 0);
              Map<String, dynamic> courseData =
                  mainData[index]['Courses'] ?? {};
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseMaterialsScreen(
                        id: mainData[index]['coursesId'],
                        // courseData: courseData
                      ), // Corrected line
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
                        offset: Offset(1, 1), // changes position of shadow
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
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mainData[index]['Courses']['courseName'].length > 15
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
                          const SizedBox(
                            height: 5,
                          ),

                          Text(progressValue.toString() + " %"),
                          // Text(mainData[index]['Courses']['materials']
                          //             .isNotEmpty ==
                          //         true
                          //     ? (mainData[index]['Courses']['materials']
                          //             .where((material) {
                          //           return material['StudentMaterial'].any(
                          //               (item) =>
                          //                   item['StudentId'] ==
                          //                       mainData[index]['studentsId'] &&
                          //                   item['Done'] == true);
                          //         }).length /
                          //         mainData[index]['Courses']['materials'].length)
                          //     : "0"),

                          // LinearProgressIndicator(
                          //   value: 50,
                          // ),
                          // GFProgressBar(
                          //     percentage: 50,
                          // percentage: (mainData[index]
                          //             .Courses
                          //             ?.materials
                          //             ?.isNotEmpty ==
                          //         true
                          //     ? (mainData[index]
                          //             .Courses!
                          //             .materials
                          //             .where((material) {
                          //           return material.StudentMaterial.any(
                          //               (item) =>
                          //                   item.StudentId ==
                          //                       mainData[index].studentsId &&
                          //                   item.Done == true);
                          //         }).length /
                          //         mainData[index].Courses!.materials.length)
                          //     : 0),
                          // backgroundColor: Colors.black26,
                          // progressBarColor: GFColors.DANGER),
                          const SizedBox(
                            height: 15,
                          ),
                          //_buildDurationAndRate()
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : Center(child: Text('No data available'));
  }

  Widget _completedCourses() {
    return ListView.builder(
      itemCount: completedCourses.length,
      itemBuilder: (context, index) {
        final course = completedCourses[index];
        return ListTile(
          title: Text(course['title'] ?? 'Unknown course'),
          subtitle: Text(
              'Course ID: ${course['coursesId']}, Student ID: ${course['studentsId']}'),
        );
      },
    );
  }

  Widget _packagesSection() {
    return ListView.builder(
      itemCount: packages.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(packages[index]['title'] ?? 'Unknown package'),
        );
      },
    );
  }
}
