import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

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
  bool isDownloaded = false;
  double progress = 0.0;
  bool isDownloading = false; // Track downloading state
  CancelToken cancelToken = CancelToken(); // Declare CancelToken

  @override
  void initState() {
    super.initState();
    fetchVideo();
    checkIfDownloaded();
  }

  Future<void> fetchVideo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('accessToken');

    if (authToken != null) {
      final Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $authToken';

      try {
        final response = await dio
            .get('https://api.fayidaacademy.com/materials/${widget.videoId}');

        if (response.statusCode == 200) {
          setState(() {
            var videoData = response.data;

            if (videoData['videoUrl'] is List &&
                videoData['videoUrl'].isNotEmpty) {
              videoUrl = videoData['videoUrl'][0];
            }

            if (videoData['video'] is Map) {
              var videoInfo = videoData['video'];
              videoTitle = videoInfo['vidTitle'] ?? 'No title available';
              videoDescription =
                  videoInfo['vidDescription'] ?? 'No description available';
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
        message = "No access token found. Please log in.";
        isLoading = false;
      });
    }
  }

  Future<void> checkIfDownloaded() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/downloaded_videos.json');

    if (await file.exists()) {
      final fileContents = await file.readAsString();
      final downloadedVideos = jsonDecode(fileContents);
      setState(() {
        isDownloaded =
            downloadedVideos.any((video) => video['id'] == widget.videoId);
      });
    }
  }

  Future<void> downloadVideo() async {
    if (isDownloading) {
      // If already downloading, do nothing
      return;
    } else {
      startDownload(); // Start the download if not already downloading
    }
  }

  Future<void> startDownload() async {
    setState(() {
      isDownloading = true; // Mark as downloading
      message = ''; // Reset the message
    });

    final directory = await getApplicationDocumentsDirectory();
    final videoPath = '${directory.path}/${widget.videoId}.mp4';
    progress = 0.0;

    try {
      final response = await Dio().download(
        videoUrl,
        videoPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress =
                  (received / total) * 100; // Convert progress to percentage
            });
          }
        },
      );

      if (response.statusCode == 200) {
        final file = File('${directory.path}/downloaded_videos.json');
        List<dynamic> downloadedVideos = [];
        if (await file.exists()) {
          final fileContents = await file.readAsString();
          downloadedVideos = jsonDecode(fileContents);
        }

        final newVideo = {
          'id': widget.videoId,
          'videoPath': videoPath,
          'title': videoTitle,
          'description': videoDescription,
        };

        downloadedVideos.add(newVideo);
        await file.writeAsString(jsonEncode(downloadedVideos));

        setState(() {
          isDownloaded = true;
          isDownloading = false; // Mark as not downloading
        });
      } else {
        setState(() {
          message = 'Failed to download video.';
          isDownloading = false; // Mark as not downloading
        });
      }
    } catch (e) {
      setState(() {
        message = "Error: $e";
        isDownloading = false; // Mark as not downloading
      });
    }
  }

  Widget _buildDownloadButton() {
    return ElevatedButton(
      onPressed: isDownloading
          ? null
          : downloadVideo, // Disable button while downloading
      child: Text(isDownloading
          ? 'Downloading ${progress.toStringAsFixed(0)}%' // Show progress while downloading
          : 'Download'), // Show "Download" when not downloading
    );
  }

  @override
  void dispose() {
    if (!isLoading) flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Details'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : message.isNotEmpty
              ? Center(child: Text(message))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: FlickVideoPlayer(
                            flickManager: flickManager,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (1 == 1)
                                ? MyCustomButton(
                                    materialId: widget.videoId,
                                  )
                                : Text("Seen"),
                            SizedBox(height: 4.0),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isDownloaded
                                ? Text(
                                    'Downloaded',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : _buildDownloadButton(), // Call the method here
                            SizedBox(height: 10.0),
                            Text(
                              videoTitle,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              videoDescription,
                              style: TextStyle(fontSize: 16),
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
