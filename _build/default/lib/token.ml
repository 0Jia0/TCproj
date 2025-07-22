(* 定义词法分析器返回的token类型 *)
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
  | ID of string
  | NUM of int
  | ASSIGN
  | SEMI
  | COMMA
  | LPAREN   (* ( *)
  | RPAREN   (* ) *)
  | LBRACE   (* { *)
  | RBRACE   (* } *)
  | ADD      (* + *)
  | SUB      (* - *)
  | MUL      (* * *)
  | DIV      (* / *)
  | MOD      (* % *)
  | NOT      (* ! *)
  | AND      (* && *)
  | OR       (* || *)
  | LT       (* < *)
  | GT       (* > *)
  | LE       (* <= *)
  | GE       (* >= *)
  | EQ       (* == *)
  | NE       (* != *)
  | ILLEGAL  (* 非法token *)

let token_to_string = function
  | EOF -> "EOF"
  | INT -> "int"
  | VOID -> "void"
  | IF -> "if"
  | ELSE -> "else"
  | WHILE -> "while"
  | BREAK -> "break"
  | CONTINUE -> "continue"
  | RETURN -> "return"
  | ID s -> "ID(" ^ s ^ ")"
  | NUM n -> "NUM(" ^ string_of_int n ^ ")"
  | ASSIGN -> "="
  | SEMI -> ";"
  | COMMA -> ","
  | LPAREN -> "("
  | RPAREN -> ")"
  | LBRACE -> "{"
  | RBRACE -> "}"
  | ADD -> "+"
  | SUB -> "-"
  | MUL -> "*"
  | DIV -> "/"
  | MOD -> "%"
  | NOT -> "!"
  | AND -> "&&"
  | OR -> "||"
  | LT -> "<"
  | GT -> ">"
  | LE -> "<="
  | GE -> ">="
  | EQ -> "=="
  | NE -> "!="
  | ILLEGAL -> "ILLEGAL"