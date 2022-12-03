// Dart
import 'dart:io';
// Custom
import 'package:coly/token/token.dart';
import 'package:coly/token/token_type.dart';
import 'package:coly/reporter/reporter.dart';
import 'package:coly/interpreter/passthrough.dart' as passthrough;

Reporter report = Reporter();
Stopwatch stopwatch = Stopwatch()..start();

class Interpreter {
  void interpret(List<Token> tokens) {
    stopwatch.elapsedMilliseconds;
    // Initialize stack
    List<Token> stack = [];
    for (String arg in passthrough.args) {
      stack.add(Token("ARGS", TokenType.STRING, 0, 0, arg));
    }
    // Variables
    Map<String, int> jumpLocations = {};
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
        if (stack.length < amountOfItems) {
          report.error(file, line,
              "Command `$command` failed. Too little items on stack.");
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
        } else if (value == Tokens.MODULO) {
          ifTooLittleItemsThrowError(2, "%");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.INTEGER || b.type != TokenType.INTEGER) {
            report.error(file, line,
                "Command `%` failed. Both items on stack must be integers.");
            _errorExit();
          }
          _push(Token(file, TokenType.INTEGER, line, i, b.value % a.value));
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
        // System
        if (value == "exit") {
          if (stack.isEmpty) exit(0);
          Token a = _pop();
          if (a.type != TokenType.INTEGER) {
            report.error(file, line,
                "Command `exit` failed. Item on stack must be an integer.");
            _errorExit();
          }
          exit(a.value);
        } else if (value == "system") {
          ifIsEmptyThrowError("system");
          Token a = _pop();
          if (a.type != TokenType.STRING) {
            report.error(file, line,
                "Command `system` failed. Item on stack must be a string.");
            _errorExit();
          }
          List<String> keywords = a.value.split(" ");
          String cmd = keywords[0];
          keywords.removeAt(0);
          try {
            // make a shell command and print the result
            ProcessResult result = Process.runSync(cmd, keywords);
            _push(Token(file, TokenType.STRING, line, i, result.stdout));
          } catch (e) {
            report.error(file, line,
                "Command `system` failed. Could not run command `${a.value}`.");
            _errorExit();
          }
        } else if (value == "elapsed") {
          _push(Token(
              file, TokenType.STRING, line, i, (stopwatch.elapsedMilliseconds / 1000).toString()));
        }
        // Input / Output
        else if (value == "out") {
          ifIsEmptyThrowError("out");
          stdout.write(_pop().value);
        } else if (value == "puts") {
          ifIsEmptyThrowError("puts");
          print(_pop().value);
        } else if (value == "endl") {
          print("");
        } else if (value == "peek") {
          ifIsEmptyThrowError("peek");
          stdout.write(stack[stack.length - 1].value);
        } else if (value == "in") {
          _push(Token(file, TokenType.STRING, line, i, stdin.readLineSync()));
        } else if (value == "input") {
          _push(Token(file, TokenType.STRING, line, i, stdin.readLineSync()));
        }
        // Basic stack operations
        else if (value == "dump") {
          ifIsEmptyThrowError("dump");
          _pop();
        } else if (value == "dup") {
          ifIsEmptyThrowError("dup");
          _push(stack.last);
        } else if (value == "clear") {
          stack = [];
        } else if (value == "swap") {
          ifTooLittleItemsThrowError(2, "swap");
          Token a = _pop();
          Token b = _pop();
          _push(a);
          _push(b);
        } else if (value == "over") {
          ifTooLittleItemsThrowError(2, "over");
          Token a = _pop();
          Token b = _pop();
          _push(b);
          _push(a);
          _push(b);
        } else if (value == "count") {
          _push(Token(file, TokenType.INTEGER, line, i, stack.length));
        } else if (value == "reverse") {
          stack = stack.reversed.toList();
        }
        // Type conversion commands
        else if (value == "stoi") {
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
        } else if (value == "ftoi") {
          ifIsEmptyThrowError("ftoi");
          try {
            _push(Token(file, TokenType.INTEGER, line, i, _pop().value ~/ 1));
          } catch (e) {
            report.error(file, line,
                "Command `ftoi` failed. Item on stack must be of type float.");
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
        } else if (value == "set") {
          if (_isAtEnd()) {
            report.error(
                file, line, "Command `set` is not followed by a name.");
            _errorExit();
          }
          i++;
          if (tokens[i].type != TokenType.KEYWORD) {
            report.error(file, line,
                "Command `set` is not followed by a name. Expected identifier.");
            _errorExit();
          }
          jumpLocations[tokens[i].value] = i;
        } else if (value == "jump") {
          if (_isAtEnd()) {
            report.error(
                file, line, "Command `set` is not followed by a name.");
            _errorExit();
          }
          i++;
          if (tokens[i].type != TokenType.KEYWORD) {
            report.error(file, line,
                "Command `set` is not followed by a name. Expected identifier.");
            _errorExit();
          }
          try {
            i = jumpLocations[tokens[i].value]!;
          } catch (e) {
            report.error(file, line,
                "Command `jump` failed. Jump location does not exist.");
            _errorExit();
          }
        } else if (value == "free") {
          if (_isAtEnd()) {
            report.error(
                file, line, "Command `set` is not followed by a name.");
            _errorExit();
          }
          i++;
          if (tokens[i].type != TokenType.KEYWORD) {
            report.error(file, line,
                "Command `set` is not followed by a name. Expected identifier.");
            _errorExit();
          }
          if (jumpLocations.remove(tokens[i].value) == null) {
            report.error(file, line,
                "Command `free` failed. Jump location does not exist.");
            _errorExit();
          }
        }
        // String
        else if (value == "concat") {
          ifTooLittleItemsThrowError(2, "concat");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
            report.error(file, line,
                "Command `concat` failed. Both items on stack must be of type string.");
            _errorExit();
          }
          _push(Token(file, TokenType.STRING, line, i, b.value + a.value));
        } else if (value == "trim") {
          ifIsEmptyThrowError("trim");
          Token a = _pop();
          if (a.type != TokenType.STRING) {
            report.error(file, line,
                "Command `trim` failed. Item on stack must be of type string.");
            _errorExit();
          }
          _push(Token(file, TokenType.STRING, line, i, a.value.trim()));
        } else if (value == "split") {
          ifTooLittleItemsThrowError(2, "split");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
            report.error(file, line,
                "Command `split` failed. Both items on stack must be of type string.");
            _errorExit();
          }
          for (String s in b.value.split(a.value)) {
            _push(Token(file, TokenType.STRING, line, i, s));
          }
        } else if (value == "revsplit") {
          ifTooLittleItemsThrowError(2, "revsplit");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
            report.error(file, line,
                "Command `split` failed. Both items on stack must be of type string.");
            _errorExit();
          }

