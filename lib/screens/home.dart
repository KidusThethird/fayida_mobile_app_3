import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:online_course/screens/prizeslist.dart';
import 'package:online_course/theme/color.dart';
import 'package:online_course/utils/data.dart';
//import 'package:online_course/utils/fetch_package_model.dart';
import 'dart:convert';

import '../models/bloglist.dart';
import '../models/packagelist.dart';

import 'package:online_course/widgets/category_box.dart';
//import 'package:online_course/widgets/feature_item.dart';
import 'package:online_course/widgets/notification_box.dart';
import 'package:online_course/widgets/recommend_item.dart';

import 'package:http/http.dart' as http;

import '../services/blogList_services.dart';
import '../widgets/blog_item.dart';

import '../services/packageList_services.dart';
import '../widgets/drawer.dart';
import '../widgets/package_item.dart';
import 'leader_board.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future getPackageList() async {
    var response = await http
        .get(Uri.https('api.fayidaacademy.com', 'packages/fetchPackagesall'));
    var jsonData = jsonDecode(response.body);
    print("response.body");
  }

  @override
  void initState() {
    print("comon");
    PackageListServices().getAllPackages();

    super.initState();
    getPackageList(); // Call this in initState to load data when the widget is created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColor.appBarColor,
            pinned: true,
            snap: true,
            floating: true,
            title: _buildAppBar(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildBody(),
              childCount: 1,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Image.asset(
            'assets/images/smalllogo.png',
            width: 100,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Add your menu bar icon functionality here
            print('Menu bar icon tapped');
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            // child: Icon(
            //   Icons.menu,
            //   color: AppColor.textColor,
            // ),
          ),
        )
      ],
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategories(),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: Text(
              "Featured Packages",
              style: TextStyle(
                color: AppColor.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
          ),
          _buildFeatured(),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Blogs",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textColor),
                ),
                // Text(
                //   "See all",
                //   style: TextStyle(fontSize: 14, color: AppColor.darker),
                // ),
              ],
            ),
          ),
          _buildBlog(),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle first button click
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text('Explore'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrizesScreen()),
                );
                // Handle second button click
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text('Prize'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderBoardScreen()),
                );
                // Handle third button click
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text('Leaderboard'),
            ),
          ),
        ),
      ],
    );
  }

  _buildFeatured() {
    return FutureBuilder(
        future: PackageListServices().getAllPackages(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error fetching package data"),
            );
          }
          if (snapshot.hasData) {
            var packageData = snapshot.data as List<Package>;

            return CarouselSlider(
              options: CarouselOptions(
                height: 290,
                enlargeCenterPage: true,
                disableCenter: true,
                viewportFraction: .75,
              ),
              items: List.generate(
                packageData.length,
                (index) => PackageItem(data: packageData[index]),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  _buildBlog() {
    return FutureBuilder(
        future: BlogListServices().getAllBlogs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error fetching blog data"),
            );
          }
          if (snapshot.hasData) {
            var blogData = snapshot.data as List<Blog>;

            return CarouselSlider(
              options: CarouselOptions(
                height: 100,
                enlargeCenterPage: true,
                disableCenter: true,
                viewportFraction: .75,
              ),
              items: List.generate(
                blogData.length,
                (index) => BlogItem(data: blogData[index]),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });

    // return SingleChildScrollView(
    //   padding: EdgeInsets.fromLTRB(15, 5, 0, 5),
    //   scrollDirection: Axis.horizontal,
    //   child: Row(
    //     children: List.generate(
    //       recommends.length,
    //       (index) => Padding(
    //         padding: const EdgeInsets.only(right: 10),
    //         child: RecommendItem(
    //           data: recommends[index],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
