library visit_counter.secrets;

import 'dart:io';

class Secret {
  //static const String MONGODB_CONNSTRING = "mongodb+srv://sa:75whVEi8ei1XvLNj@bblj.76jhfiu.mongodb.net/visitor_count?retryWrites=true&w=majority";
  static String get MONGODB_CONNSTRING {
    return Platform.environment["MONGODB_CONNSTRING"]!;
  }
}