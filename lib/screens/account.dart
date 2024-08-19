import 'package:flutter/material.dart';
import 'package:online_course/theme/color.dart';
import 'package:online_course/utils/data.dart';
import 'package:online_course/widgets/custom_image.dart';
import 'package:online_course/widgets/setting_box.dart';
import 'package:online_course/widgets/setting_item.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/persistent_cookie_jar.dart';
import 'login.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? firstName;
  String? lastName;
  String? grade;
  String? phoneNumber;
  String? age;
  String? status;
  String? email;
  String? points;
  String? grandName;
  String? city;
  String? region;
  String? school;
  String? gender;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cookieString = prefs.getString('cookies');

    if (cookieString != null) {
      final Dio dio = Dio();
      dio.options.headers['Cookie'] = cookieString;

      try {
        final response = await dio
            .get('https://api.fayidaacademy.com/login_register/profile');

        if (response.statusCode == 200) {
          setState(() {
            firstName = response.data['firstName'];
            lastName = response.data['lastName'];
            grade = response.data['gread'];
            phoneNumber = response.data['phoneNumber'];
            age = response.data['age'];
            status = response.data['studentStatus'];
            email = response.data['email'];
            points = response.data['points'];
            grandName = response.data['grandName'];
            city = response.data['city'];
            region = response.data['region'];
            school = response.data['schoolName'];
            gender = response.data['gender'];
          });
        }
      } catch (e) {
        // Handle error if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (firstName == null && lastName == null) {
      // Show loading screen while data is being fetched
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: AppColor.appBgColor,
          pinned: true,
          snap: true,
          floating: true,
          title: _buildHeader(),
        ),
        SliverToBoxAdapter(child: _buildBody())
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Account",
          style: TextStyle(
            color: AppColor.textColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          _buildProfile(),
          const SizedBox(height: 20),
          _buildRecord(),
          const SizedBox(height: 20),
          _buildSection1(),
          const SizedBox(height: 20),
          // _buildSection2(),
          // const SizedBox(height: 20),
          _buildSection3(),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Column(
      children: [
        Icon(
          Icons.person,
          size: 70,
          color: Color.fromARGB(
              255, 11, 82, 17), // Use your desired color for the icon
        ),
        const SizedBox(height: 10),
        Text(
          '$firstName $lastName',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecord() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SettingBox(
            title: 'Status: $status',
            icon: "assets/icons/profile.svg",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SettingBox(
            title: "$grade",
            icon: "assets/icons/more.svg",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SettingBox(
            title: 'Points: $points',
            icon: "assets/icons/star.svg",
          ),
        ),
      ],
    );
  }

  Widget _buildSection1() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppColor.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          itemProfile(
            'Full Name',
            '$firstName $lastName $grandName',
            Icons.person,
          ),
          itemProfile(
            'Email',
            '$email',
            Icons.email,
          ),
          itemProfile(
            'School',
            '$school',
            Icons.school,
          ),
          itemProfile(
            'City',
            '$city',
            Icons.location_history,
          ),
          itemProfile(
            'Region',
            '$region',
            Icons.location_city,
          ),
          itemProfile(
            'Age',
            '$age',
            Icons.calendar_view_day,
          ),
          itemProfile(
            'Gender',
            '$gender',
            Icons.male,
          ),
          itemProfile(
            'Phone Number',
            '$phoneNumber',
            Icons.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildSection3() {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppColor.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          _logout();
        },
        child: SettingItem(
          title: "Log Out",
          leadingIcon: "assets/icons/logout.svg",
          bgIconColor: AppColor.darker,
        ),
      ),
    );
  }

  itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 5),
                color: Color.fromARGB(255, 14, 82, 12).withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        tileColor: Colors.white,
      ),
    );
  }

  void _logout() async {
    // Create an instance of PersistentCookieJar
    final cookieJar = PersistentCookieJar();

    // Delete all cookies to clear the session
    await cookieJar.deleteAll();

    // Navigate to LoginScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false, // Remove all previous routes
    );
  }
}
