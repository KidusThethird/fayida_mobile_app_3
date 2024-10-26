import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/mybutton.dart';

class VideoDetailScreen extends StatefulWidget {
  final String videoId;

  VideoDetailScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late FlickManager flickManager;
  String videoUrl = '';
  String videoTitle = 'Loading...';
  String videoDescription = 'Loading...';
  String message = '';
  bool isLoading = true;
  bool isMaterialDone = false;

  @override
  void initState() {
    super.initState();
    fetchVideo();
  }

  Future<void> fetchVideo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cookieString = prefs.getString('cookies');

    if (cookieString != null) {
      // Print all cookie information
      print("Cookies: $cookieString");

      final Dio dio = Dio();
      dio.options.headers['Cookie'] = cookieString;

      try {
        final response = await dio
            .get('https://api.fayidaacademy.com/materials/${widget.videoId}');

        if (response.statusCode == 200) {
          setState(() {
            var videoData = response.data;

            // Uncomment and complete the logic for checking material completion
            // String studentId = _extractStudentIdFromCookies(cookieString);
            // isMaterialDone = videoData['StudentMaterial']?.any((item) =>
            //     item['StudentId'] == studentId &&
            //     item['Done'] == true) ??
            //     false;

            if (videoData is Map<String, dynamic>) {
              if (videoData['videoUrl'] is List) {
                var urls = videoData['videoUrl'];
                if (urls.isNotEmpty && urls[0] is String) {
                  videoUrl = urls[0];
                }
              }

              if (videoData['video'] is Map) {
                var videoInfo = videoData['video'];
                videoTitle = videoInfo['vidTitle'] ?? 'No title available';
                videoDescription =
                    videoInfo['vidDescription'] ?? 'No description available';
              }
            } else {
              message = 'Unexpected response format';
            }
            isLoading = false;

            // Initialize FlickManager with the video URL
            flickManager = FlickManager(
              videoPlayerController: VideoPlayerController.network(videoUrl),
            );
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
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("------------------This needs to be printed: " + widget.videoId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Details'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : message.isNotEmpty
              ? Center(child: Text(message))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width, // Full width
                        child: AspectRatio(
                          aspectRatio: 16 / 9, // 16:9 aspect ratio
                          child: FlickVideoPlayer(
                            flickManager: flickManager,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: 20.0), // Additional space above the text area
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 16.0), // Bottom padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (1 == 1)
                                ? MyCustomButton(
                                    materialId: widget.videoId,
                                  )
                                : Text("Seen"),
                            SizedBox(height: 10.0),
                            Text(
                              videoTitle,
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              videoDescription,
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
