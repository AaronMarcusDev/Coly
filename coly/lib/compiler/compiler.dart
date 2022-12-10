// ignore_for_file: non_constant_identifier_names
// Dart
import 'dart:io';
// Custom
import 'package:coly/compiler/init.dart' as init;
import 'package:coly/token/token.dart';
import 'package:coly/token/token_type.dart';
import 'package:coly/reporter/reporter.dart';

Reporter report = Reporter();
Stopwatch stopwatch = Stopwatch()..start();

class Compiler {
  List<String> generate(List<Token> tokens) {
    List<String> code = [];
    List<String> jumpLocations = [];
    // Init
    code.add(init.init);
    code.add("int main(int argc, char *argv[]) {");
    code.add("""
// INIT
      clock_t start = clock();
      for (int i = 1; i < argc; ++i)
        {
          value v;
          v.type = "string";
          v.value = argv[i];
          stack.push(v);
        };
    """);

    for (int i = 0; i < tokens.length; i++) {
      Token token = tokens[i];
      TokenType type = token.type;
      int line = token.line;
      String file = token.file;
      dynamic value = token.value;

      void emptyPanic() {
        code.add("if (stack.empty()) panic(\"$value\", \"Empty stack\");");
      }

      void tooLittleItemsPanic(amountOfItems) {
        code.add(
            "if (stack.size() < $amountOfItems) panic(\"$value\", \"Insufficient stack values\");");
      }

      bool _isAtEnd() => i >= tokens.length - 1;

      if (type == TokenType.OPERATOR) {
        if (value == Tokens.PLUS) {
          code.add("// PLUS");
          code.add("""
          {
          if (stack.size() < 2) panic("+", "Insufficient stack values");
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "integer" || v2.type != "integer") panic("+", "Invalid stack values");
                  value v;
                  v.type = "integer";
                  v.value = std::to_string(std::stoi(v1.value) + std::stoi(v2.value));
                  stack.push(v);
                  }
          """);
        } else if (value == Tokens.MINUS) {
          code.add("// MINUS");
          code.add("""
        {
          if (stack.size() < 2) panic("-", "Insufficient stack values");
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "integer" || v2.type != "integer") panic("-", "Invalid stack values");
                  value v;
                  v.type = "integer";
                  v.value = std::to_string(std::stoi(v2.value) - std::stoi(v1.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.STAR) {
          code.add("// STAR");
          code.add("""
          if (stack.size() < 2) panic("*", "Insufficient stack values");
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "integer" || v2.type != "integer") panic("*", "Invalid stack values");
                  value v;
                  v.type = "integer";
                  v.value = std::to_string(std::stoi(v1.value) * std::stoi(v2.value));
                  stack.push(v);
          """);
        } else if (value == Tokens.SLASH) {
          code.add("// SLASH");
          code.add("""
          {
          if (stack.size() < 2) panic("/", "Insufficient stack values");
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "integer" || v2.type != "integer") panic("*", "Invalid stack values");
                  value v;
                  v.type = "integer";
                  v.value = std::to_string(std::stoi(v2.value) / std::stoi(v1.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.MODULO) {
          code.add("// MODULO");
          code.add("""
          {
          if (stack.size() < 2) panic("%", "Insufficient stack values");
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "integer" || v2.type != "integer") panic("%", "Invalid stack values");
                  value v;
                  v.type = "integer";
                  v.value = std::to_string(std::stoi(v2.value) % std::stoi(v1.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.FLOAT_PLUS) {
          code.add("// FLOAT_PLUS");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "float" || v2.type != "float") panic("+.", "Invalid stack values");
                  value v;
                  v.type = "float";
                  v.value = std::to_string(std::stof(v1.value) + std::stof(v2.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.FLOAT_MINUS) {
          code.add("// FLOAT_MINUS");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "float" || v2.type != "float") panic("-.", "Invalid stack values");
                  value v;
                  v.type = "float";
                  v.value = std::to_string(std::stof(v2.value) - std::stof(v1.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.FLOAT_STAR) {
          code.add("// FLOAT_STAR");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "float" || v2.type != "float") panic("*.", "Invalid stack values");
                  value v;
                  v.type = "float";
                  v.value = std::to_string(std::stof(v1.value) * std::stof(v2.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.FLOAT_SLASH) {
          code.add("// FLOAT_MINUS");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "float" || v2.type != "float") panic("/.", "Invalid stack values");
                  value v;
                  v.type = "float";
                  v.value = std::to_string(std::stof(v2.value) / std::stof(v1.value));
                  stack.push(v);
          }
          """);
        }
      } else if (type == TokenType.COMPARATOR) {
        if (value == Tokens.EQUAL_EQUAL) {
          code.add("// EQUAL_EQUAL");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = v1.value == v2.value ? "true" : "false";
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.BANG_EQUAL) {
          code.add("// BANG_EQUAL");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = v1.value != v2.value ? "true" : "false";
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.GREATER) {
          code.add("// GREATER");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = std::stoi(v2.value) > std::stoi(v1.value) ? "true" : "false";
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.GREATER_EQUAL) {
          code.add("// GREATER_EQUAL");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = std::stoi(v2.value) >= std::stoi(v1.value) ? "true" : "false";
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.LESS_EQUAL) {
          code.add("// LESS_EQUAL");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = std::stoi(v2.value) <= std::stoi(v1.value) ? "true" : "false";
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.LESS) {
          code.add("// LESS");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = std::stoi(v2.value) < std::stoi(v1.value) ? "true" : "false";
                  stack.push(v);
          }
          """);
        }
      } else if (type == TokenType.KEYWORD) {
        // System
        if (value == "exit") {
          code.add("// EXIT");
          code.add("""
          if (stack.empty()) exit(0);
          value v = stack.top();
          stack.pop();
          if (v.type == "integer") exit(std::stoi(v.value)); else panic("exit", "Invalid stack value");
          """);
        } else if (value == "system") {
          code.add("// SYSTEM");
          tooLittleItemsPanic(1);
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("system", "Invalid stack value");
          system(v.value.c_str());
        }
          """);
        } else if (value == "elapsed") {
          code.add("// ELAPSED");
          code.add("""
          {
            clock_t end = clock();
            double elapsed = (double)(end - start) / CLOCKS_PER_SEC;
            value v;
            v.type = "float";
            v.value = std::to_string(elapsed);
            stack.push(v);
          }
        """);
        }
        // Input / Output
        else if (value == "out") {
          code.add("// OUT");
          emptyPanic();
          code.add("""
          std::cout << stack.top().value;
          stack.pop();
          """);
        } else if (value == "puts") {
          code.add("// PUTS");
          emptyPanic();
          code.add("""
          std::cout << stack.top().value << std::endl;
          stack.pop();
          """);
        } else if (value == "endl") {
          code.add("// ENDL");
          code.add("std::cout << std::endl;");
        } else if (value == "input") {
          code.add("// INPUT");
          code.add("""
        {
          std::string input;
          std::cin >> input;
          value v;
          v.type = "string";
          v.value = input;
          stack.push(v);
        }
          """);
        }
        // Basic stack operations
        else if (value == "dump") {
          code.add("// DUMP");
          emptyPanic();
          code.add("stack.pop();");
        } else if (value == "dup") {
          code.add("// DUP");
          emptyPanic();
          code.add("stack.push(stack.top());");
        } else if (value == "clear") {
          code.add("// CLEAR");
          code.add("stack = std::stack<value>();");
        } else if (value == "swap") {
          code.add("// SWAP");
          tooLittleItemsPanic(2);
          code.add("""
        {
          value v1 = stack.top();
          stack.pop();
          value v2 = stack.top();
          stack.pop();
          stack.push(v1);
          stack.push(v2);
        }
          """);
        } else if (value == "over") {
          code.add("// OVER");
          tooLittleItemsPanic(2);
          code.add("""
        {
          value v1 = stack.top();
          stack.pop();
          value v2 = stack.top();
          stack.push(v1);
          stack.push(v2);
        }
          """);
        } else if (value == "count") {
          code.add("// COUNT");
          code.add("""
        {
          value v;
          v.type = "integer";
          v.value = std::to_string(stack.size());
          stack.push(v);
        }
          """);
        } else if (value == "reverse") {
          code.add("// REVERSE");
          code.add("{\nstd::stack<value> temp;");
          code.add(
              "while (!stack.empty()) { temp.push(stack.top()); stack.pop(); }");
          code.add("stack = temp;\n}");
        }
        // Type conversion commands
        else if (value == "stoi") {
          code.add("// STOI");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("stoi", "Invalid stack value");
          v.type = "integer";
          try {
                  v.value = std::to_string(std::stoi(v.value));
          } catch (...) {
                  panic("stoi", "Invalid stack value");
          }
          stack.push(v);
        }
          """);
        } else if (value == "stof") {
          code.add("// STOF");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("stof", "Invalid stack value");
          v.type = "float";
          try {
                  v.value = std::to_string(std::stof(v.value));
          } catch (...) {
                  panic("stof", "Invalid stack value");
          }
          stack.push(v);
        }
          """);
        } else if (value == "itof") {
          code.add("// ITOF");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "integer") panic("itof", "Invalid stack value");
          v.type = "float";
          v.value = std::to_string(std::stof(v.value));
          stack.push(v);
        }
          """);
        } else if (value == "ftoi") {
          code.add("// FTOI");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "float") panic("ftoi", "Invalid stack value");
          v.type = "integer";
          try {
                  v.value = std::to_string(floor(std::stof(v.value)));
          } catch (...) {
                  panic("stof", "Invalid stack value");
          }
          stack.push(v);
        }
          """);
        } else if (value == "atos") {
          code.add("// ATOS");
          emptyPanic();
          code.add("""
        {
          value v;
          v.type = "string";
          v.value = stack.top().value;
          stack.pop();
          stack.push(v);
        }
          """);
        }
        // Control flow
        else if (value == "if") {
          code.add("// IF");
          emptyPanic();
          code.add("if (IFPOP().value == \"true\")");
        } else if (value == "set") {
          if (_isAtEnd()) {
            report.error(
                file, line, "Command `set` is not followed by a name.");
            exit(1);
          }
          i++;
          if (tokens[i].type != TokenType.KEYWORD) {
            report.error(file, line,
                "Command `set` is not followed by a name. Expected identifier.");
            exit(1);
          }
          if (jumpLocations.contains(tokens[i].value)) {
            report.error(file, line,
                "Command `set` is followed by an already declared location.");
            exit(1);
          }
          code.add("// SET");
          code.add("${tokens[i].value}:");
          jumpLocations.add(tokens[i].value);
        } else if (value == "jump") {
          if (_isAtEnd()) {
            report.error(
                file, line, "Command `set` is not followed by a name.");
            exit(1);
          }
          i++;
          if (tokens[i].type != TokenType.KEYWORD) {
            report.error(file, line,
                "Command `set` is not followed by a name. Expected identifier.");
            exit(1);
          }
          code.add("// JUMP");
          code.add("goto ${tokens[i].value};");
        }
        // String
        else if (value == "concat") {
          code.add("// CONCAT");
          tooLittleItemsPanic(2);
          code.add("""
        {
          value v1 = stack.top();
          stack.pop();
          value v2 = stack.top();
          stack.pop();
          if (v1.type != "string" || v2.type != "string") panic("concat", "Invalid stack value");
          v1.value = v2.value + v1.value;
          stack.push(v1);
        }
          """);
        } else if (value == "trim") {
          code.add("// TRIM");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("trim", "Invalid stack value");
          v.value = trim(v.value);
          stack.push(v);
        }
          """);
        } else if (value == "split") {
          code.add("// SPLIT");
          tooLittleItemsPanic(2);
          // Split string by delim in c++ and push results to stack by one
          code.add("""
        {
          // split b by a
            value b = IFPOP();
            value a = IFPOP();
            if (a.type != "string") panic("split", "Expected string, got " + a.type);
            if (b.type != "string") panic("split", "Expected string, got " + b.type);
            std::string str = a.value;
            std::string delim = b.value;
            std::vector<std::string> result;
            size_t pos = 0;
            std::string token;
            while ((pos = str.find(delim)) != std::string::npos) {
                token = str.substr(0, pos);
                result.push_back(token);
                str.erase(0, pos + delim.length());
            }
            result.push_back(str);
            for (int i = 0; i < result.size(); i++) {
                value v;
                v.type = "string";
                v.value = result[i];
                stack.push(v);
            }
        }
          """);
          // }
        } else if (value == "revsplit") {
          code.add("// REVSPLIT");
          tooLittleItemsPanic(2);
          // Split string by delim in c++ and push results to stack by one
          code.add("""
        {
          // split b by a
            value b = IFPOP();
            value a = IFPOP();
            if (a.type != "string") panic("split", "Expected string, got " + a.type);
            if (b.type != "string") panic("split", "Expected string, got " + b.type);
            std::string str = a.value;
            std::string delim = b.value;
            std::vector<std::string> result;
            size_t pos = 0;
            std::string token;
            while ((pos = str.find(delim)) != std::string::npos) {
                token = str.substr(0, pos);
                result.push_back(token);
                str.erase(0, pos + delim.length());
            }
            result.push_back(str);
            for (int i = result.size() - 1; i >= 0; i--) {
                value v;
                v.type = "string";
                v.value = result[i];
                stack.push(v);
            }
        }
          """);
          // }
        } else if (value == "length") {
          code.add("// LENGTH");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("length", "Invalid stack value");
          v.type = "integer";
          v.value = std::to_string(v.value.length());
          stack.push(v);
        }
          """);
        } else if (value == "replace") {
          code.add("// REPLACE");
          tooLittleItemsPanic(3);
          code.add("""
  	    {
          value a = stack.top();
          stack.pop();
          value b = stack.top();
          stack.pop();
          value c = stack.top();
          stack.pop();
          if (a.type != "string" || b.type != "string" || c.type != "string") panic("replace", "Invalid stack value");
          std::string code = c.value;
          findAndReplaceAll(code, b.value, a.value);
          value v;
          v.type = "string";
          v.value = code;
          stack.push(v);
        }
          """);
        } else if (value == "contains") {
          code.add("// CONTAINS");
          tooLittleItemsPanic(2);
          code.add("""
        {
          value v1 = stack.top();
          stack.pop();
          value v2 = stack.top();
          stack.pop();
          if (v1.type != "string" || v2.type != "string") panic("contains", "Invalid stack value");
          v1.type = "boolean";
          v1.value = v2.value.find(v1.value) != std::string::npos ? "true" : "false";
          stack.push(v1);
        }
          """);
        } else if (value == "startswith") {
          code.add("// STARTSWITH");
          tooLittleItemsPanic(2);
          code.add("""
        {
          value v1 = stack.top();
          stack.pop();
          value v2 = stack.top();
          stack.pop();
          if (v1.type != "string" || v2.type != "string") panic("startswith", "Invalid stack value");
          v1.type = "boolean";
          v1.value = v2.value.find(v1.value) == 0 ? "true" : "false";
          stack.push(v1);
        }
          """);
        } else if (value == "endswith") {
          code.add("// ENDSWITH");
          tooLittleItemsPanic(2);
          code.add("""
        {
          value v1 = stack.top();
          stack.pop();
          value v2 = stack.top();
          stack.pop();
          if (v1.type != "string" || v2.type != "string") panic("endswith", "Invalid stack value");
          v1.type = "boolean";
          v1.value = v2.value.rfind(v1.value) == v2.value.length() - v1.value.length() ? "true" : "false";
          stack.push(v1);
        }
          """);
        }
        // FileStream
        else if (value == "fRead") {
          code.add("// fREAD");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("fRead", "Expected string, got " + v.type);
          std::ifstream file(v.value);
          if (!file.is_open())
            panic("fRead", "Failed to open file");
          std::string str((std::istreambuf_iterator<char>(file)),
                          std::istreambuf_iterator<char>());
          v.type = "string";
          v.value = str;
          stack.push(v);
        }
          """);
        } else if (value == "fWrite") {
          code.add("// fWRITE");
          tooLittleItemsPanic(2);
          code.add("""
        {
          value a = IFPOP();
          value b = IFPOP();
          if (a.type != "string") panic("fWrite", "Expected string, got " + a.type);
          if (b.type != "string") panic("fWrite", "Expected string, got " + b.type);
          std::ofstream file(a.value);
          if (!file.is_open())
            panic("fWrite", "Failed to open file");
          file << b.value;
          file.close();
        }
          """);
        } else if (value == "fAppend") {
          code.add("// fAPPEND");
          tooLittleItemsPanic(2);
          code.add("""
        {
          value a = IFPOP();
          value b = IFPOP();
          if (a.type != "string") panic("fAppend", "Expected string, got " + a.type);
          if (b.type != "string") panic("fAppend", "Expected string, got " + b.type);
          std::ofstream file(a.value, std::ios_base::app);
          if (!file.is_open())
            panic("fAppend", "Failed to open file");
          file << b.value;
          file.close();
        }
        """);
        } else if (value == "fDelete") {
          code.add("// fDELETE");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("fDelete", "Expected string, got " + v.type);
          if (std::remove(v.value.c_str()) != 0)
            panic("fDelete", "Failed to delete file");
        }
        """);
        } else if (value == "fExists") {
          code.add("// fEXISTS");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("fExists", "Expected string, got " + v.type);
          v.type = "boolean";
          std::ifstream file(v.value);
          v.value = file ? "true" : "false";
          stack.push(v);
        }
        """);
        } else if (value == "fCreate") {
          code.add("// fCREATE");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("fCreate", "Expected string, got " + v.type);
          std::ofstream file(v.value);
          if (!file.is_open())
            panic("fCreate", "Failed to create file");
          file.close();
        }
        """);
        }
        // Unknown keyword
        else {
          report.error(file, line, "Unknown command `$value`.");
          exit(1);
        }
      } else if (type == TokenType.CHARACTER) {
        if (value == Tokens.LEFT_BRACE) code.add('{');
        if (value == Tokens.RIGHT_BRACE) code.add('}');
      } else if (type == TokenType.LANGUAGE) {
        if (!_isAtEnd()) {
          report.error(file, line, "Unexpected end of file.");
        }
        code.add("// END\nreturn 0;\n}");
      } else {
        String? stype;
        if (type == TokenType.STRING) stype = "string";
        if (type == TokenType.INTEGER) stype = "integer";
        if (type == TokenType.FLOAT) stype = "float";
        if (type == TokenType.BOOLEAN) stype = "boolean";

        code.add("// PUSH");
        code.add("""
          {
              value v;
              v.type = "$stype";
              v.value = "$value";
              stack.push(v);
          }

          """);
      }
    }
    return code;
  }

  String build(List<String> IR) {
    return IR.join("\n");
  }

  void compile(String filename, String code) {
    if (Platform.isWindows) {
      try {
        File("COLYOUTPUT.cpp").writeAsStringSync(code);
        Process.runSync("g++", ["COLYOUTPUT.cpp", "-o", "$filename.exe"]);
        File("COLYOUTPUT.cpp").deleteSync();
      } catch (e) {
        print("\x1B[31m[ERROR] g++ was not found.\x1B[0m");
        exit(1);
      }
    } else if (Platform.isLinux) {
      try {
        File("COLYOUTPUT.cpp").writeAsStringSync(code);
        Process.runSync("g++", ["COLYOUTPUT.cpp", "-o", filename]);
        File("COLYOUTPUT.cpp").deleteSync();
      } catch (e) {
        print("\x1B[31m[ERROR] g++ was not found.\x1B[0m");
        exit(1);
      }
    } else {
      report.error("<lang>", 0, "Unsupported platform.");
      exit(1);
    }
  }
}
