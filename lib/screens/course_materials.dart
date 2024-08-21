import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:online_course/screens/video_details.dart';
import 'package:online_course/screens/file_details.dart';
import 'package:online_course/screens/link_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'assessment_details.dart';

class CourseMaterialsScreen extends StatefulWidget {
  final String id;

  CourseMaterialsScreen({required this.id});

  @override
  State<CourseMaterialsScreen> createState() => _CourseMaterialsScreenState();
}

class _CourseMaterialsScreenState extends State<CourseMaterialsScreen> {
  List<dynamic> courseData = [];
  String message = "";
  bool isLoading = true;
  List<dynamic> materials = [];
  String studentId = ''; // Store the student ID

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cookieString = prefs.getString('cookies');

    if (cookieString != null) {
      final Dio dio = Dio();
      dio.options.headers['Cookie'] = cookieString;

      try {
        final response = await dio.get(
            'https://api.fayidaacademy.com/purchaselist/specificStudentSingleCourse/${widget.id}');

        if (response.statusCode == 200) {
          setState(() {
            courseData = response.data;
            materials = courseData[0]['Courses']['materials'];
            studentId = courseData[0]['studentsId']; // Extract student ID
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

  @override
  Widget build(BuildContext context) {
    IconData getIconForMaterial(String materialType) {
      switch (materialType) {
        case 'video':
          return Icons.play_arrow;
        case 'assessment':
          return Icons.assignment;
        case 'link':
          return Icons.link;
        case 'file':
        default:
          return Icons.attach_file;
      }
    }

    // Group materials by part
    Map<String, List<dynamic>> groupedMaterials = {};
    for (var material in materials) {
      String part = material['part'] ?? 'Unknown Part';
      if (!groupedMaterials.containsKey(part)) {
        groupedMaterials[part] = [];
      }
      groupedMaterials[part]!.add(material);
    }

    List<dynamic> courseUnitsList = courseData.isNotEmpty
        ? courseData[0]['Courses']['CourseUnitsList'] ?? []
        : [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : message.isNotEmpty
                ? Text(message)
                : ListView.builder(
                    itemCount: groupedMaterials.keys.length,
                    itemBuilder: (context, partIndex) {
                      String part = groupedMaterials.keys.elementAt(partIndex);
                      List<dynamic> partMaterials = groupedMaterials[part]!;

                      // Get the corresponding unit title
                      String unitTitle = '';
                      if (partIndex < courseUnitsList.length) {
                        unitTitle = courseUnitsList[partIndex]['Title'] ?? '';
                      } else {
                        unitTitle =
                            'Extra Materials'; // Alternative title for extra units
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Chapter $part: $unitTitle',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: partMaterials.length,
                            itemBuilder: (context, index) {
                              var material = partMaterials[index];
                              String title;

                              // Determine the title based on material type
                              switch (material['materialType']) {
                                case 'video':
                                  title = material['video']?['vidTitle'] ??
                                      'No Title Available';
                                  break;
                                case 'assessment':
                                  title = material['assementId']
                                          ?['assesmentTitle'] ??
                                      'No Title Available';
                                  break;
                                case 'link':
                                  title = material['link']?['title'] ??
                                      'No Title Available';
                                  break;
                                case 'file':
                                default:
                                  title = material['file']?['title'] ??
                                      'No Title Available';
                                  break;
                              }

                              // Check if material is locked
                              bool isLocked = material['Access'] == 'locked';

                              // Check if the material is completed
                              bool isCompleted = material['StudentMaterial']
                                      ?.any((studentMaterial) =>
                                          studentMaterial['StudentId'] ==
                                              studentId &&
                                          studentMaterial['Done'] == true) ??
                                  false;

                              return ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLocked)
                                      Icon(Icons.lock, color: Colors.red),
                                    Icon(getIconForMaterial(
                                        material['materialType'])),
                                  ],
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(title),
                                    if (isCompleted)
                                      Icon(Icons.check, color: Colors.green),
                                  ],
                                ),
                                subtitle: isLocked
                                    ? Text('Locked',
                                        style: TextStyle(color: Colors.red))
                                    : null,
                                onTap: () {
                                  if (material['materialType'] == 'video') {
                                    String videoId = material?['id'] ??
                                        ''; // Get the video ID
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VideoDetailScreen(videoId: videoId),
                                      ),
                                    );
                                  } else if (material['materialType'] ==
                                      'file') {
                                    String fileId = material?['id'] ??
                                        ''; // Get the file ID
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FileDetailScreen(fileId: fileId),
                                      ),
                                    );
                                  } else if (material['materialType'] ==
                                      'link') {
                                    String linkId = material?['id'] ??
                                        ''; // Get the link ID
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LinkScreen(
                                            materialId:
                                                linkId), // Navigate to LinkScreen
                                      ),
                                    );
                                  } else if (material['materialType'] ==
                                      'assessment') {
                                    String assessmentId = material?['id'] ??
                                        ''; // Get the assessment ID
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AssessmentScreen(
                                          assessmentId: assessmentId,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
}
