import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_trackr/global.dart';
import 'package:time_trackr/shared_pref.dart';

import 'attendancePage.dart';
import 'database_helper.dart';
import 'editTimeTable.dart';
import 'home_page.dart';
import 'loginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 169, 229, 100)),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: _checkFirstTimeLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.data == true) {
            return LoginPage();
          } else {
            return HomePage();
          }
        },
      ),
      routes: {
        // '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/timeTableEntry': (context) => TimetablePage(),
        '/attendaceEntry': (context)=>  AttendanceEntryPage(),
      },
      // home: const MyHomePage(title: 'Time Tracker'),
    );
  }
}

Future<bool> _checkFirstTimeLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool temp = !prefs.containsKey('user');
  print("check login $temp");
  if (!temp) {
    SharedPref sharedPref = SharedPref();
    user = User.fromJson(await sharedPref.read('user'));
    print(user);
  }
  return temp;
  // {
  //   print(true);
  //   return true;
  // }
  // SharedPref sharedPref = SharedPref();
  // bool isFirstTime;
  // try{
  //   isFirstTime = await sharedPref.read('isLogin') ?? true;
  // } catch (e) {
  //   print(e);
  // }
  // return isFirstTime;
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final dbHelper = DatabaseHelper.instance;
//   TextEditingController emailController = TextEditingController();
//   TextEditingController ageController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
    
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           children: [
//             TextField(
//               controller: emailController,
//             ),
//             TextField(
//               controller: ageController,
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 print("hello");
//                 // Insert data
//                 Map<String, dynamic> row = {
//                   DatabaseHelper.columnName: emailController.text,
//                   DatabaseHelper.columnAge: ageController.text,
//                 };
//                 int id = await dbHelper.insert(row);
//                 print('Inserted row id: $id');

//                 // Query all data
//                 List<Map<String, dynamic>> allRows = await dbHelper.queryAll();
//                 allRows.forEach((row) {
//                   print(
//                       'Name: ${row[DatabaseHelper.columnName]}, Age: ${row[DatabaseHelper.columnAge]}');
//                 });
//               },
//               child: Text('Insert into Database'),
//             ),
//             ElevatedButton(
//                 onPressed: () async {
//                   // List<Map<String, dynamic>> allRows = await dbHelper.queryAll();
//                   print(await dbHelper.queryAll());
//                   // allRows.forEach((row) {
//                   //   print(
//                   //       'Name: ${row[DatabaseHelper.columnName]}, Age: ${row[DatabaseHelper.columnAge]}');
//                   // });
//                 },
//                 child: Text("Execute query"))
//           ],
//         ),
//       ),
//     );
//   }
// }
