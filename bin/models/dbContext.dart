library visit_counter.models;

import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import 'visitor_log.dart';

class DbContext{

  String dbpath = p.current + '/bin/visit_counter.db';

  DbContext(){
    open.overrideFor(OperatingSystem.linux, _openOnLinux);
  }

  bool addVisitor(VisitorLog visitor){

    bool isSuccess = false;
    var db = sqlite3.open(dbpath);
    final stmt = db.prepare('INSERT INTO VisitorLog (CountryCode, Region, Query)'
        ' VALUES (?, ?, ?)');
    try{
      stmt.execute([visitor.countryCode, visitor.region, visitor.query]);
      stmt.dispose();
      db.dispose();
      isSuccess = true;
    } catch (ex){
      print(ex);
      stmt.dispose();
      db.dispose();
      isSuccess = false;
    }
    return isSuccess;
  }

  List<VisitorLog> getVisitors(){
    List<VisitorLog> logs = [];
    Database? db;
    try{
      db = sqlite3.open(dbpath);
    }catch(ex){
      print(ex);
    }
    if(db != null){
      try{
        var resultSet = db.select('SELECT * FROM VisitorLog');
        for (Row row in resultSet) {
          var log = VisitorLog();
          log.logId = int.parse(row['LogId'].toString());
          log.countryCode = row['CountryCode'].toString();
          log.region = row['Region'].toString();
          log.query = row['Query'].toString();
          log.timestamp = row['Timestamp'].toString();
          logs.add(log);
        }
      }catch(ex){
        print(ex);
      }finally{
        db.dispose();
      }
    }
    return logs;
  }

  int getVisitorCt(){
    int visitorCt = 0;
    //select count(*) as VisitorCt from VisitorLog
    Database? db;
    try{
      db = sqlite3.open(dbpath);
    }catch (ex){
      print(ex);
    }
    if(db != null){
      try{
        var resultSet = db.select('select count(*) as VisitorCt from VisitorLog');
        for(Row row in resultSet){
          visitorCt = int.parse(row["VisitorCt"].toString());
          break;
        }
      }catch(ex){
        print(ex);
      } finally{
        db.dispose();
      }
    }
    return visitorCt;
  }

  DynamicLibrary _openOnLinux() {
    final scriptDir = File(Platform.script.toFilePath()).parent;
    final libraryNextToScript = File('${scriptDir.path}/libsqlite3.so.0.8.6');
    return DynamicLibrary.open(libraryNextToScript.path);
  }

}