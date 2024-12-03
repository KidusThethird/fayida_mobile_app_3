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
    // final String? cookieString = prefs.getString('cookies');
    final String? authToken = prefs.getString('accessToken');

    if (authToken != null) {
      final Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $authToken';

      try {
        final response = await dio.get(
            'https://api.fayidaacademy.com/purchaselist/specificStudentCourses');
        final package_response = await dio
            .get('https://api.fayidaacademy.com/purchaselist/getpuchasedlist');

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

        if (package_response.statusCode == 200) {
          print(
              "Fetched data: ${package_response.data}"); // Inspect the response
          setState(() {
            packageListData = package_response.data; // Update mainData
            //  inProgressCourses = response.data['inProgress'] ?? [];
            //  completedCourses = response.data['completed'] ?? [];
            //  packages = response.data['packages'] ?? [];
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
            //    Tab(text: 'Packages'),
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
            //  Center(child: _packagesSection()),
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
                    ? double.parse(((completedMaterials) * 100 / totalMaterials)
                        .toStringAsFixed(1))
                    : 0;
              }

              int completedMaterials = getCompletedMaterials(
                  mainData[index]['Courses']['materials'] ?? [],
                  mainData[index]['studentsId']);

              int totalMaterials =
                  getTotalMaterials(mainData[index]['Courses']['materials']);

              double progressValue =
                  calculateProgressValue(completedMaterials, totalMaterials);

              bool completed = progressValue == 100.0;
              String x = progressValue.toString();
              Map<String, dynamic> courseData =
                  mainData[index]['Courses'] ?? {};

              print("This is everything :" + progressValue.toString());

              print("Completed is : " + completed.toString());
              if (!completed) {
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
                            const SizedBox(
                              height: 5,
                            ),
                            Text(progressValue.toString() + " %"),
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
                    ? double.parse(((completedMaterials) * 100 / totalMaterials)
                        .toStringAsFixed(1))
                    : 0;
              }

              int completedMaterials = getCompletedMaterials(
                  mainData[index]['Courses']['materials'] ?? [],
                  mainData[index]['studentsId']);

              int totalMaterials =
                  getTotalMaterials(mainData[index]['Courses']['materials']);

              double progressValue =
                  calculateProgressValue(completedMaterials, totalMaterials);

              bool completed = progressValue == 100.0;
              String x = progressValue.toString();
              Map<String, dynamic> courseData =
                  mainData[index]['Courses'] ?? {};

              print("This is everything :" + progressValue.toString());

              print("Completed is : " + completed.toString());
              if (completed) {
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
                            const SizedBox(
                              height: 5,
                            ),
                            Text(progressValue.toString() + " %"),
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
              } else {
                return Text("");
              }
            })
        : Center(child: Text('No data available'));
  }

  // Widget _packagesSection() {
  //   return ListView.builder(
  //     itemCount: packages.length,
  //     itemBuilder: (context, index) {
  //       return ListTile(
  //         title: Text(packages[index]['title'] ?? 'Unknown package'),
  //       );
  //     },
  //   );
  // }

  Widget _packagesSection() {
    return ListView.builder(
      itemCount: packageListData.length,
      itemBuilder: (context, index) {
        final package = packageListData[index];
        final activatedDate =
            DateTime.parse(packageListData[index]['activatedDate']);
        final expiryDate = DateTime.parse(packageListData[index]['expiryDate']);
        final daysLeft = expiryDate.difference(DateTime.now()).inDays;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  packageListData[index]['thumbnailUrl'][0],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package['packageName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Expires in $daysLeft days',
                      style: TextStyle(
                        color: daysLeft <= 7 ? Colors.red : Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      package['packageDescription'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
