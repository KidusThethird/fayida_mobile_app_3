class CourseDetails {
  final String id;
  final int courseIndex;
  final bool displayOnHome;
  final String instructorName;
  final String title;
  final String subTitle;
  final String description;
  final String thumbnail;
  final DateTime createdAt;
  final String? extra1;
  final String? extra2;
  final List<String> imgUrl;

  CourseDetails({
    required this.id,
    required this.courseIndex,
    required this.displayOnHome,
    required this.instructorName,
    required this.title,
    required this.subTitle,
    required this.description,
    required this.thumbnail,
    required this.createdAt,
    this.extra1,
    this.extra2,
    required this.imgUrl,
  });

  factory CourseDetails.fromJson(Map<String, dynamic> json) {
    return CourseDetails(
      id: json['id'],
      courseIndex: json['courseIndex'],
      displayOnHome: json['displayOnHome'].toLowerCase() == 'true',
      instructorName: json['instructorName'],
      title: json['title'],
      subTitle: json['subTitle'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      createdAt: DateTime.parse(json['createdAt']),
      extra1: json['extra1'],
      extra2: json['extra2'],
      imgUrl: List<String>.from(json['imgUrl']),
    );
  }
}
