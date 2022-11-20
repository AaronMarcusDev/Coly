import 'package:coly/token/token_type.dart';

class Token {
  final String file;
  final TokenType type;
  final int line;
  final int pos;
  final dynamic value;

  Token(this.file, this.type, this.line, this.pos, this.value);
}