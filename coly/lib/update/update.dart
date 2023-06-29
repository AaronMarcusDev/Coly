import 'version.dart';

import 'package:http/http.dart' as http;

const String uri =
    "https://raw.githubusercontent.com/AaronMarcusDev/Coly/main/coly/lib/update/version.dart";

Future<(bool, String)> hasUpdate() async {
  String data = await http.read(Uri.parse(uri));
  String latest = data.substring(24, 29);
  return (!(version == latest), latest);
}
