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
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance for ${widget.subjectName}'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Date')),
            for (int i = 1; i <= 10; i++)
              if (showLectureColumns[i - 1]) DataColumn(label: Text('Lec $i')),
          ],
          rows: attendanceData.map((data) {
            List<DataCell> cells = [
              DataCell(Text(data['Date'])),
            ];
            for (int i = 1; i <= 10; i++) {
              if (showLectureColumns[i - 1]) {
                String lectureStatus = '';
                if (data['Lec_no'] == i) {
                  lectureStatus = data['Att_Status'];
                }
                cells.add(DataCell(
                  Container(
                    color: _getColorForAttendance(lectureStatus),
                    child: Text(lectureStatus),
                  ),
                ));
              }
            }
            return DataRow(cells: cells);
          }).toList(),
        ),
      ),
    );
  }
}
