import 'dart:io';

import 'package:coly/token/token.dart';
import 'package:coly/token/token_type.dart';
import 'package:coly/reporter/reporter.dart';

Reporter report = Reporter();

class Parser {
  List<Token> parse(List<Token> tokens) {
    List<Token> preresult = [];
    int errors = 0;
    Map macros = {};

    for (int i = 0; i < tokens.length; i++) {
      bool _isAtEnd() => i >= tokens.length - 1;

      Token token = tokens[i];
      TokenType type = token.type;
      int line = token.line;
      String file = token.file;
      dynamic value = token.value;

      if (tokens[i].type == TokenType.KEYWORD) {
        if (tokens[i].value == "true") {
          preresult.add(Token(
              tokens[i].file, TokenType.BOOLEAN, tokens[i].line, i, true));
        } else if (tokens[i].value == "false") {
          preresult.add(Token(
              tokens[i].file, TokenType.BOOLEAN, tokens[i].line, i, false));
        } else if (tokens[i].value == "null") {
          preresult.add(
              Token(tokens[i].file, TokenType.NULL, tokens[i].line, i, null));
        } else if (tokens[i].value == "macro") {
          if (_isAtEnd()) {
            report.error(file, line,
                "Macro creation failed. `macro` is not followed by a name.");
            errors++;
            break;
          }
          i++;

          if (tokens[i].type != TokenType.KEYWORD) {
            report.error(file, line,
                "Macro creation failed. `macro` is not followed by a keyword. Expected identifier.");
            errors++;
            break;
          }

          String name = tokens[i].value;

          if (_isAtEnd()) {
            report.error(file, line,
                "Macro creation failed. `macro` is not followed by a value.");
            errors++;
            break;
          }
          i++;
          if (tokens[i].value != Tokens.LEFT_BRACE) {
            report.error(file, line,
                "Macro creation failed. macro name is not followed by a block.");
            errors++;
            break;
          }
          i++;

          int nest = 0;
          List<Token> macroTokens = [];
          while (true) {
            if (_isAtEnd()) {
              report.error(file, line,
                  "Macro creation failed. Block was not terminated.");
              errors++;
              break;
            } else if (tokens[i].value == Tokens.LEFT_BRACE) {
              nest++;
              macroTokens.add(tokens[i]);
            } else if (tokens[i].value == Tokens.RIGHT_BRACE) {
              if (nest == 0) {
                if (macros.containsKey(name)) {
                  report.error(file, line,
                      "Macro creation failed. Macro with name `$name` already exists.");
                  errors++;
                } else {
                  macros[name] = macroTokens;
                }
                break;
              }
              nest--;
              macroTokens.add(tokens[i]);
            } else {
              macroTokens.add(tokens[i]);
            }
            i++;
          }
        } else {
          preresult.add(tokens[i]);
        }
      } else {
        preresult.add(tokens[i]);
      }
    }
    List<Token> result = [];
    for (int i = 0; i < preresult.length; i++) {
      bool _isAtEnd() => i >= preresult.length - 1;

      Token token = preresult[i];
      TokenType type = token.type;
      int line = token.line;
      String file = token.file;
      dynamic value = token.value;

      if (preresult[i].type == TokenType.KEYWORD) {
        if (macros.containsKey(preresult[i].value)) {
          List<Token> macroTokens = macros[preresult[i].value];
          for (int j = 0; j < macroTokens.length; j++) {
            result.add(macroTokens[j]);
          }
        } else {
          result.add(preresult[i]);
        }
      } else {
        result.add(preresult[i]);
      }
    }
    if (errors > 0) exit(1);
    return result;
  }
}
