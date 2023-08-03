import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:time_trackr/shared_pref.dart';
import 'package:flutter_chart/flutter_chart.dart';
import 'package:time_trackr/vennDiagram.dart';

import 'database_helper.dart';
import 'global.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> subjectsData = [];
  bool _visitedOtherPage = false;

  @override
  void initState() {
    super.initState();
    getSubjectData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_visitedOtherPage) {
      // Refresh data when the user comes back from other pages
      getSubjectData();
      _visitedOtherPage = false;
    }
  }

  Future<void> getSubjectData() async {
    final DatabaseHelper _databaseHelper = DatabaseHelper();
    final Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> temp = await db.rawQuery('''
      SELECT * FROM subject_name
      WHERE Id=?
    ''', [user.id]);

    setState(() {
      subjectsData = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: NavigationPanel(onPageVisited: () {
        setState(() {
          _visitedOtherPage = true;
        });
      }), // Adding the custom drawer here
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Attendance Calculator App!'),
            SizedBox(height: 20),
            // Display Pie Chart
            subjectsData.isEmpty
                ? NoSubjectsWidget() // Show NoSubjectsWidget when no subjects are available
                : AttendancePercentagePieChart(),
          ],
        ),
      ),
    );
  }
}

// Rest of the code remains the same as before.

class NavigationPanel extends StatelessWidget {
  final VoidCallback onPageVisited;

  NavigationPanel({required this.onPageVisited});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        // width: MediaQuery.of(context).size.width * 0.65, // 65% of screen width
        color: Theme.of(context).primaryColor, // Use primary theme color for background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              // padding: EdgeInsets.symmetric(vertical: 1, horizontal: 16), // Adjust the padding here
              child: Text(
                user.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(
              color: Colors.white,
              thickness: 2,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    onTap: () async {
                      onPageVisited(); // Notify the HomePage that the user visited another page
                      Navigator.pushNamed(context, '/home');
                    },
                    title: Text(
                      "Home",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      onPageVisited(); // Notify the HomePage that the user visited another page
                      Navigator.pushNamed(context, '/attendaceEntry');
                    },
                    title: Text(
                      "Enter Attendance",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      onPageVisited(); // Notify the HomePage that the user visited another page
                      Navigator.pushNamed(context, '/timeTableEntry');
                    },
                    title: Text(
                      "Edit Time Table",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              onTap: () async {
                onPageVisited(); // Notify the HomePage that the user visited another page
                SharedPref sharedPref = SharedPref();
                await sharedPref.remove("user");
                Navigator.pushReplacementNamed(context, '/login');
              },
              title: Text(
                "Log Out",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class AttendancePercentagePieChart extends StatefulWidget {
  @override
  _AttendancePercentagePieChartState createState() =>
      _AttendancePercentagePieChartState();
}

class _AttendancePercentagePieChartState
    extends State<AttendancePercentagePieChart> {
  List<Map<String, dynamic>> subjectsData = [];

  @override
  void initState() {
    super.initState();
    getSubjectData();
  }

  Future<void> getSubjectData() async {
    final DatabaseHelper _databaseHelper = DatabaseHelper();
    final Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> temp = await db.rawQuery('''
      SELECT * FROM subject_name
      WHERE Id=?
    ''', [user.id]);

    setState(() {
      subjectsData = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: subjectsData.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> subjectData = subjectsData[index];
          return VennDiagram(
            subject: subjectData['Subject'],
            attendance: subjectData['Attendance'],
            classTillDate: subjectData['classTillDate'],
          );
        },
      ),
    );
  }
}


class NoSubjectsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No subjects added yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please add subjects in the Time Table section to view attendance percentage.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}