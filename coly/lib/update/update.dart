// Dart
import 'dart:io';
import 'package:http/http.dart' as http;
// Custom
import 'version.dart';

Future<(bool, String)?> hasUpdate() async {
  try {
    String latest = await http.read(Uri.parse(
        "https://raw.githubusercontent.com/AaronMarcusDev/Coly/main/stdlib/.version"));
    return (!(version() == latest), latest);
  } catch (e) {
    return null;
  }
}

Future<void> update() async {
  print("[INFOR] Updating the standard library...");
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
    String latest = await http.read(Uri.parse("$root/.version"));

    for (String file in stdlist.split("\n")) {
      if (file == "") continue;
      String data = await http.read(Uri.parse("$root/$file.coly"));
      await File("$scriptFolderPath/stdlib/$file.coly").writeAsString(data);
    }

    await File("$scriptFolderPath/stdlib/.version").writeAsString(latest);
  } catch (e) {
    print("\x1B[31m[ERROR] Could not update standard library.\x1B[0m");
    print("[INFOR] Please check your internet connection.");
  }
  print("[INFOR] Succesfully updated the standard library.");
}
