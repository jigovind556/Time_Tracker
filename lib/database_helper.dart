import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'global.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await initDatabase(); // Initialize if not already initialized
    return _database!;
  }

  Future<Database> initDatabase() async {
    // Get the directory for storing the database
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'attendance.db');

    // Create or open the database at a given path
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create the tables here
    await db.execute('''
      CREATE TABLE users (
        Id TEXT PRIMARY KEY,
        Name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE time_table (
        Id TEXT,
        Subject_Name TEXT,
        Day INTEGER,
        Lecture_No INTEGER,
        Classroom TEXT, 
        PRIMARY KEY (Id, Day, Lecture_No),
        FOREIGN KEY (Id, Subject_Name) REFERENCES subject_name (Id, Subject)
          ON DELETE CASCADE
          ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE subject_name (
        Id TEXT,
        Subject TEXT,
        Attendance INTEGER DEFAULT 0,
        classTillDate INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (Id, Subject),
        FOREIGN KEY (Id) REFERENCES users (Id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance_record (
        Id TEXT,
        Subject TEXT,
        Date TEXT,
        Lec_no INTEGER,
        Att_Status TEXT,
        PRIMARY KEY (Id, Subject, Date, Lec_no),
        FOREIGN KEY (Id, Subject) REFERENCES subject_name (Id, Subject)
          ON DELETE CASCADE
          ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TRIGGER update_class_till_date
      AFTER INSERT ON attendance_record
      BEGIN
        UPDATE subject_name
        SET classTillDate = (
          SELECT COUNT(*) 
          FROM attendance_record 
          WHERE subject_name.Id = attendance_record.Id 
          AND subject_name.Subject = attendance_record.Subject 
          AND (attendance_record.Att_Status = 'Present' OR attendance_record.Att_Status = 'Absent')
        )
        WHERE subject_name.Id = NEW.Id AND subject_name.Subject = NEW.Subject;
      END;
    ''');

    // Trigger to update Attendance
    await db.execute('''
      CREATE TRIGGER update_attendance
      AFTER INSERT ON attendance_record
      BEGIN
        UPDATE subject_name
        SET Attendance = (
          SELECT COUNT(*) 
          FROM attendance_record 
          WHERE subject_name.Id = attendance_record.Id 
          AND subject_name.Subject = attendance_record.Subject 
          AND attendance_record.Att_Status = 'Present'
        )
        WHERE subject_name.Id = NEW.Id AND subject_name.Subject = NEW.Subject;
      END;
    ''');

    //   await db.execute('''
    //   CREATE TRIGGER IF NOT EXISTS insert_subject_trigger
    //   AFTER INSERT ON time_table
    //   BEGIN
    //     INSERT OR IGNORE INTO subject_name (Id, Subject)
    //     VALUES (NEW.Id, NEW.Subject_Name);
    //   END;
    // ''');
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final Database db = await database;
    return await db.rawQuery('SELECT * FROM $table');
  }

  Future<void> insertTimeTable(
      String id, String subject, int day, int lNo, String Classroom) async {
    print("inserting into Time Table");
    Database db = await database;
    List<Map<String, dynamic>> data = await db.rawQuery('''
  SELECT subject FROM subject_name where id=? and subject=?;
''', [user.id, subject]);
    // final Database db = await _databaseHelper.database;
    print(data);
    if (data.isEmpty) {
      print("adding subject");
      await db.insert('subject_name', {
        "Id": user.id,
        "Subject": subject,
      });
    }
    await db.insert(
      'time_table',
      {
        'Id': id,
        'Subject_Name': subject,
        'Day': day,
        'Lecture_No': lNo,
        'Classroom': Classroom,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class User {
  String name = "";
  String id = "";

  User({
    this.name = "",
    this.id = "",
  });

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'];
}
