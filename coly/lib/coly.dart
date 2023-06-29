// ignore_for_file: non_constant_identifier_names

// Dart
import 'dart:io';
// Custom
import 'package:coly/tools/tools.dart' as tools;
import 'package:coly/shared/source/source.dart' as shared_source;
import 'package:coly/token/token.dart';
import 'package:coly/lexer/lexer.dart';
import 'package:coly/parser/parser.dart';
import 'package:coly/interpreter/interpreter.dart';
import 'package:coly/interpreter/passthrough.dart' as passthrough;
import 'package:coly/compiler/compiler.dart';
import 'package:coly/update/update.dart' as update;

Lexer lexer = Lexer();
Parser parser = Parser();
Interpreter interpreter = Interpreter();
Compiler compiler = Compiler();

void run(List<String> args) async {
  String scriptFolderPath;
  if (Platform.isWindows) scriptFolderPath = Platform.resolvedExecutable.replaceAll("coly.exe", '');
  else scriptFolderPath = Platform.resolvedExecutable.replaceAll("coly", '');
  (bool, String) hasUpdate = await update.hasUpdate();

  if (hasUpdate.$1) {
    print(
        "[INFOR] There is a newer version of coly available (Version ${hasUpdate.$2})");
  }

  String scriptFolderPath =
      Platform.resolvedExecutable.replaceAll("coly.exe", '');

  if (!Directory("$scriptFolderPath/stdlib").existsSync()) {
    print("\x1B[31m[ERROR] Standard library could not be located.\x1B[0m");
    print(
        "[INFOR] Please check if the standard library is in the same folder as the executable.");
    exit(1);
  }

  try {
    Process.runSync("g++", ["--version"]);
  } catch (e) {
    print("\x1B[31m[ERROR] G++ could not be located.\x1B[0m");
    if (Platform.isWindows) {
      print(
          "[INFOR] Please install G++ from https://code.visualstudio.com/docs/cpp/config-mingw");
    } else {
      print("[INFOR] Please install G++ from your package manager.");
      print("[INFOR] Example: sudo apt install g++ (Debian/Ubuntu)");
    }
    exit(1);
  }

  if (args.length < 2) {
    print("\x1B[31m[ERROR] Unexpected amount of arguments provided.\x1B[0m");
    print("[INFOR] Usage: coly <mode> <file> [args]");
    print("[INFOR] Modes: run, build, IR");
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
      shared_source.source = source;
      List<Token> tokens = lexer.lex("compile", file, source);
      List<Token> CFG =
          parser.parse("compile", tokens, "$scriptFolderPath/stdlib");
      List<String> IR = compiler.generate(CFG);
      String cpp = compiler.build(IR);
      compiler.compile("output", cpp);
    } else if (mode == "run") {
      passthrough.args = args.sublist(2);
      String source = tools.loadFile(file);
      shared_source.source = source;
      List<Token> tokens = lexer.lex("interpret", file, source);
      List<Token> CFG =
          parser.parse("interpret", tokens, "$scriptFolderPath/stdlib");
      interpreter.interpret(CFG);
    } else if (mode == "IR") {
      String source = tools.loadFile(file);
      shared_source.source = source;
      List<Token> tokens = lexer.lex("compile", file, source);
      List<Token> CFG =
          parser.parse("compile", tokens, "$scriptFolderPath/stdlib");
      List<String> IR = compiler.generate(CFG);
      try {
        File('output.cpp').writeAsStringSync(compiler.build(IR));
      } catch (e) {
        print("\x1B[31m[ERROR] Could not write to file.\x1B[0m");
        print("[INFOR] Please check permissions.");
        exit(1);
      }
    } else {
      print("\x1B[31m[ERROR] Invalide mode.\x1B[0m");
      print("[INFOR] Usage: coly <mode> <file> [args]");
      print("[INFOR] Modes: run, build, IR");
      exit(1);
    }
  }
}
