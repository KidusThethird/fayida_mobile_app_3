// lib/data.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Define your model class
class Package {
  final String id;
  final String packageName;
  final String price;
  final String? price2;
  final String? price3;
  final String? temporaryPrice;
  final String? temporaryPrice2;
  final String? temporaryPrice3;
  final bool discountStatus;
  final String? discountExpiryDate;
  final bool status;
  final bool displayOnHome;
  final String thumbnail;
  final String? trailer;
  final String createdAt;
  final String packageDescription;
  final String? sectionsId;
  final String? group;
  final String? group2;
  final String? extra1;
  final String? extra2;
  final String tag;
  final List<dynamic> courses;
  final List<String> imgUrl;

  Package({
    required this.id,
    required this.packageName,
    required this.price,
    this.price2,
    this.price3,
    this.temporaryPrice,
    this.temporaryPrice2,
    this.temporaryPrice3,
    required this.discountStatus,
    this.discountExpiryDate,
    required this.status,
    required this.displayOnHome,
    required this.thumbnail,
    this.trailer,
    required this.createdAt,
    required this.packageDescription,
    this.sectionsId,
    this.group,
    this.group2,
    this.extra1,
    this.extra2,
    required this.tag,
    required this.courses,
    required this.imgUrl,
  });

  // Factory method to create a Package instance from JSON
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
      discountExpiryDate: json['discountExpiryDate'],
      status: json['status'],
      displayOnHome: json['displayOnHome'],
      thumbnail: json['thumbnail'],
      trailer: json['trailer'],
      createdAt: json['createdAt'],
      packageDescription: json['packageDescription'],
      sectionsId: json['sectionsId'],
      group: json['group'],
      group2: json['group2'],
      extra1: json['extra1'],
      extra2: json['extra2'],
      tag: json['tag'],
      courses: List<dynamic>.from(json['courses']),
      imgUrl: List<String>.from(json['imgUrl']),
    );
  }

  // Method to convert a Package instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageName': packageName,
      'price': price,
      'price2': price2,
      'price3': price3,
      'temporaryPrice': temporaryPrice,
      'temporaryPrice2': temporaryPrice2,
      'temporaryPrice3': temporaryPrice3,
      'discountStatus': discountStatus,
      'discountExpiryDate': discountExpiryDate,
      'status': status,
      'displayOnHome': displayOnHome,
      'thumbnail': thumbnail,
      'trailer': trailer,
      'createdAt': createdAt,
      'packageDescription': packageDescription,
      'sectionsId': sectionsId,
      'group': group,
      'group2': group2,
      'extra1': extra1,
      'extra2': extra2,
      'tag': tag,
      'courses': courses,
      'imgUrl': imgUrl,
    };
  }
}

// Function to fetch the package data from the API
Future<Package> fetchPackage() async {
  final response = await http.get(Uri.parse('https://api.example.com/package'));

  if (response.statusCode == 200) {
    return Package.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load package');
  }
}
