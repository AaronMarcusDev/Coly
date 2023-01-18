// ignore_for_file: no_leading_underscores_for_local_identifiers

//Dart
import 'dart:io';
// Custom
import 'package:coly/token/token.dart';
import 'package:coly/token/token_type.dart';
import 'package:coly/reporter/reporter.dart';
import 'package:coly/lexer/lexer.dart';

Reporter report = Reporter();
Lexer lexer = Lexer();

class Parser {
  List<Token> parse(String mode, List<Token> tokens, String stdLibPath) {
    List<Token> preresult = [];
    int errors = 0;
    Map macros = {};

    for (int i = 0; i < tokens.length; i++) {
      bool _isAtEnd() => i >= tokens.length - 1;

      if (tokens[i].type == TokenType.KEYWORD && tokens[i].value == "include") {
        if (_isAtEnd()) {
          report.error(tokens[i].file, tokens[i].line,
              "Expected a string after `include`.");
          errors++;
          break;
        }
        i++;
        if (tokens[i].type != TokenType.STRING) {
          report.error(tokens[i].file, tokens[i].line,
              "Expected a string after `include`.");
          errors++;
          break;
        }
        String fileName = tokens[i].value.trim();
        if (!File(fileName).existsSync()) {
          report.error(tokens[i].file, tokens[i].line,
              "File `$fileName` does not exist.");
          errors++;
          break;
        }
        List<Token> lexedTokens =
            lexer.lex(mode, fileName, File(fileName).readAsStringSync());
        for (Token token in lexedTokens.sublist(0, lexedTokens.length - 1)) {
          preresult.add(token);
        }
      } else if (tokens[i].type == TokenType.KEYWORD && tokens[i].value == "use") {
        if (_isAtEnd()) {
          report.error(tokens[i].file, tokens[i].line,
              "Expected a string after `use`.");
          errors++;
          break;
        }
        i++;
        if (tokens[i].type != TokenType.STRING) {
          report.error(tokens[i].file, tokens[i].line,
              "Expected a string after `use`.");
          errors++;
          break;
        }
        String fileName = tokens[i].value.trim();
        if (!File("$stdLibPath\\$fileName.coly").existsSync()) {
          report.error(tokens[i].file, tokens[i].line,
              "File `$fileName` does not exist in the standard library.");
          errors++;
          break;
        }
        List<Token> lexedTokens =
            lexer.lex(mode, "$fileName.coly", File("$stdLibPath\\$fileName.coly").readAsStringSync());
        for (Token token in lexedTokens.sublist(0, lexedTokens.length - 1)) {
          preresult.add(token);
        }
      } else {
        preresult.add(tokens[i]);
      }
    }
    tokens = preresult;
    preresult = [];

    for (int i = 0; i < tokens.length; i++) {
      bool _isAtEnd() => i >= tokens.length - 1;
      int line = tokens[i].line;
      String file = tokens[i].file;

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

    for (var key in macros.keys) {
      List<Token> result = [];
      var macro = macros[key];
      for (var item in macro) {
        if (item.type == TokenType.KEYWORD) {
          if (macros.containsKey(item.value)) {
            result.addAll(macros[item.value]);
          } else {
            result.add(item);
          }
        } else {
          result.add(item);
        }
      }
      macros[key] = result;
    }

    List<Token> result = [];
    for (int i = 0; i < preresult.length; i++) {
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
    // for (var key in macros.keys) {
    //   print(key);
    //   print(macros[key]);
    // }
    if (errors > 0) exit(1);
    return result;
  }
}
