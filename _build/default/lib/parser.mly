%{
  open Ast
%}

%token EOF
%token INT VOID
%token IF ELSE WHILE BREAK CONTINUE RETURN
%token <string> ID
%token <int> NUM
%token ASSIGN SEMI COMMA
%token LPAREN RPAREN LBRACE RBRACE
%token ADD SUB MUL DIV MOD
%token NOT AND OR
%token LT GT LE GE EQ NE

%right ASSIGN
%left OR
%left AND
%left EQ NE
%left LT GT LE GE
%left ADD SUB
%left MUL DIV MOD
%right NOT
%right UMINUS UPLUS
%nonassoc NOELSE
%nonassoc ELSE

%start program
%type <Ast.program> program

%%

program:
  | function_def_list EOF { $1 }

function_def_list:
  | {[]}
  | function_def_list function_def { $1 @ [$2] }

function_def:
  | function_type ID LPAREN params RPAREN body {
    {return_type = $1; name = $2; params = $4; body = $6}
  }

function_type:
  | VOID {Void}
  | INT {Int}

params:
  | {[]}
  | param {[$1]}
  | params COMMA param { $1 @ [$3] }

param:
  | INT ID {{ptype = Int; pname = $2}}

body:
  | LBRACE stmt_list RBRACE { $2 }
  
stmt_list:
  | {[]}
  | stmt_list stmt { $1 @ [$2] }

stmt:
  | SEMI { Block [] }
  | expr SEMI { Expr $1 }
  | ID ASSIGN expr SEMI { Assign ($1, $3) }
  | INT ID ASSIGN expr SEMI { VarDecl ("int", $2, $4) }    (* int x = 1; *)
  | INT ID SEMI { VarDecl ("int", $2, Num 0) }             (* int x; 默认初始化为0 *)
  | RETURN expr SEMI { Return (Some $2) }
  | RETURN SEMI { Return None }
  | LBRACE stmt_list RBRACE { Block $2 }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If ($3, $5, None) }
  | IF LPAREN expr RPAREN stmt ELSE stmt { If ($3, $5, Some $7) }
  | WHILE LPAREN expr RPAREN stmt { While ($3, $5) }
  | BREAK SEMI { Break }
  | CONTINUE SEMI { Continue }              

expr:
  | NUM { Num $1 }
  | ID { Var $1 }
  | LPAREN expr RPAREN { $2 }
  // | SUB expr %prec UPLUS { $2 }
  | SUB expr %prec UMINUS { Neg $2 }
  | ADD expr %prec UPLUS { $2 }
  // | ADD expr %prec UMINUS { Neg $2 }
  | NOT expr { Not $2 }
  // | expr binop expr { Binop ($1, $2, $3) }
  // | ID LPAREN args RPAREN { Call ($1, $3) }
  | expr ADD expr { Binop ($1, Add, $3) }
  | expr SUB expr { Binop ($1, Sub, $3) }
  | expr MUL expr { Binop ($1, Mul, $3) }
  | expr DIV expr { Binop ($1, Div, $3) }
  | expr MOD expr { Binop ($1, Mod, $3) }
  | expr EQ expr { Binop ($1, Eq, $3) }
  | expr NE expr { Binop ($1, Ne, $3) }
  | expr LT expr { Binop ($1, Lt, $3) }
  | expr GT expr { Binop ($1, Gt, $3) }
  | expr LE expr { Binop ($1, Le, $3) }
  | expr GE expr { Binop ($1, Ge, $3) }
  | expr AND expr { Binop ($1, And, $3) }
  | expr OR expr { Binop ($1, Or, $3) }
  | ID LPAREN args RPAREN { Call ($1, $3) }

args:
  | {[]}
  | expr {[$1]}
  | args COMMA expr { $1 @ [$3] }

// binop:
//   | ADD { Add }
//   | SUB { Sub }
//   | MUL { Mul }
//   | DIV { Div }
//   | MOD { Mod }
//   | EQ { Eq }
//   | NE { Ne }
//   | LT { Lt }
//   | GT { Gt }
//   | LE { Le }
//   | GE { Ge }
//   | AND { And }
//   | OR { Or }
%%