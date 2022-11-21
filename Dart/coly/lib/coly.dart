import 'package:coly/tools/tools.dart' as tools;
import 'package:coly/lexer/lexer.dart';
import 'package:coly/interpreter/interpreter.dart';
import 'package:coly/token/token.dart';
import 'dart:io';

Lexer lexer = Lexer();
Interpreter interpreter = Interpreter();

void run(List<String> args) {
  if (args.length != 1) {
    print("\x1B[31m[ERROR] Not enough arguments provided.\x1B[0m");
    print("[INFOR] Usage: coly <file>");
    exit(1);
  }

  String source = tools.loadFile(args[0]);
  List<Token> tokens = lexer.lex(args[0], source);
  interpreter.interpret(tokens);
}
