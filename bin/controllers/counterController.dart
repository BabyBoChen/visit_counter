library visit_counter.controllers;

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../models/dbContext.dart';
import 'controllerBase.dart';

class CounterController implements Controller{
  final Request request;

  CounterController(this.request);

  FutureOr<Response> index(){
    var db = DbContext();
    int vc = db.getVisitorCt();
    var json = {'visitorCt':vc};
    var jsonStr = jsonEncode(json);
    var resp = Response.ok(jsonStr, headers: {'content-type':'application/json'});
    return resp;
  }

  @override
  FutureOr<Response> render(){
    FutureOr<Response> resp = Response.badRequest();
    if(request.method == 'GET'){
      resp = index();
    }
    return resp;
  }
}