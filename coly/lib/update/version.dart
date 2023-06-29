import 'dart:io';

String version() {
  String v;
  if (Platform.isWindows) {
    v = File(
            "${Platform.resolvedExecutable.replaceAll("coly.exe", '')}/stdlib/.version")
        .readAsStringSync();
  } else {
    v = File(
            "${Platform.resolvedExecutable.replaceAll('coly', '')}/stdlib/.version")
        .readAsStringSync();
  }
  return v;
}
