import 'package:http/http.dart' as http;
import 'dart:convert';

class PackageListServices {
//https://api.fayidaacademy.com/packages/fetchPackagesall
  String baseUrl = "https://api.fayidaacademy.com/";

  getAllPackages() async {
    try {
      var response =
          await http.get(Uri.parse(baseUrl + 'packages/fetchPackagesall'));
      if (response.statusCode == 200) {
        var data = response.body;
        var decodedData = jsonDecode(data);
        print(data);
      }
    } catch (e) {
      print("error from catch" + e.toString());
      throw Exception(e.toString());
    }

    print("Hello from print");
  }
}
