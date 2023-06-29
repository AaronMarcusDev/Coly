// Dart
import 'dart:io';
import 'package:http/http.dart' as http;
// Custom
import 'version.dart';

const String uri =
    "https://raw.githubusercontent.com/AaronMarcusDev/Coly/main/coly/lib/update/version.dart";

Future<(bool, String)> hasUpdate() async {
  String data = await http.read(Uri.parse(uri));
  String latest = data.substring(24, 29);
  return (!(version == latest), latest);
}

Future<void> update() async {
  String scriptFolderPath;
  if (Platform.isWindows) {
    scriptFolderPath = Platform.resolvedExecutable.replaceAll("coly.exe", '');
  } else {
    scriptFolderPath = Platform.resolvedExecutable.replaceAll("coly", '');
  }

  try {
    const String root =
        "https://raw.githubusercontent.com/AaronMarcusDev/Coly/main/stdlib/";
    String stdlist = await http.read(Uri.parse("$root/.stdlist"));

    for (String file in stdlist.split("\n")) {
      if (file == "") continue;
      String data = await http.read(Uri.parse("$root/$file.coly"));
      await File("$scriptFolderPath/stdlib/$file.coly").writeAsString(data);
    }
  } catch (e) {
    print("\x1B[31m[ERROR] Could not update standard library.\x1B[0m");
    print("[INFOR] Please check your internet connection.");
  }
}
