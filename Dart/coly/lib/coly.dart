// ignore_for_file: non_constant_identifier_names

// Dart
import 'dart:io';
// Custom
import 'package:coly/tools/tools.dart' as tools;
import 'package:coly/lexer/lexer.dart';
import 'package:coly/parser/parser.dart';
import 'package:coly/interpreter/interpreter.dart';
import 'package:coly/interpreter/passthrough.dart' as passthrough;
import 'package:coly/token/token.dart';

Lexer lexer = Lexer();
Parser parser = Parser();
Interpreter interpreter = Interpreter();

void run(List<String> args) {
  if (args.isEmpty) {
    print("\x1B[31m[ERROR] Not enough arguments provided.\x1B[0m");
    print("[INFOR] Usage: coly <file> <args>");
    exit(1);
  }

  passthrough.args = args.sublist(1);

  String source = tools.loadFile(args[0]);
  List<Token> tokens = lexer.lex(args[0], source);
  List<Token> CFG = parser.parse(tokens);
  interpreter.interpret(CFG);
}
