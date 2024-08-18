class Blog {
  final String id;
  final int blogIndex;
  final bool displayOnHome;
  final String writtenBy;
  final String title;
  final String subTitle;
  final String text;
  final String image;
  final DateTime createdAt;
  final String? extra1;
  final String? extra2;
  final List<String> imgUrl;

  Blog({
    required this.id,
    required this.blogIndex,
    required this.displayOnHome,
    required this.writtenBy,
    required this.title,
    required this.subTitle,
    required this.text,
    required this.image,
    required this.createdAt,
    this.extra1,
    this.extra2,
    required this.imgUrl,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      blogIndex: json['blogIndex'],
      displayOnHome: json['displayOnHome'].toLowerCase() == 'true',
      writtenBy: json['writtenBy'],
      title: json['title'],
      subTitle: json['subTitle'],
      text: json['text'],
      image: json['image'],
      createdAt: DateTime.parse(json['createdAt']),
      extra1: json['extra1'],
      extra2: json['extra2'],
      imgUrl: List<String>.from(json['imgUrl']),
    );
  }
}
