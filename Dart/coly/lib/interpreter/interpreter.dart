// Dart
import 'dart:io';
// Custom
import 'package:coly/token/token.dart';
import 'package:coly/token/token_type.dart';
import 'package:coly/reporter/reporter.dart';

Reporter report = Reporter();

class Interpreter {
  void interpret(List<Token> tokens) {
    // Initialize stack
    List<Token> stack = [];
    // Stack Operations
    void _push(token) => stack.add(token);
    Token _pop() => stack.removeLast();

    // Iterate over tokens (interpret)
    for (int i = 0; i < tokens.length; i++) {
      void _errorExit() {
        print("\x1B[34m[INFOR] Error(s) found. Interpreting failed.\x1B[0m");
        exit(1);
      }

      Token token = tokens[i];
      TokenType type = token.type;
      int line = token.line;
      String file = token.file;
      dynamic value = token.value;

      // print("Type: $type, Value: $value");

      bool _isAtEnd() => i >= tokens.length - 1;

      void ifIsEmptyThrowError(String command) {
        if (stack.isEmpty) {
          report.error(
              file, line, "Command `$command` failed. Stack is empty.");
          _errorExit();
        }
      }

      void ifTooLittleItemsThrowError(int amountOfItems, String command) {
        if (stack.length != amountOfItems) {
          report.error(file, line,
              "Command `$command` failed. Stack too little items on stack.");
          _errorExit();
        }
      }

      if (type == TokenType.OPERATOR) {
        if (value == Tokens.PLUS) {
          ifTooLittleItemsThrowError(2, "+");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.INTEGER || b.type != TokenType.INTEGER) {
            report.error(file, line,
                "Command `+` failed. Both items on stack must be integers.");
            _errorExit();
          }
          _push(Token(file, TokenType.INTEGER, line, i, a.value + b.value));
        } else if (value == Tokens.MINUS) {
          ifTooLittleItemsThrowError(2, "-");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.INTEGER || b.type != TokenType.INTEGER) {
            report.error(file, line,
                "Command `-` failed. Both items on stack must be integers.");
            _errorExit();
          }
          _push(Token(file, TokenType.INTEGER, line, i, b.value - a.value));
        } else if (value == Tokens.STAR) {
          ifTooLittleItemsThrowError(2, "*");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.INTEGER || b.type != TokenType.INTEGER) {
            report.error(file, line,
                "Command `*` failed. Both items on stack must be integers.");
            _errorExit();
          }
          _push(Token(file, TokenType.INTEGER, line, i, a.value * b.value));
        } else if (value == Tokens.SLASH) {
          ifTooLittleItemsThrowError(2, "/");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.INTEGER || b.type != TokenType.INTEGER) {
            report.error(file, line,
                "Command `/` failed. Both items on stack must be integers.");
            _errorExit();
          }
          _push(Token(file, TokenType.FLOAT, line, i, b.value / a.value));
        } else if (value == Tokens.FLOAT_PLUS) {
          ifTooLittleItemsThrowError(2, "+.");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.FLOAT || b.type != TokenType.FLOAT) {
            report.error(file, line,
                "Command `+.` failed. Both items on stack must be floats.");
            _errorExit();
          }
          _push(Token(file, TokenType.FLOAT, line, i, a.value + b.value));
        } else if (value == Tokens.FLOAT_MINUS) {
          ifTooLittleItemsThrowError(2, "-.");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.FLOAT || b.type != TokenType.FLOAT) {
            report.error(file, line,
                "Command `-.` failed. Both items on stack must be floats.");
            _errorExit();
          }
          _push(Token(file, TokenType.FLOAT, line, i, b.value - a.value));
        } else if (value == Tokens.FLOAT_STAR) {
          ifTooLittleItemsThrowError(2, "*.");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.FLOAT || b.type != TokenType.FLOAT) {
            report.error(file, line,
                "Command `*.` failed. Both items on stack must be floats.");
            _errorExit();
          }
          _push(Token(file, TokenType.FLOAT, line, i, a.value * b.value));
        } else if (value == Tokens.FLOAT_SLASH) {
          ifTooLittleItemsThrowError(2, "/.");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.FLOAT || b.type != TokenType.FLOAT) {
            report.error(file, line,
                "Command `/.` failed. Both items on stack must be floats.");
            _errorExit();
          }
          _push(Token(file, TokenType.FLOAT, line, i, b.value / a.value));
        }
      } else if (type == TokenType.COMPARATOR) {
        if (value == Tokens.EQUAL_EQUAL) {
          ifTooLittleItemsThrowError(2, "=");
          Token a = _pop();
          Token b = _pop();
          if (a.type != b.type) {
            report.error(file, line,
                "Command `=` failed. Both items on stack must be the same type.");
            _errorExit();
          }
          _push(Token(file, TokenType.BOOLEAN, line, i, a.value == b.value));
        } else if (value == Tokens.BANG_EQUAL) {
          ifTooLittleItemsThrowError(2, "!=");
          Token a = _pop();
          Token b = _pop();
          if (a.type != b.type) {
            report.error(file, line,
                "Command `!=` failed. Both items on stack must be the same type.");
            _errorExit();
          }
          _push(Token(file, TokenType.BOOLEAN, line, i, a.value != b.value));
        } else if (value == Tokens.GREATER) {
          ifTooLittleItemsThrowError(2, ">");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.INTEGER || b.type != TokenType.INTEGER) {
            report.error(file, line,
                "Command `>` failed. Both items on stack must be integers.");
            _errorExit();
          }
          _push(Token(file, TokenType.BOOLEAN, line, i, b.value > a.value));
        } else if (value == Tokens.GREATER_EQUAL) {
          ifTooLittleItemsThrowError(2, ">=");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.INTEGER || b.type != TokenType.INTEGER) {
            report.error(file, line,
                "Command `>=` failed. Both items on stack must be integers.");
            _errorExit();
          }
          _push(Token(file, TokenType.BOOLEAN, line, i, b.value >= a.value));
        } else if (value == Tokens.LESS_EQUAL) {
          ifTooLittleItemsThrowError(2, "<=");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.INTEGER || b.type != TokenType.INTEGER) {
            report.error(file, line,
                "Command `>=` failed. Both items on stack must be integers.");
            _errorExit();
          }
          _push(Token(file, TokenType.BOOLEAN, line, i, b.value <= a.value));
        } else if (value == Tokens.LESS) {
          ifTooLittleItemsThrowError(2, "<");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.INTEGER || b.type != TokenType.INTEGER) {
            report.error(file, line,
                "Command `<` failed. Both items on stack must be integers.");
            _errorExit();
          }
          _push(Token(file, TokenType.BOOLEAN, line, i, b.value < a.value));
        }
      } else if (type == TokenType.KEYWORD) {
        if (value == "out") {
          ifIsEmptyThrowError("out");
          // stdout.write(_pop().value);
          print(_pop().value);
          // Type conversion commands
        } else if (value == "stoi") {
          ifIsEmptyThrowError("stoi"); // String To Integer
          try {
            _push(Token(
                file, TokenType.INTEGER, line, i, int.parse(_pop().value)));
          } catch (e) {
            report.error(file, line,
                "Command `stoi` failed. string must contain only an integer number.");
            _errorExit();
          }
        } else if (value == "stof") {
          ifIsEmptyThrowError("stof"); // String To Float
          try {
            _push(Token(
                file, TokenType.FLOAT, line, i, double.parse(_pop().value)));
          } catch (e) {
            report.error(file, line,
                "Command `stof` failed. string must only contain a floating-point number.");
            _errorExit();
          }
        } else if (value == "itof") {
          ifIsEmptyThrowError("itof"); // Integer to Float
          try {
            _push(Token(file, TokenType.FLOAT, line, i, _pop().value / 1));
          } catch (e) {
            report.error(file, line,
                "Command `itof` failed. Item on stack must be of type integer.");
            _errorExit();
          }
        } else if (value == "atos") {
          ifIsEmptyThrowError("atos"); // Any To String
          _push(
              Token(file, TokenType.STRING, line, i, _pop().value.toString()));
        }
        // Control flow
        else if (value == "if") {
          ifIsEmptyThrowError("if");

          Token a = _pop();

          if (a.type != TokenType.BOOLEAN) {
            report.error(file, line,
                "Command `if` failed. Item on stack must be of type boolean.");
            _errorExit();
          }

          if (_isAtEnd()) {
            report.error(file, line, "Command `if` is not followed by a block");
            _errorExit();
          }
          i++;

          if (tokens[i].value != Tokens.LEFT_BRACE) {
            report.error(
                file, line, "Command `if` is not followed by a block.");
            _errorExit();
          }
          i++;

          int startJMP = i - 1;
          int nest = 0;
          while (true) {
            if (_isAtEnd()) {
              report.error(
                  file, line, "Block has not been closed. Missing '{'.");
              _errorExit();
            } else if (tokens[i].value == Tokens.LEFT_BRACE) {
              nest++;
            } else if (tokens[i].value == Tokens.RIGHT_BRACE) {
              if (nest == 0) {
                if (!a.value) break;
                i = startJMP;
                break;
              } else {
                nest--;
              }
            }

            i++;
          }
        }
      } else if (type == TokenType.LANGUAGE) {
        if (!_isAtEnd()) {
          report.error(file, line, "Unexpected end of file.");
        }
      } else {
        _push(token);
      }
    }
  }
}
