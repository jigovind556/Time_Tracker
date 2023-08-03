import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
              ElevatedButton(
  onPressed: () async {
    await _importDatabase(context); // Call the import database function
    await getUsersFromSharedPreferences(); // Refresh the user list
  },
  child: Text('Import Database'),
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

  Future<void> _importDatabase(BuildContext context) async {
  // Open a file picker to select the backup file
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    // Get the selected backup file
    PlatformFile file = result.files.first;

    try {
      // Copy the backup file to the app's data directory
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String backupPath = '${appDirectory.path}/backup.db';
      await File(file.path!).copy(backupPath);

      // Open the copied backup database
      final Database backupDb = await openDatabase(backupPath);

      // Get a list of all table names in the backup database
      final List<String> tableNames = await backupDb
          .query('sqlite_master', where: 'type = ?', whereArgs: ['table'])
          .then((tables) => tables.map((table) => table['name'] as String)
          .toList());

      // Open the existing database
      final Database existingDb = await _databaseHelper.database;

      // Import data from each table in the backup database
      for (final tableName in tableNames) {
        // Fetch data from the corresponding table in the backup database
        final List<Map<String, dynamic>> backupData =
            await backupDb.query(tableName);

        // Clear the corresponding table in the existing database
        await existingDb.delete(tableName);

        // Import the backup data into the corresponding table in the existing database
        for (final Map<String, dynamic> row in backupData) {
          await existingDb.insert(tableName, row);
        }
      }

      // Close the backup database
      await backupDb.close();

      // Show a snackbar or dialog to inform the user about the import status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database imported successfully!'),
        ),
      );
    } catch (e) {
      print('Error importing database: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while importing the database.'),
        ),
      );
    }
  }
}

}
