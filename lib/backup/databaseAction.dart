import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share/share.dart'; // Import the share package

import '../database_helper.dart';
import '../global.dart';

class DatabaseAction {
  static Future<void> shareDatabase(BuildContext context) async {
    try {
      // Get the path to the app's documents directory
      await exportDatabase(context);
      Directory documentsDir = await getApplicationDocumentsDirectory();
      String documentsPath = documentsDir.path;

      // Get the backup file
      File backupFile = File('$documentsPath/time_table_backup.sql');

      // Check if the backup file exists
      if (await backupFile.exists()) {
        // Share the backup file using the share package
        await Share.shareFiles([backupFile.path],
            subject: 'Time Table Backup',
            text: 'Here is the backup file for your time table.');
      } else {
        print('Backup file does not exist.');
      }
    } catch (e) {
      print('Error sharing backup file: $e');
    }
  }

  static Future<void> exportDatabase(BuildContext context) async {
    try {
      // Get the path to the app's documents directory
      Directory documentsDir = await getApplicationDocumentsDirectory();
      String documentsPath = documentsDir.path;

      // Create a backup file
      File backupFile = File('$documentsPath/time_table_backup.sql');

      // Open the backup file for writing
      IOSink sink = backupFile.openWrite();

      // Retrieve the time table data for the current user
      final DatabaseHelper _databaseHelper = DatabaseHelper();
      final Database db = await _databaseHelper.database;
      List<Map<String, dynamic>> timeTableData = await db.rawQuery('''
        SELECT * FROM time_table;
      ''');

      // Generate the backup content for the time table data
      for (var row in timeTableData) {
        String insertStatement = '''
          INSERT INTO time_table (Id, Subject_Name, Day, Lecture_No, Classroom) VALUES ( #newUserId, '${row['Subject_Name']}',  ${row['Day']},  ${row['Lecture_No']}, '${row['Classroom']}');
        ''';

        sink.writeln(insertStatement);
        print(insertStatement);
      }

      // Close the backup file
      await sink.flush();
      await sink.close();

      // Show a snackbar or dialog to inform the user about the export status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Time table exported successfully!'),
        ),
      );
    } catch (e) {
      print('Error exporting time table: $e');
    }
  }

  static String extractSubjectNameFromQuery(String modifiedQuery) {
    // Split the query by comma and remove whitespace
    List<String> values =
        modifiedQuery.split(',').map((value) => value.trim()).toList();
    return values[5].replaceAll("'", "").trim();
  }

  static Future<void> importDatabase(
      BuildContext context, String newUserId) async {
    try {
      // Open a file picker to select the backup file
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first;

        // Read the selected backup file content
        String backupContent = await File(file.path!).readAsString();

        // Get the path to the app's documents directory
        Directory documentsDir = await getApplicationDocumentsDirectory();
        String documentsPath = documentsDir.path;

        // Create a new backup file with the imported content
        File importedBackupFile =
            File('$documentsPath/time_table_imported.sql');
        await importedBackupFile.writeAsString(backupContent);

        // Open the imported backup file for reading
        List<String> lines = await importedBackupFile.readAsLines();

        // Retrieve the existing database instance
        final DatabaseHelper _databaseHelper = DatabaseHelper();
        final Database db = await _databaseHelper.database;

        // Clear the existing time_table table for the new user
        await db.delete('time_table', where: 'Id = ?', whereArgs: [newUserId]);

        // Import the backup data into the time_table table
        for (String line in lines) {
          if (line.trim().isNotEmpty) {
            // Replace the Id value with the newUserId
            String modifiedLine =
                line.replaceFirst('#newUserId', "\'$newUserId\'");

            String extractedSubject = extractSubjectNameFromQuery(modifiedLine);
            if (extractedSubject != "") {
              print("Extracted Subject: $extractedSubject");

              List<Map<String, dynamic>> data = await db.rawQuery('''
  SELECT subject FROM subject_name where id=? and subject=?;
''', [user.id, extractedSubject]);
              // final Database db = await _databaseHelper.database;
              print(data);
              if (data.isEmpty) {
                print("adding subject");
                await db.insert('subject_name', {
                  "Id": user.id,
                  "Subject": extractedSubject,
                });
              }
            } else {
              print("not found");
            }
            print(modifiedLine);
            await db.execute(modifiedLine);
          }
        }

        // Show a snackbar or dialog to inform the user about the import status
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Time table imported successfully!'),
          ),
        );
      }
    } catch (e) {
      print('Error importing time table: $e');
    }
  }
}
