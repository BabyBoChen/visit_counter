library visit_counter;

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

import 'controllers/controllerBase.dart';
import 'controllers/counterController.dart';
import 'controllers/homeController.dart';

import 'package:path/path.dart' as p;

void main() async {
  var app = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(_myHandler);

  var server = await shelf_io.serve(app, '0.0.0.0', 8080);

  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Middleware _cors() {
  var filter = createMiddleware(
      requestHandler: null,
      responseHandler: (response) {
        var myHeader = {
          'Access-Control-Allow-Origin': 'https://babybochen.github.io',
          'Access-Control-Allow-Methods': '*'
        };
        response = response.change(headers: myHeader);
        return response;
      });
  return filter;
}

FutureOr<Response> _myHandler(Request request) {
  var routes = request.url.pathSegments;
  FutureOr<Response> resp = Response.notFound('404');
  if (routes.isEmpty || routes.first == 'home') {
    Controller homeController = HomeController(request);
    resp = homeController.render();
  } else if (routes.first == 'favicon.ico') {
    var faviconHandler =
        createStaticHandler('bin/views', defaultDocument: 'favicon.ico');
    resp = faviconHandler(request);
  } else if (routes.first == 'counter') {
    Controller counterController = CounterController(request);
    resp = counterController.render();
  } else if(routes.first == 'visit_counter.db'){
    var dbDownload =
    createStaticHandler('bin', defaultDocument: 'visit_counter.db');
    resp = dbDownload(request);
  }
  return resp;
}