          List<String> split = b.value.split(a.value);
          for (int i = split.length - 1; i >= 0; i--) {
            _push(Token(file, TokenType.STRING, line, i, split[i]));
          }
        } else if (value == "length") {
          ifIsEmptyThrowError("length");
          Token a = _pop();
          if (a.type != TokenType.STRING) {
            report.error(file, line,
                "Command `length` failed. Item on stack must be of type string.");
            _errorExit();
          }
          _push(Token(file, TokenType.INTEGER, line, i, a.value.length));
        } else if (value == "replace") {
          ifTooLittleItemsThrowError(3, "replace");
          Token a = _pop();
          Token b = _pop();
          Token c = _pop();
          if (a.type != TokenType.STRING ||
              b.type != TokenType.STRING ||
              c.type != TokenType.STRING) {
            report.error(file, line,
                "Command `replace` failed. All items on stack must be of type string.");
            _errorExit();
          }
          _push(Token(file, TokenType.STRING, line, i,
              c.value.replaceAll(b.value, a.value)));
        } else if (value == "contains") {
          ifTooLittleItemsThrowError(2, "contains");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
            report.error(file, line,
                "Command `contains` failed. Both items on stack must be of type string.");
            _errorExit();
          }
          _push(Token(
              file, TokenType.BOOLEAN, line, i, b.value.contains(a.value)));
        } else if (value == "startswith") {
          ifTooLittleItemsThrowError(2, "startswith");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
            report.error(file, line,
                "Command `startswith` failed. Both items on stack must be of type string.");
            _errorExit();
          }
          _push(Token(
              file, TokenType.BOOLEAN, line, i, b.value.startsWith(a.value)));
        } else if (value == "endswith") {
          ifTooLittleItemsThrowError(2, "endswith");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
            report.error(file, line,
                "Command `endswith` failed. Both items on stack must be of type string.");
            _errorExit();
          }
          _push(Token(
              file, TokenType.BOOLEAN, line, i, b.value.endsWith(a.value)));
        }
        // FileStream
        else if (value == "fRead") {
          ifIsEmptyThrowError("fRead");
          Token a = _pop();
          if (a.type != TokenType.STRING) {
            report.error(file, line,
                "Command `fRead` failed. Item on stack must be of type string.");
            _errorExit();
          }
          try {
            _push(Token(file, TokenType.STRING, line, i,
                File(a.value).readAsStringSync()));
          } catch (e) {
            report.error(file, line,
                "Command `fRead` failed. File does not exist or is not readable.");
            _errorExit();
          }
        } else if (value == "fWrite") {
          ifTooLittleItemsThrowError(2, "fWrite");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
            report.error(file, line,
                "Command `fWrite` failed. Both items on stack must be of type string.");
            _errorExit();
          }
          try {
            File(a.value).writeAsStringSync(b.value);
          } catch (e) {
            report.error(file, line,
                "Command `fWrite` failed. File does not exist or is not writable.");
            _errorExit();
          }
        } else if (value == "fAppend") {
          ifTooLittleItemsThrowError(2, "fAppend");
          Token a = _pop();
          Token b = _pop();
          if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
            report.error(file, line,
                "Command `fAppend` failed. Both items on stack must be of type string.");
            _errorExit();
          }
          try {
            File(a.value).writeAsStringSync(b.value, mode: FileMode.append);
          } catch (e) {
            report.error(file, line,
                "Command `fAppend` failed. File does not exist or is not writable.");
            _errorExit();
          }
        } else if (value == "fDelete") {
          ifIsEmptyThrowError("fDelete");
          Token a = _pop();
          if (a.type != TokenType.STRING) {
            report.error(file, line,
                "Command `fDelete` failed. Item on stack must be of type string.");
            _errorExit();
          }
          try {
            File(a.value).deleteSync();
          } catch (e) {
            report.error(file, line,
                "Command `fDelete` failed. File does not exist or is not writable.");
            _errorExit();
          }
        } else if (value == "fExists") {
          ifIsEmptyThrowError("fExists");
          Token a = _pop();
          if (a.type != TokenType.STRING) {
            report.error(file, line,
                "Command `fExists` failed. Item on stack must be of type string.");
            _errorExit();
          }
          _push(Token(
              file, TokenType.BOOLEAN, line, i, File(a.value).existsSync()));
        } else if (value == "fCreate") {
          ifIsEmptyThrowError("fCreate");
          Token a = _pop();
          if (a.type != TokenType.STRING) {
            report.error(file, line,
                "Command `fCreate` failed. Item on stack must be of type string.");
            _errorExit();
          }
          try {
            File(a.value).createSync();
          } catch (e) {
            report.error(file, line, "Command `fCreate` failed.");
            _errorExit();
          }
        }
        // Unknown keyword
        else {
          report.error(file, line, "Unknown command `$value`.");
          _errorExit();
        }
      } else if (type == TokenType.LANGUAGE) {
        if (!_isAtEnd()) {
          report.error(file, line, "Unexpected end of file.");
          _errorExit();
        }
      } else {
        if (type != TokenType.CHARACTER) _push(token);
      }
    }
  }
}
