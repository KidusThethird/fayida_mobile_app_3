class Package {
  final String id;
  final String? packageName;
  final String? price;
  final String? price2;
  final String? price3;
  final String? temporaryPrice;
  final String? temporaryPrice2;
  final String? temporaryPrice3;
  final bool? discountStatus;
  final String? discountExpiryDate;
  final bool? status;
  final bool? displayOnHome;
  final String? thumbnail;
  final String? trailer;
  final DateTime? createdAt;
  final String? packageDescription;
  final String? sectionsId;
  final String? group;
  final String? group2;
  final String? extra1;
  final String? extra2;
  final String? tag;
  final List<dynamic>? courses;
  final List<String>? imgUrl;

  Package({
    required this.id,
    this.packageName,
    this.price,
    this.price2,
    this.price3,
    this.temporaryPrice,
    this.temporaryPrice2,
    this.temporaryPrice3,
    this.discountStatus,
    this.discountExpiryDate,
    this.status,
    this.displayOnHome,
    this.thumbnail,
    this.trailer,
    this.createdAt,
    this.packageDescription,
    this.sectionsId,
    this.group,
    this.group2,
    this.extra1,
    this.extra2,
    this.tag,
    this.courses,
    this.imgUrl,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      packageName: json['packageName'],
      price: json['price'],
      price2: json['price2'],
      price3: json['price3'],
      temporaryPrice: json['temporaryPrice'],
      temporaryPrice2: json['temporaryPrice2'],
      temporaryPrice3: json['temporaryPrice3'],
      discountStatus: json['discountStatus'],
      discountExpiryDate: json['discountExpriyDate'],
      status: json['status'],
      displayOnHome: json['displayOnHome'],
      thumbnail: json['thumbnail'],
      trailer: json['trailer'],
      createdAt: DateTime.parse(json['createdAt']),
      packageDescription: json['packageDescription'],
      sectionsId: json['sectionsId'],
      group: json['group'],
      group2: json['group2'],
      extra1: json['extra1'],
      extra2: json['extra2'],
      tag: json['tag'],
      courses: json['courses'],
      imgUrl: List<String>.from(json['imgUrl']),
    );
  }
}
