type token =
  | EOF
  | INT
  | VOID
  | IF
  | ELSE
  | WHILE
  | BREAK
  | CONTINUE
  | RETURN
  | ID of (
# 8 "lib/parser.mly"
        string
# 15 "lib/parser.mli"
)
  | NUM of (
# 9 "lib/parser.mly"
        int
# 20 "lib/parser.mli"
)
  | ASSIGN
  | SEMI
  | COMMA
  | LPAREN
  | RPAREN
  | LBRACE
  | RBRACE
  | ADD
  | SUB
  | MUL
  | DIV
  | MOD
  | NOT
  | AND
  | OR
  | LT
  | GT
  | LE
  | GE
  | EQ
  | NE

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
