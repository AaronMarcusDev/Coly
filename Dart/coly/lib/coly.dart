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
  if (args.length < 2) {
    print("\x1B[31m[ERROR] Unexpected amount of arguments provided.\x1B[0m");
    print("[INFOR] Usage: coly <mode> <file> [args]");
    exit(1);
  } else {
    String mode = args[0];
    String file = args[1];

    if (mode == "build") {
      if (args.length > 2) {
        print(
            "\x1B[31m[ERROR] Unexpected amount of arguments provided.\x1B[0m");
        print("[INFOR] Usage: coly build <file>");
        exit(1);
      }

      String source = tools.loadFile(file);
      List<Token> tokens = lexer.lex("compile", file, source);
      List<Token> CFG = parser.parse("compile", tokens);
      List<String> IR = compiler.generate(CFG);
      String cpp = compiler.build(IR);
      compiler.compile("output", cpp);
    } else if (mode == "run") {
      passthrough.args = args.sublist(2);

      String source = tools.loadFile(file);
      List<Token> tokens = lexer.lex("interpret", file, source);
      List<Token> CFG = parser.parse("interpret", tokens);
      interpreter.interpret(CFG);
    } else {
      print("\x1B[31m[ERROR] Invalide mode.\x1B[0m");
      print("[INFOR] Usage: coly <mode> <file> [args]");
      print("[INFOR] Modes: run, build");
      exit(1);
    }
  }
}
