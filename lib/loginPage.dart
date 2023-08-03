import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:time_trackr/global.dart';
import 'package:time_trackr/shared_pref.dart';
import 'home_page.dart';
import 'database_helper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    getUsersFromSharedPreferences();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> users = [];

  Future<void> getUsersFromSharedPreferences() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    var userList = await dbHelper.queryAll("users");
    // List<String> userList = prefs.getStringList('user_list') ?? [];
    setState(() {
      users = userList;
    });
    print(users.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        print("object");
                        SharedPref sharedPref = SharedPref();
                        await sharedPref.save("user", {
                          "id": users[index]['Id'],
                          "name": users[index]['Name'],
                        });
                        user.id = users[index]['Id'];
                        user.name = users[index]['Name'];
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 2)),
                        child: ListTile(
                          tileColor: Theme.of(context).colorScheme.background,
                          title: Text(users[index]['Name']),
                          subtitle: Text("${users[index]['Id']}"),
                        ),
                      ),
                    );
                  },
                ),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  // Save user's name and email to database
                  String name = _nameController.text;
                  String email = _emailController.text;
                  if (name != "" && email != "") {
                    user.id = email;
                    user.name = name;
                    await _saveUserData(name, email);
                    // Redirect to home page
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String cleanAndCapitalize(String input) {
    String cleaned = input.replaceAll(RegExp(r'\s+'), ' ');
    String trimmed = cleaned.trim();
    return trimmed.split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1)}';
      } else {
        return '';
      }
    }).join(' ');
  }

  Future<void> _saveUserData(String name, String email) async {
    final Database db = await _databaseHelper.database;
    SharedPref sharedPref = SharedPref();
    name = cleanAndCapitalize(name);
    print(name);
    await db.insert(
      'users',
      {
        'Id': email.trim(),
        'Name': name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await sharedPref.save("user", {
      "id": email.trim(),
      "name": name,
    });
  }
}
