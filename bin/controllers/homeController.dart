library visit_counter.controllers;

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

import '../models/dbContext.dart';
import '../models/iDbContext.dart';
import '../models/mongoContext.dart';
import '../models/visitor_log.dart';
import 'controllerBase.dart';

class HomeController implements Controller {
  final Request request;
  late IDbContext _db;

  HomeController(this.request){
    _db = MongoContext();
  }

  FutureOr<Response> index() {
    var fileResponse =
        createStaticHandler('bin/views', defaultDocument: 'index.html');
    return fileResponse(request);
  }

  FutureOr<Response> addVisitor() async {
    FutureOr<Response> resp = Response.badRequest();
    var data = await request.readAsString();
    var userIp = jsonDecode(data);
    VisitorLog visitor = VisitorLog();
    visitor.countryCode = userIp["countryCode"].toString();
    visitor.region = userIp["region"].toString();
    visitor.query = userIp["query"].toString();
    var isSuccess = await _db.addVisitor(visitor);
    if (isSuccess) {
      resp = Response.ok('1|OK');
    } else {
      resp = Response.ok('0|Fail');
    }
    return resp;
  }

  FutureOr<Response> getVisitors() async {
    FutureOr<Response> resp = Response.badRequest();
    String since = _db.getUpTime();
    List<VisitorLog> logs = await _db.getVisitors();
    List<Map<String, dynamic>> logsMap = [];
    for (VisitorLog log in logs) {
      var dict = {
        'logId': log.logId,
        'countryCode': log.countryCode,
        'region': log.region,
        'query': log.query,
        'timestamp': log.timestamp,
      };
      logsMap.add(dict);
    }
    int total = await _db.getVisitorCt();
    Map<String, dynamic> visitorLog = {
      "since": since,
      "visitors": logsMap,
      "visitorCount": total,
    };
    String jsonStr = jsonEncode(visitorLog);
    resp = Response.ok(jsonStr, headers: {'content-type': 'application/json'});
    return resp;
  }

  @override
  FutureOr<Response> render() async {
    var routes = request.url.pathSegments;
    FutureOr<Response> resp = Response.badRequest();
    if (request.method == 'GET') {
      if (routes.isEmpty) {
        resp = index();
      } else if (request.url.path == 'home/getVisitors') {
        resp = getVisitors();
      }
    } else if (request.method == 'POST') {
      resp = await addVisitor();
    }
    return resp;
  }
}
