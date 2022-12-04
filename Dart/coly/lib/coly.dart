// ignore_for_file: non_constant_identifier_names

// Dart
import 'dart:io';
// Custom
import 'package:coly/tools/tools.dart' as tools;
import 'package:coly/lexer/lexer.dart';
import 'package:coly/parser/parser.dart';
import 'package:coly/interpreter/interpreter.dart';
import 'package:coly/compiler/compiler.dart';
import 'package:coly/interpreter/passthrough.dart' as passthrough;
import 'package:coly/token/token.dart';

Lexer lexer = Lexer();
Parser parser = Parser();
Interpreter interpreter = Interpreter();
Compiler compiler = Compiler();

void run(List<String> args) {
  if (args.length == 2) {
    String mode = args[0];
    String file = args[1];

    if (mode == "build") {
      passthrough.args = args.sublist(1);

      String source = tools.loadFile(file);
      List<Token> tokens = lexer.lex("compile", args[0], source);
      List<Token> CFG = parser.parse("compile", tokens);
      compiler.generate(CFG);
    } else if (mode == "run") {
      passthrough.args = args.sublist(1);

      String source = tools.loadFile(file);
      List<Token> tokens = lexer.lex("interpret", args[0], source);
      List<Token> CFG = parser.parse("interpret", tokens);
      interpreter.interpret(CFG);
    }
  } else {
    print("\x1B[31m[ERROR] Unexpected amount of arguments provided.\x1B[0m");
    print("[INFOR] Usage: coly <mode> <file> [args]");
    exit(1);
  }
}
