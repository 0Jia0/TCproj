(* OCamllex实现词法分析器 *)
{
  open Parser
  exception LexicalError of string
}

let digit = ['0'-'9']
let whitespace = [' ' '\t' '\r']
let newline = '\r' | '\n' | "\r\n"

rule token = parse
  | whitespace+    { token lexbuf }  
  | newline        { token lexbuf }
  | "//"           { line_comment lexbuf }  (* 使用专门的单行注释处理 *)
  | "/*"           { block_comment 1 lexbuf }  (* 处理多行注释，支持嵌套 *)
  
  (* 关键字 *)
  | "int"          { INT }
  | "void"         { VOID }
  | "if"           { IF }
  | "else"         { ELSE }
  | "while"        { WHILE }
  | "break"        { BREAK }
  | "continue"     { CONTINUE }
  | "return"       { RETURN }
  
  (* 标识符 *)
  | ['_''A'-'Z''a'-'z']['_''A'-'Z''a'-'z''0'-'9']* as id { ID id }
  
  (* 整数 *)
  | '0'            { NUM 0 }
  | ['1'-'9'] digit* as num { NUM (int_of_string num) }

  (* 运算符和分隔符 *)
  | '='            { ASSIGN }
  | ';'            { SEMI }
  | ','            { COMMA }
  | '('            { LPAREN }
  | ')'            { RPAREN }
  | '{'            { LBRACE }
  | '}'            { RBRACE }
  | '+'            { ADD }
  | '-'            { SUB }
  | '*'            { MUL }
  | '/'            { DIV }
  | '%'            { MOD }
  | '!'            { NOT }
  | "&&"           { AND }
  | "||"           { OR }
  | "<="           { LE }
  | ">="           { GE }
  | "=="           { EQ }
  | "!="           { NE }
  | '<'            { LT }
  | '>'            { GT }
  
  (* 结束和错误处理 *)
  | eof            { EOF }
  | _ as c         { 
      let msg = Printf.sprintf "Illegal character '%c'" c in
      raise (LexicalError msg)
    }

(* 单行注释处理 *)
and line_comment = parse
  | newline        { token lexbuf }           (* 换行时结束单行注释 *)
  | eof            { EOF }                    (* 文件结束 *)
  | _              { line_comment lexbuf }    (* 跳过所有字符，包括 /* */ *)

(* 多行注释处理 - 修改为宽松模式 *)
and block_comment depth = parse
  | "/*"       { block_comment (depth + 1) lexbuf }
  | "*/"       { 
      (* 修改：任何 */ 都结束整个注释块 *)
      token lexbuf
    }
  | newline    { block_comment depth lexbuf }
  | _          { block_comment depth lexbuf }
  | eof        { EOF }
