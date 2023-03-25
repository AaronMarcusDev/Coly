import 'package:coly/shared/source/source.dart' as shared_source;

class Reporter {
  void error(String file, int line, String message) {
    print("\x1B[31m[ERROR] $file:$line $message\x1B[0m");
    // print(shared_source.source.split("\n")[line-1]);
  }

  void warning(String file, int line, String message) {
    print("\x1B[33m[ERROR] $file:$line, $message\x1B[0m");
  }
}