import 'package:coly/token/token.dart';
import 'package:coly/token/token_type.dart';

class Parser {
  List<Token> parse(List<Token> tokens) {
    List<Token> result = [];

    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i].type == TokenType.KEYWORD) {
        if (tokens[i].value == "true") {
          result.add(Token(
              tokens[i].file, TokenType.BOOLEAN, tokens[i].line, i, true));
        } else if (tokens[i].value == "false") {
          result.add(Token(
              tokens[i].file, TokenType.BOOLEAN, tokens[i].line, i, false));
        } else {
          result.add(tokens[i]);
        }
      } else {
        result.add(tokens[i]);
      }
    }
    return result;
  }
}
