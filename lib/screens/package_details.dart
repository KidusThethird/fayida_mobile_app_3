import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:getwidget/getwidget.dart';

class PackageDetailsScreen extends StatefulWidget {
  final String packageId;
  final String packageImage;
  final String packageName;

  const PackageDetailsScreen({
    Key? key,
    required this.packageId,
    required this.packageImage,
    required this.packageName,
  }) : super(key: key);

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchPackageDetails() async {
    final response = await http.get(Uri.parse(
        'https://api.fayidaacademy.com/packages/${widget.packageId}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load package details');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.packageName,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
                child: SizedBox(
                  height: screenHeight / 2.2,
                  width: screenWidth,
                  child: Image.network(
                    widget.packageImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth / 20, vertical: 20),
              child: Text(
                widget.packageName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 30,
                ),
              ),
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: fetchPackageDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 20),
                    child: const Text(
                      'Loading description...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 20),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  var data = snapshot.data!;
                  return Column(
                    children: [
                      GFTabBar(
                        length: 3,
                        controller: tabController,
                        tabBarColor: Color.fromARGB(47, 9, 95, 12),
                        labelColor: Colors.black,
                        tabs: [
                          Tab(
                            icon: Icon(Icons.info),
                            child: Text(
                              "About",
                            ),
                          ),
                          Tab(
                            icon: Icon(Icons.book),
                            child: Text(
                              "Courses",
                            ),
                          ),
                          Tab(
                            icon: Icon(Icons.comment),
                            child: Text(
                              "Reviews",
                            ),
                          ),
                        ],
                      ),
                      GFTabBarView(
                          controller: tabController,
                          children: <Widget>[
                            Container(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth / 20, vertical: 20),
                                child: Text(
                                  '${data['packageDescription']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(221, 10, 77, 13),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Container(color: Colors.green),
                            Container(color: Colors.blue)
                          ]),
                    ],
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 20),
                    child: const Text(
                      'No description found',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
