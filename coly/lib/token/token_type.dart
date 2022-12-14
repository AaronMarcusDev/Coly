// ignore_for_file: constant_identifier_names

enum TokenType {
  LANGUAGE,
  KEYWORD,
  STRING,
  INTEGER,
  FLOAT,
  BOOLEAN,
  CHARACTER,
  OPERATOR,
  COMPARATOR,
  ASSIGN,
  NULL
}

enum Tokens {
  // Single-character tokens.
  LEFT_PAREN,
  RIGHT_PAREN,
  LEFT_BRACE,
  RIGHT_BRACE,
  COMMA,
  DOT,
  MINUS,
  PLUS,
  SLASH,
  STAR,
  MODULO,
  FLOAT_PLUS,
  FLOAT_MINUS,
  FLOAT_SLASH,
  FLOAT_STAR,
  SEMICOLON,

  // Single-or-Double-character tokens.
  BANG,
  BANG_EQUAL,
  EQUAL,
  EQUAL_EQUAL,
  GREATER,
  GREATER_EQUAL,
  LESS,
  LESS_EQUAL,

  // Literals.
  STRING,
  NUMBER,

  //EOF
  EOF
}