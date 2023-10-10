library visit_counter.models;

import 'package:mongo_dart/mongo_dart.dart';

import '../secrets/secret.dart';
import 'iDbContext.dart';
import 'visitor_log.dart';

class MongoContext implements IDbContext{
  static final DateTime since = DateTime.now();

  Future<Db> getDb() async {   
    var db = await Db.create(Secret.MONGODB_CONNSTRING);
    await db.open();
    return db;
  }    

  @override
  Future<bool> addVisitor(VisitorLog visitor) async {
    var db = await getDb();
    var qry = where.ne("_id", null).sortBy("logId", descending: true);
    int maxLogId =  await db.collection("visitor_log").findOne(qry).then((doc){
      if(doc != null){
        return doc["logId"];
      } else {
        return 0;
      }
    });
    var res = await db.collection("visitor_log").insertOne({
      "_id": ObjectId(),
      "logId":maxLogId + 1,
      "countryCode":visitor.countryCode,
      "region":visitor.region,
      "query":visitor.query,
      "timestamp":DateTime.now().toString().substring(0,19),
      "_ts": Timestamp(),
    });
    await db.close();
    return res.isSuccess;
  }

  @override
  String getUpTime() {
    return since.toString().substring(0, 10);
  }

  @override
  Future<int> getVisitorCt() async {
    var db = await getDb();
    int cnt = await db.collection("visitor_log").count();
    await db.close();
    return cnt;
  }

  @override
  Future<List<VisitorLog>> getVisitors() async{
    List<VisitorLog> logs = [];
    var db = await getDb();
    var qry = where.ne("_id", null).sortBy("timestamp", descending: true).limit(30);
    await db.collection("visitor_log").find(qry).forEach((row) {
      var log = VisitorLog();
      log.logId = row["logId"] as int;
      log.countryCode = row["countryCode"].toString();
      log.region = row["region"].toString();
      log.query = row["query"].toString();
      log.timestamp = row["timestamp"].toString();
      logs.add(log);
    });
    await db.close();
    return logs;
  }

}