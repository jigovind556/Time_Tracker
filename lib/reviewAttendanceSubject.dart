import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:time_trackr/global.dart';

import 'database_helper.dart';

class ReviewAttendancePage extends StatefulWidget {
  final String subjectName;

  ReviewAttendancePage({required this.subjectName});

  @override
  _ReviewAttendancePageState createState() => _ReviewAttendancePageState();
}

class _ReviewAttendancePageState extends State<ReviewAttendancePage> {
  late List<Map<String, dynamic>> attendanceData = [];
  late List<bool> showLectureColumns;
  late Map<String, Map<int, String>> organizedData = {};
  @override
  void initState() {
    super.initState();
    showLectureColumns = List<bool>.generate(10, (index) => false);
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final DatabaseHelper _databaseHelper = DatabaseHelper();
    final Database db = await _databaseHelper.database;
    attendanceData = await db.rawQuery('''
      SELECT Date, Lec_no, Att_Status FROM attendance_record
      WHERE Id = ? AND Subject = ?
      ORDER BY Date DESC, Lec_no ASC;
    ''', [user.id, widget.subjectName]);
    // print(attendanceData);
    for (int i = 0; i < attendanceData.length; i++) {
      // print(attendanceData[i]);
      showLectureColumns[attendanceData[i]['Lec_no'] - 1] = true;
    }

    // Loop through your existing attendanceData and organize it
    for (var data in attendanceData) {
      final date = data['Date'];
      final lectureNumber = data['Lec_no'];
      final status = data['Att_Status'];

      if (!organizedData.containsKey(date)) {
        organizedData[date] = {};
      }

      organizedData[date]![lectureNumber] = status;
    }
    print(organizedData);
    setState(() {});
  }

  Color _getColorForAttendance(String status) {
    switch (status) {
      case 'No class':
        return Colors.grey[300]!;
      case 'Holiday':
        return Colors.blue[100]!;
      case 'Absent':
        return Colors.red[100]!;
      case 'Present':
        return Colors.green[100]!;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName}'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Date')),
                for (int i = 1; i <= 10; i++)
                  if (showLectureColumns[i - 1])
                    DataColumn(label: Text('Lec $i')),
              ],
              rows: organizedData.keys.map((date) {
                List<DataCell> cells = [
                  DataCell(Text(date)),
                ];
                for (int i = 1; i <= 10; i++) {
                  if (showLectureColumns[i - 1]) {
                    String lectureStatus = organizedData[date]![i] ?? '';
                    cells.add(DataCell(
                      Container(
                        color: _getColorForAttendance(lectureStatus),
                        child: Center(child: Text(lectureStatus)),
                      ),
                    ));
                  }
                }
                return DataRow(cells: cells);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
