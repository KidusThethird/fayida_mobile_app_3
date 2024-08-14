import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:online_course/models/packagelist.dart';

class PackageListServices {
//https://api.fayidaacademy.com/packages/fetchPackagesall
  String baseUrl = "https://api.fayidaacademy.com/";

  getAllPackages() async {
    List<Package> allPackages = [];

    try {
      var response =
          await http.get(Uri.parse(baseUrl + 'packages/fetchPackagesall'));
      if (response.statusCode == 200) {
        var data = response.body;
        var decodedData = jsonDecode(data);
        //  print(decodedData);

        for (var packageData in decodedData) {
          Package newPackage = Package.fromJson(packageData);
          allPackages.add(newPackage);
        }
        print(allPackages);
        return allPackages;
      }
    } catch (e) {
      print("error from catch" + e.toString());
      throw Exception(e.toString());
    }

    //  print("Hello from print");
  }
}
