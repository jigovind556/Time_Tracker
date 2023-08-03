import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';
import 'global.dart';

class AttendanceEntryPage extends StatefulWidget {
  @override
  _AttendanceEntryPageState createState() => _AttendanceEntryPageState();
}

class _AttendanceEntryPageState extends State<AttendanceEntryPage> {
  DateTime _selectedDate = DateTime.now();
  final List<String> attendanceTypes = [
    'Present',
    'Absent',
    'Holiday',
    'No class'
  ];

  String selectedDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

  void initState() {
    super.initState();
    initializeTimetableData();
  }

  List<Map<String, dynamic>> timetableData = [];
  Future<void> initializeTimetableData() async {
    // Database database = await openDatabase(
    //   'attendance.db', // Replace 'attendance.db' with your actual database file name
    //   version: 1,
    // );
    String date = DateFormat('yyyy-MM-dd').format(_selectedDate);
    print(date);
    final DatabaseHelper _databaseHelper = DatabaseHelper();
    final Database db = await _databaseHelper.database;

    int dayOfWeek = DateTime.parse(date).weekday;

    timetableData = await db.rawQuery('''
      SELECT * FROM time_table
      WHERE id=? and day = ? 
      GROUP BY Lecture_No
    ''', [user.id, dayOfWeek - 1]);
    // timetableData = timetableData.map((row) => row.toMap()).toList();
    List<Map<String, dynamic>> pastRecord = await db.rawQuery('''
        select subject,Lec_no,Att_Status from attendance_record
        where Id=? and Date=?
        group by Lec_no
        ;''', [user.id, DateFormat('yyyy-MM-dd').format(_selectedDate)]);

    List<Map<String, dynamic>> temp = await db.rawQuery('''
        select * from subject_name
        where Id=?
        ;''', [user.id]);

    temp.forEach((element) => {print(element.toString())});
    print(pastRecord);
    List<Map<String, dynamic>> updatedTimetableData = [];
    if (pastRecord.isEmpty) {
      for (int i = 0; i < timetableData.length; i++) {
        Map<String, dynamic> updatedData = Map.from(timetableData[i]);
        updatedData['attendanceType'] = 'Present';
        updatedTimetableData.add(updatedData);
      }
    } else {
      for (int i = 0; i < timetableData.length; i++) {
        Map<String, dynamic> updatedData = Map.from(timetableData[i]);
        updatedData['attendanceType'] = pastRecord[i]['Att_Status'];
        updatedTimetableData.add(updatedData);
      }
    }

    timetableData = updatedTimetableData;
    // print("timetable data : ${timetableData}");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Entry'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                Text(
                  // DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                  selectedDate,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    print("date picker clicked");
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2022),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        selectedDate =
                            DateFormat('EEEE, dd MMMM yyyy').format(pickedDate);
                      });
                      initializeTimetableData();
                    }
                  },
                  child: Text('Select Date'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: timetableData.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data = timetableData[index];
                String subjectName = data['Subject_Name'];
                int lectureNo = data['Lecture_No'];

                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Lecture $lectureNo: $subjectName'),
                      Text(
                        data['Classroom'] ?? '', // Display the classroom name
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: DropdownButtonFormField<String>(
                    value: data['attendanceType'] ?? attendanceTypes[0],
                    onChanged: (value) {
                      setState(() {
                        // Update the 'attendanceType' property in the Map
                        timetableData[index]['attendanceType'] = value!;
                      });
                    },
                    items: attendanceTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Attendance Type'),
                  ),
                  // trailing: Text(
                  //   data['Classroom'] ?? '', // Display the classroom name
                  //   style: TextStyle(fontSize: 16),
                  // ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final DatabaseHelper _databaseHelper = DatabaseHelper();
          final Database db = await _databaseHelper.database;
          String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
          print(timetableData);
          for (var data in timetableData) {
            int rowId = await db.insert(
              'attendance_record',
              {
                'Id': user.id,
                'Subject': data['Subject_Name'],
                'Date': formattedDate,
                'Lec_no': data['Lecture_No'],
                'Att_Status': data['attendanceType'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );

            // if (rowId > 0) {
            //   // New row inserted
            //   print('Attendance data inserted: Row ID $rowId');
            //   switch (data['attendanceType']) {
            //     case "Present":
            //       await db.rawQuery(
            //           '''UPDATE subject_name set Attendance= Attendance+1 ,classTillDate= classTillDate+1 where id=? and Subject=?;''',
            //           [user.id, data['Subject_Name']]);
            //       break;
            //     case 'Absent':
            //       await db.rawQuery(
            //           '''UPDATE subject_name set classTillDate= classTillDate+1 where id=? and Subject=?;''',
            //           [user.id, data['Subject_Name']]);
            //       break;
            //     default:
            //   }
            // } else {
            //   // Existing row updated
            //   print('Attendance data updated: Row ID ${data['Lecture_No']}');
            // }
          }
          // print("values inserted successfully");
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Updated Sucdessfully")));
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
