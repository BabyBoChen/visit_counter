library visit_counter.secrets;

import 'dart:io';

class Secret {
  static String get MONGODB_CONNSTRING {
    return Platform.environment["MONGODB_CONNSTRING"]!;
  }
}
