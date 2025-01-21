import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'localvideo.dart';

class CourseMaterialsFromLocalStorageScreen extends StatefulWidget {
  @override
  State<CourseMaterialsFromLocalStorageScreen> createState() =>
      _CourseMaterialsFromLocalStorageScreenState();
}

class _CourseMaterialsFromLocalStorageScreenState
    extends State<CourseMaterialsFromLocalStorageScreen> {
  List<dynamic> courseData = [];
  List<dynamic> materials = [];
  String studentId = ''; // Store the student ID

  @override
  void initState() {
    super.initState();
    _loadDataFromLocalStorage();
  }

  Future<void> _loadDataFromLocalStorage() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/specificStudentCourses.json');

    if (await file.exists()) {
      final fileContents = await file.readAsString();
      final loadedData = jsonDecode(fileContents);
      setState(() {
        courseData = loadedData;
        materials = courseData[0]['Courses']['materials'];
        studentId = courseData[0]['studentsId']; // Extract student ID
      });
    } else {
      setState(() {
        materials = [];
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
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
        title: Text('Course Materials (Offline)'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: materials.isEmpty
          ? Center(child: Text('No materials found in local storage.'))
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
                            title = material['assementId']?['assesmentTitle'] ??
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
                        bool isCompleted = material['StudentMaterial']?.any(
                                (studentMaterial) =>
                                    studentMaterial['StudentId'] == studentId &&
                                    studentMaterial['Done'] == true) ??
                            false;

                        return ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLocked) Icon(Icons.lock, color: Colors.red),
                              Icon(
                                  getIconForMaterial(material['materialType'])),
                            ],
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            if (material['materialType'] == 'video' &&
                                !isLocked) {
                              String videoId =
                                  material?['id'] ?? ''; // Get the video ID
                              // Navigate to the video screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HelloWorldScreen()
                                    // VideoDetailScreen(videoId: videoId),
                                    ),
                              );
                            } else if (material['materialType'] == 'file' &&
                                !isLocked) {
                              String fileId =
                                  material?['id'] ?? ''; // Get the file ID
                              // Navigate to the file screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HelloWorldScreen()
                                    //HelloWorldScreen(fileId: fileId),
                                    ),
                              );
                            }

                            // else if (material['materialType'] == 'link' &&
                            //     !isLocked) {
                            //   String linkId = material?['id'] ?? ''; // Get the link ID
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) =>
                            //           LinkScreen(materialId: linkId),
                            //     ),
                            //   );
                            // }

                            //   else if (material['materialType'] == 'assessment' &&
                            //       !isLocked) {
                            //     String assessmentId = material?['id'] ?? ''; // Get the assessment ID
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) =>
                            //             AssessmentScreen(assessmentId: assessmentId),
                            //       ),
                            //     );
                            //   }
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
