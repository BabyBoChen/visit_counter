library visit_counter;

import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

import 'controllers/controllerBase.dart';
import 'controllers/counterController.dart';
import 'controllers/homeController.dart';

import 'models/dbContext.dart';

void main() async {
  String since = _setUpTime();

  var app = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler((req) => _requestDispatcher(req));

  var server = await shelf_io.serve(app, '0.0.0.0', 8080);

  server.autoCompress = true;
  print('Version: 1.2.0');
  print('Since: $since');
  print('Serving at http://${server.address.host}:${server.port}');
}

String _setUpTime() {
  String since = '';
  var db = DbContext();
  since = db.getUpTime();
  return since;
}

Middleware _cors() {
  var filter = createMiddleware(
      requestHandler: null,
      responseHandler: (response) {
        var myHeader = {
          'Access-Control-Allow-Origin': 'https://babybochen.github.io',
          //'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': '*'
        };
        response = response.change(headers: myHeader);
        return response;
      });
  return filter;
}

FutureOr<Response> _requestDispatcher(Request request) {
  FutureOr<Response> resp = Response.notFound('404');

  var routes = request.url.pathSegments;
  List<String> staticDirs = ["lib", "css", "js", "assets"];

  if (routes.isEmpty || routes.first == 'home') {
    Controller homeController = HomeController(request);
    resp = homeController.render();
  } else if (routes.first == 'favicon.ico') {
    var faviconHandler =
        createStaticHandler('bin/views', defaultDocument: 'favicon.ico');
    resp = faviconHandler(request);
  } else if (staticDirs.contains(routes.first)) {
    var staticFileHandler = createStaticHandler('bin/views');
    resp = staticFileHandler(request);
  } else if (routes.first == 'counter') {
    Controller counterController = CounterController(request);
    resp = counterController.render();
  } else if (routes.first == 'visit_counter.db') {
    var dbDownload = createFileHandler('bin/visit_counter.db',
        contentType: "application/octet-stream");
    resp = dbDownload(request);
  }
  return resp;
}
