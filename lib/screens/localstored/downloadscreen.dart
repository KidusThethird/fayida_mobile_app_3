import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';

class DownloadedVideosScreen extends StatefulWidget {
  @override
  State<DownloadedVideosScreen> createState() => _DownloadedVideosScreenState();
}

class _DownloadedVideosScreenState extends State<DownloadedVideosScreen> {
  List<dynamic> downloadedVideos = [];

  @override
  void initState() {
    super.initState();
    loadDownloadedVideos();
  }

  Future<void> loadDownloadedVideos() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/downloaded_videos.json');

    if (await file.exists()) {
      final fileContents = await file.readAsString();
      setState(() {
        downloadedVideos = jsonDecode(fileContents);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Downloaded Videos'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: downloadedVideos.isEmpty
          ? Center(child: Text('No downloaded videos available.'))
          : ListView.builder(
              itemCount: downloadedVideos.length,
              itemBuilder: (context, index) {
                final video = downloadedVideos[index];
                return ListTile(
                  title: Text(video['title']),
                  subtitle: Text(video['description']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          videoPath: video['videoPath'],
                          title: video['title'],
                          description: video['description'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String title;
  final String description;

  VideoPlayerScreen({
    required this.videoPath,
    required this.title,
    required this.description,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.file(File(widget.videoPath)),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.description,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
