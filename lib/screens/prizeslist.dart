import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrizesScreen extends StatefulWidget {
  @override
  _PrizesScreenState createState() => _PrizesScreenState();
}

class _PrizesScreenState extends State<PrizesScreen> {
  List<dynamic> prizes = [];
  Map<String, dynamic> userProfile = {};
  final Dio _dio = Dio();
  var myData;
  String? _firstName;
  double? _userPoints;

  @override
  void initState() {
    super.initState();
    _initializeCookies();
  }

  Future<void> _initializeCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    final cookieString = prefs.getString('cookies');
    final String? authToken = prefs.getString('accessToken');

    if (authToken != null) {
      // Adding cookies to Dio
      //_dio.options.headers['Cookie'] = cookieString;
      _dio.options.headers['Authorization'] = 'Bearer $authToken';
      // Fetch user profile data
      await _fetchUserProfile();
      // Fetch prizes data
      await _fetchPrizes();
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await _dio
          .get('https://api.fayidaacademy.com/login_register/profile');
      if (response.statusCode == 200) {
        setState(() {
          myData = response.data;
          _firstName = response.data['firstName'];
          _userPoints = double.parse(response.data['points'].toString());
        });
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _fetchPrizes() async {
    try {
      final response =
          await _dio.get('https://api.fayidaacademy.com/prizes/fetchprizes');
      if (response.statusCode == 200) {
        setState(() {
          prizes = response.data;
        });
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showPurchaseDialog(
      double prizePoints, String prizeId, String prizeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Purchase'),
        content: Text(
            'You have $_userPoints points. Are you sure you want to redeem this prize for $prizePoints points?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
              onPressed: () {
                _handlePurchase(prizePoints, prizeId, prizeName);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                backgroundColor: Color.fromARGB(
                    255, 7, 49, 9), // Make the button background transparent
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(
      double prizePoints, String prizeId, String prizeName) async {
    if (_userPoints != null && _userPoints! < prizePoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You dont have enough points to redeem this prize.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      try {
        final response = await _dio.post(
          'https://api.fayidaacademy.com/studentprize',
          data: {
            'prizeId': prizeId,
            'prizePoint': prizePoints.toString(),
            'itemName': prizeName,
          },
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase successful!'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Handle error
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prizes'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: Column(
        children: [
          // Display user profile information
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: prizes.length,
              itemBuilder: (context, index) {
                final prize = prizes[index];
                return GestureDetector(
                  onTap: () => _showPurchaseDialog(
                    double.parse(prize['points']),
                    prize['id'],
                    prize['itemName'],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            prize['imgUrl'][0],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prize['itemName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(prize['itemDecription']),
                              SizedBox(height: 8.0),
                              Text('Points: ${prize['points']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
