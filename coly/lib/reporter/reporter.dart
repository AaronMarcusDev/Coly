import 'package:coly/shared/source/source.dart' as shared_source;

class Reporter {
  void error(String file, int line, String message) {
    print("\x1B[31m[ERROR] $message\x1B[0m");
    // print("\x1B[33m[TRACE]\x1B[0m $file:$line");
    print("[TRACE]\x1B[0m $file:$line");
    print("\x1B[33m   -->\x1B[0m  \x1B[1m\x1B[33m$line\x1B[0m \x1B[33m|\x1B[0m \x1b[0m${shared_source.source.split("\n")[line-1]}\n");
  }

  void warning(String file, int line, String message) {
    print("\x1B[33m[ERROR] $file:$line, $message\x1B[0m");
  }
}