(*AST*)
type binop = 
  | Add | Sub | Mul | Div | Mod
  | Lt | Gt | Le | Ge | Eq | Ne
  | And | Or

type expr =
  | Num of int
  | Var of string
  | Binop of expr * binop * expr
  | Neg of expr
  | Not of expr
  | Call of string * expr list

type stmt =
  | Block of stmt list
  | Expr of expr
  | VarDecl of string * string * expr  (* type, id, expr *)
  | Assign of string * expr   (* id = expr; *)
  | If of expr * stmt * stmt option (* if (expr) stmt [else stmt] *)
  | While of expr * stmt      (* while (expr) stmt *)
  | Break
  | Continue
  | Return of expr option

type param_type = Int

type param = { ptype: param_type; pname: string } 

type function_type = Int | Void

type function_def = {
  return_type: function_type;
  name: string;
  params: param list;
  body: stmt list;
}

type program = function_def list

