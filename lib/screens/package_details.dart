import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:getwidget/getwidget.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late String packageDetailsUrl;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    packageDetailsUrl = 'fayidaacademy.com/package_2/${widget.packageId}';
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: screenHeight / 2.2,
              pinned: true,
              backgroundColor: const Color.fromARGB(255, 189, 199, 189),
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: widget.packageName,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                    ),
                    child: SizedBox(
                      width: screenWidth,
                      child: Image.network(
                        widget.packageImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth / 20, vertical: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.packageName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 30,
                      ),
                    ),
                    GFButton(
                      onPressed: () async {
                        // var url = Uri.https('fayidaacademy.com',
                        //     '/package_2/26fd7472-1ef0-4072-b0fb-7550efea7e0a');
                        var url = Uri.https('fayidaacademy.com',
                            '/package_2/${widget.packageId}');
                        print("Can handle the req 000");

                        if (await canLaunchUrl(url)) {
                          print("Can handle the req");
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Could not launch $packageDetailsUrl')),
                          );
                        }
                      },
                      text: "More",
                      shape: GFButtonShape.pills,
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: FutureBuilder<Map<String, dynamic>>(
          future: fetchPackageDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          "Info",
                        ),
                      ),
                      Tab(
                        icon: Icon(Icons.book),
                        child: Text(
                          "Content",
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
                  Expanded(
                    child: GFTabBarView(
                      controller: tabController,
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth / 20, vertical: 15),
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
                        SingleChildScrollView(
                          child: Column(
                            children:
                                List.generate(data['courses'].length, (index) {
                              return Container(
                                margin: EdgeInsets.all(8.0),
                                color: Color.fromARGB(122, 8, 68, 21),
                                child: Center(
                                  child: GFAccordion(
                                    title:
                                        '${data['courses'][index]['courseName']}',
                                    content:
                                        '${data['courses'][index]['courseDescription']}',
                                    collapsedIcon: Icon(Icons.add),
                                    expandedIcon: Icon(Icons.minimize),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children:
                                List.generate(data['review'].length, (index) {
                              return Container(
                                margin: EdgeInsets.all(8.0),
                                color: Color.fromARGB(122, 8, 68, 21),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.all(8.0),
                                    padding: EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5.0,
                                          spreadRadius: 2.0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${data['review'][index]['text']}",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          "${data['review'][index]['Student']['firstName']} ${data['review'][index]['Student']['lastName']}",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text(
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
      ),
    );
  }
}
