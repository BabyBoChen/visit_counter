library visit_counter.models;

import 'dart:ffi';

import 'package:path/path.dart' as p;

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import 'visitor_log.dart';

class DbContext {
  String dbpath = p.current + '/bin/visit_counter.db';

  DbContext() {
    open.overrideFor(OperatingSystem.linux, _openOnLinux);
  }

  Future<bool> addVisitor(VisitorLog visitor) {
    bool isSuccess = false;
    var db = sqlite3.open(dbpath);
    final stmt =
        db.prepare('INSERT INTO VisitorLog (CountryCode, Region, Query)'
            ' VALUES (?, ?, ?)');
    try {
      stmt.execute([visitor.countryCode, visitor.region, visitor.query]);
      stmt.dispose();
      db.dispose();
      isSuccess = true;
    } catch (ex) {
      print(ex);
      stmt.dispose();
      db.dispose();
      isSuccess = false;
    }
    return Future.value(isSuccess);
  }

  Future<List<VisitorLog>> getVisitors() {
    List<VisitorLog> logs = [];
    Database? db;
    try {
      db = sqlite3.open(dbpath);
    } catch (ex) {
      print(ex);
    }
    if (db != null) {
      try {
        var resultSet = db.select('SELECT * FROM VisitorLog '
            'order by Timestamp desc LIMIT 30');
        for (Row row in resultSet) {
          var log = VisitorLog();
          log.logId = int.parse(row['LogId'].toString());
          log.countryCode = row['CountryCode'].toString();
          log.region = row['Region'].toString();
          log.query = row['Query'].toString();
          log.timestamp = row['Timestamp'].toString();
          logs.add(log);
        }
      } catch (ex) {
        print(ex);
      } finally {
        db.dispose();
      }
    }
    return Future.value(logs);
  }

  Future<int> getVisitorCt() {
    int visitorCt = 0;
    //select count(*) as VisitorCt from VisitorLog
    Database? db;
    try {
      db = sqlite3.open(dbpath);
    } catch (ex) {
      print(ex);
    }
    if (db != null) {
      try {
        var resultSet =
            db.select('select count(*) as VisitorCt from VisitorLog');
        for (Row row in resultSet) {
          visitorCt = int.parse(row["VisitorCt"].toString());
          break;
        }
      } catch (ex) {
        print(ex);
      } finally {
        db.dispose();
      }
    }
    return Future.value(visitorCt);
  }

  String getUpTime() {
    String since = '';
    Database? db;
    try {
      db = sqlite3.open(dbpath);
    } catch (ex) {
      print(ex);
    }
    if (db != null) {
      try {
        var resultSet = db.select("select * from UpTime");
        if (resultSet.isEmpty) {
          db.execute("insert into UpTime DEFAULT VALUES");
          resultSet = db.select("select * from UpTime");
        }
        since = resultSet.first["Since"].toString();
      } catch (ex) {
        print(ex);
      } finally {
        db.dispose();
      }
    }
    return since;
  }

  DynamicLibrary _openOnLinux() {
    String soPath = p.current + '/bin/libsqlite3.so.0.8.6';
    return DynamicLibrary.open(soPath);
  }
}
