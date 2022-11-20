class Reporter {
  void error(String file, int line, String message) {
    print("\x1B[31m[ERROR] $file:$line $message\x1B[0m");
  }

  void warning(String file, int line, String message) {
    print("\x1B[33m[ERROR] $file:$line, $message\x1B[0m");
  }
}