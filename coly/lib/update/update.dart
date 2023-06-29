import 'package:http/http.dart' as http;

const String uri =
    "https://raw.githubusercontent.com/AaronMarcusDev/Coly/main/coly/lib/update/version";

Future<bool> hasUpdate() async {
  String data = await http.read(Uri.parse(uri));
  print(data);

  return false;
}
