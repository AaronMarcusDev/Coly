// Dart
import 'dart:io';
// Custom
import 'package:coly/reporter/reporter.dart';

Reporter reporter = Reporter();

String loadFile(String f) {
  if (!File(f).existsSync()) {
    print(
        "\x1B[31m[ERROR] File `$f` does not exist in the current working directory.\x1B[0m");
    exit(1);
  }
  String content = File(f).readAsStringSync();
  if (content.trim().isEmpty) {
    print(
        "\x1B[31m[ERROR] File `$f` is empty.\x1B[0m");
    exit(1);
  }
  return '$content ';
}
