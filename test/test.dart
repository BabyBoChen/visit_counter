import 'package:test/test.dart';

import '../bin/models/mongoContext.dart';
import '../bin/models/visitor_log.dart';

void main() {
  test("test db connection", () async {
    print(MongoContext().getUpTime());
    print(await testMongoDb());
    print(await testVisitorCnt());
    print(MongoContext().getUpTime());
    var v = VisitorLog();
    v.query = "111.184.15.49";
    v.countryCode = "TW";
    v.region = "Taipei City";
    print(await MongoContext().addVisitor(v));
    expect(1, equals(1));
  });
}

Future<List<VisitorLog>> testMongoDb() async {
  var db = MongoContext();
  return db.getVisitors();
}

Future<int> testVisitorCnt(){
  var db = MongoContext();
  return db.getVisitorCt();
}


