import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LeaderBoardScreen extends StatefulWidget {
  @override
  _LeaderBoardScreenState createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  List<dynamic> leaderboardData = [];

  @override
  void initState() {
    super.initState();
    fetchLeaderboardData();
  }

  Future<void> fetchLeaderboardData() async {
    final url =
        Uri.parse('https://api.fayidaacademy.com/leaderboard/all/toptwenty');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        leaderboardData = json.decode(response.body);
      });
    } else {
      // Handle error
      print('Error fetching leaderboard data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: Color.fromARGB(255, 7, 49, 9),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Rank')),
              DataColumn(label: Text('First Name')),
              DataColumn(label: Text('Last Name')),
              DataColumn(label: Text('Grade')),
              DataColumn(label: Text('Points')),
            ],
            rows: leaderboardData
                .asMap()
                .map((index, data) => MapEntry(
                      index,
                      DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (index == 0) {
                              return Colors.amber[100];
                            } else if (index == 1) {
                              return Colors.grey[200];
                            } else if (index == 2) {
                              return Colors.brown[100];
                            }
                            return null; // Use the default value.
                          },
                        ),
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(data['firstName'])),
                          DataCell(Text(data['lastName'])),
                          DataCell(Text(data['gread'])),
                          DataCell(Text(data['points'])),
                        ],
                      ),
                    ))
                .values
                .toList(),
          ),
        ),
      ),
    );
  }
}
