import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class BackupPage extends StatefulWidget {
  @override
  _BackupPageState createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  Future<void> _backupDatabase(BuildContext context) async {
    if (await Permission.storage.isGranted) {
      final databasesPath = await getDatabasesPath();
      final originalPath = join(databasesPath, 'attendance.db');

      final externalStorageDir = await getExternalStorageDirectory();
      final backupPath = join(externalStorageDir!.path, 'MyAppBackups');

      Directory(backupPath).createSync(recursive: true);

      final backupFilePath = join(backupPath, 'backup.db');

      File(originalPath).copySync(backupFilePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database backed up successfully')),
      );
    } else {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup Database'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Backup your SQLite database to external storage',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _backupDatabase(context),
              child: Text('Backup Database'),
            ),
          ],
        ),
      ),
    );
  }
}

