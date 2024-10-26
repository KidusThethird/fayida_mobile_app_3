import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:online_course/screens/package_details.dart';

class PackageScreen extends StatefulWidget {
  final String filterKeyExtracted;

  const PackageScreen({Key? key, required this.filterKeyExtracted})
      : super(key: key);

  @override
  _PackageScreenState createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  List<dynamic> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  Future<void> fetchPackages() async {
    final url =
        'https://api.fayidaacademy.com/packages/filter_fetch_home_packages/${widget.filterKeyExtracted}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          packages = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load packages');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching packages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Packages'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : packages.isEmpty
              ? Center(child: Text('No packages found.'))
              : GridView.builder(
                  padding: EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PackageDetailsScreen(
                              packageId: package['id'],
                              packageImage: package['imgUrl'][0],
                              packageName: package['packageName'],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                package['imgUrl'][0],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Center(
                            child: Text(
                              package['packageName'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
