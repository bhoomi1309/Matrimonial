import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:matrimonial/database/user_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'User.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  final User _user = User();
  List<Map<String, dynamic>> list = [];
  bool _isLoading = true;
  int maleCount = 0;
  int femaleCount = 0;
  Map<String, int> hobbiesCount = {};
  Map<String, int> ageGroups = {
    '18-25': 0,
    '26-35': 0,
    '36-45': 0,
    '46-55': 0,
    '56+': 0,
  };

  Future<void> _fetchUsers() async {
    try {
      List<Map<String, dynamic>> users = await _user.getUserList();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? loggedInUserId = prefs.getString(UserDatabase.USER_ID);
      int id = int.parse(loggedInUserId!);

      List<Map<String, dynamic>> filteredUsers = users.where((user) => user[UserDatabase.USER_ID] != id).toList();
      maleCount = filteredUsers.where((user) => user[UserDatabase.GENDER] == 'Male').length;
      femaleCount = filteredUsers.where((user) => user[UserDatabase.GENDER] == 'Female').length;

      ageGroups = {
        '0-18': filteredUsers.where((user) => user[UserDatabase.AGE] < 18).length,
        '18-25': filteredUsers.where((user) => user[UserDatabase.AGE] >= 18 && user[UserDatabase.AGE] <= 25).length,
        '26-35': filteredUsers.where((user) => user[UserDatabase.AGE] >= 26 && user[UserDatabase.AGE] <= 35).length,
        '36-45': filteredUsers.where((user) => user[UserDatabase.AGE] >= 36 && user[UserDatabase.AGE] <= 45).length,
        '46-55': filteredUsers.where((user) => user[UserDatabase.AGE] >= 46 && user[UserDatabase.AGE] <= 55).length,
        '56+': filteredUsers.where((user) => user[UserDatabase.AGE] >= 56).length,
      };

      hobbiesCount.clear();
      for (var user in filteredUsers) {
        List<String> hobbies = (user[UserDatabase.HOBBIES] as String).split(',');
        for (var hobby in hobbies) {
          hobbiesCount[hobby] = (hobbiesCount[hobby] ?? 0) + 1;
        }
      }

      setState(() {
        list = filteredUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    // Generate Bar Chart Data for Age Distribution
    List<BarChartGroupData> bars = ageGroups.entries.map((entry) {
      return BarChartGroupData(
        x: ageGroups.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blueAccent,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    }).toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Male-Female Ratio
              const Text(
                'Male-Female Ratio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: maleCount.toDouble(),
                        title: 'Male',
                        color: Colors.blue,
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        value: femaleCount.toDouble(),
                        title: 'Female',
                        color: Colors.pink.shade200,
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Age Distribution
              const Text(
                'Age Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    barGroups: bars,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < 0 || value.toInt() >= ageGroups.length) return Container();
                            return Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                ageGroups.keys.elementAt(value.toInt()),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}