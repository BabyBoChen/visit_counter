library visit_counter.models;

import 'visitor_log.dart';

abstract class IDbContext {
  Future<bool> addVisitor(VisitorLog visitor);
  Future<List<VisitorLog>> getVisitors();
  Future<int> getVisitorCt();
  String getUpTime();
}