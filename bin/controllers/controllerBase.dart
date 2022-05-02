library visit_counter.controller;

import 'dart:async';

import 'package:shelf/shelf.dart';

abstract class Controller {
  FutureOr<Response> render();
}