import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    var json2;
    // var json3;
    try {
      json2 = json.decode(prefs.getString(key)!);
      // json3 =await  prefs.getString(key)!;
      // print("json3 : ${json3}");
    } catch (e) {
      print("error in shared pref : ${e}");
    }
    return json2;
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    // print(json.encode(value));
    prefs.setString(key, json.encode(value));
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
