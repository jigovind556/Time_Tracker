import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:time_trackr/database_helper.dart';
import 'package:time_trackr/global.dart';

class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final PageController _pageController = PageController(initialPage: 0);
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  int _selectedDayIndex = 0; // Track the selected day index
  final ScrollController _scrollController =
      ScrollController(); // ScrollController for navigation bar

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable App'),
      ),
      body: Column(
        children: [
          _buildNavigationBar(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                return TimetableEntryPage(
                  day: index,
                  isSelected:
                      _selectedDayIndex == index, // Pass isSelected flag
                );
              },
              onPageChanged: (index) {
                setState(() {
                  _selectedDayIndex = index;
                  _scrollToSelectedDay(); // Scroll to the selected day
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: 50,
      color: primaryColor,
      child: ListView.builder(
        controller: _scrollController, // Assign the scroll controller
        scrollDirection: Axis.horizontal,
        itemCount: daysOfWeek.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              _pageController.animateToPage(index,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              color: _selectedDayIndex == index
                  ? primaryColor.withOpacity(0.8)
                  : null,
              child: Text(
                daysOfWeek[index],
                style: TextStyle(
                  color:
                      _selectedDayIndex == index ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to scroll to the selected day in the navigation bar
  void _scrollToSelectedDay() {
    double scrollOffset =
        (_selectedDayIndex * 80.0) - (MediaQuery.of(context).size.width / 2);
    _scrollController.animateTo(scrollOffset,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}

// class TimetableEntryPage extends StatefulWidget {
//   @override
//   _TimetableEntryPageState createState() => _TimetableEntryPageState();
// }

// class _TimetableEntryPageState extends State<TimetableEntryPage> {
//   List<Map<String, String>> timetableData = List.generate(
//     10,
//     (index) =>
//         {'subject': '', 'type': 'Lecture'}, // Set a default value for 'type'
//   );

//   List<TextEditingController> subjectControllers = List.generate(
//     10,
//     (index) => TextEditingController(),
//   );

//   @override
//   void dispose() {
//     // Dispose the text editing controllers
//     for (var controller in subjectControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Timetable Entry'),
//       ),
//       body: SingleChildScrollView(
//         child: Material(
//           child: ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: timetableData.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: TextFormField(
//                   controller: subjectControllers[index],
//                   decoration: InputDecoration(labelText: 'Subject Name'),
//                   onChanged: (value) {
//                     print(value);
//                     setState(() {
//                       timetableData[index]['subject'] = value;
//                     });
//                   },
//                 ),
//                 subtitle: DropdownButtonFormField<String>(
//                   value: timetableData[index]['type'],
//                   onChanged: (value) {
//                     setState(() {
//                       timetableData[index]['type'] = value!;
//                     });
//                   },
//                   items: [
//                     DropdownMenuItem(
//                         child: Text('Tutorial'), value: 'Tutorial'),
//                     DropdownMenuItem(child: Text('Lecture'), value: 'Lecture'),
//                     DropdownMenuItem(
//                       child: Text('Practical'),
//                       value: 'Practical',
//                     ),
//                     DropdownMenuItem(
//                       child: Text('No Lecture'),
//                       value: 'Nan',
//                     ),
//                   ],
//                   decoration: InputDecoration(labelText: 'Lecture Type'),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Save the timetableData or use it as needed
//           // For example, you can print it to see the entered data
//           print(timetableData);
//         },
//         child: Icon(Icons.save),
//       ),
//     );
//   }
// }

class TimetableEntryPage extends StatefulWidget {
  final int day;
  final bool isSelected;

  const TimetableEntryPage({required this.day, required this.isSelected});

  @override
  _TimetableEntryPageState createState() => _TimetableEntryPageState();
}

class _TimetableEntryPageState extends State<TimetableEntryPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
  }

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  List<Map<String, String>> timetableData = List.generate(
    10,
    (index) => {'subject': '', 'type': 'L'},
  );

  List<TextEditingController> subjectControllers = List.generate(
    10,
    (index) => TextEditingController(),
  );

  setData() async {
    final DatabaseHelper _databaseHelper = DatabaseHelper();
    final Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> data = await db.rawQuery('''
  SELECT * FROM time_table 
  WHERE id = ? AND Day = ?;
''', [user.id, widget.day]);
    print(data.toString());
    for (var val in data) {
      setState(() {
        subjectControllers[val['Lecture_No'] - 1].text = val['Subject_Name']
            .toString()
            .substring(0, val['Subject_Name'].toString().length - 2);
        timetableData[val['Lecture_No'] - 1]['subject'] = val['Subject_Name']
            .toString()
            .substring(0, val['Subject_Name'].toString().length - 2);
        timetableData[val['Lecture_No'] - 1]['type'] = val['Subject_Name']
            .toString()
            .substring(val['Subject_Name'].toString().length - 1);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in subjectControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isSelected)
              Container(
                color: primaryColor.withOpacity(0.8),
                padding: EdgeInsets.all(16),
                child: Text(
                  daysOfWeek[widget.day],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ...timetableData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return Card(
                child: ListTile(
                  title: TextFormField(
                    controller: subjectControllers[index],
                    decoration: InputDecoration(labelText: 'Subject Name'),
                    onChanged: (value) {
                      setState(() {
                        timetableData[index]['subject'] = value;
                      });
                    },
                  ),
                  subtitle: DropdownButtonFormField<String>(
                    value: data['type'],
                    onChanged: (value) {
                      setState(() {
                        timetableData[index]['type'] = value!;
                      });
                    },
                    items: [
                      DropdownMenuItem(child: Text('Tutorial'), value: 'T'),
                      DropdownMenuItem(child: Text('Lecture'), value: 'L'),
                      DropdownMenuItem(child: Text('Practical'), value: 'P'),
                      DropdownMenuItem(child: Text('No Lecture'), value: 'Nan'),
                    ],
                    decoration: InputDecoration(labelText: 'Lecture Type'),
                  ),
                  leading: Text(
                    'Lecture ${index + 1}', // Display the lecture number
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DatabaseHelper dbHelper = DatabaseHelper();
          print(daysOfWeek[widget.day]);
          print(timetableData);
          int index = 1;
          for (var data in timetableData) {
            if (data['type'] != "Nan" &&
                data['subject'] != null &&
                data['subject']!.trim() != "") {
              await dbHelper.insertTimeTable(user.id,
                  "${data['subject']!}_${data['type']}", widget.day, index);
            }
            index++;
          }
          //show snackbar
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Updated Sucdessfully")));
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
