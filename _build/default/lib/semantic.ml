(* 语义分析 *)
open Ast

exception Semantic_error of string

(* 变量类型 *)
type vtype = IntType

(* 作用域环境 *)
type env = {
  vars: (string * vtype) list;         (* 当前作用域变量 *)
  parent: env option;                  (* 上层作用域 *)
  in_loop: bool;                       (* 是否在循环内 *)
  ret_type: function_type option;      (* 当前函数返回类型 *)
}

type func_info = {
  ret_type: function_type;
  params: (string * vtype) list;
}

(* 查找变量类型（支持作用域嵌套） *)
let rec find_var env name =
  match List.assoc_opt name env.vars with
  | Some t -> Some t
  | None -> (match env.parent with Some p -> find_var p name | None -> None)

(* 检查变量是否已在当前作用域声明 *)
let var_declared_in_current_scope env name =
  List.exists (fun (n, _) -> n = name) env.vars

(* 检查表达式类型 *)
let rec check_expr env funcs expr =
  match expr with
  | Num _ -> IntType
  | Var name -> (
      match find_var env name with
      | Some IntType -> IntType
      | None -> raise (Semantic_error ("变量未声明: " ^ name))
    )
  | Binop (e1, _, e2) ->
      let t1 = check_expr env funcs e1 in
      let t2 = check_expr env funcs e2 in
      (match t1, t2 with
      | IntType, IntType -> IntType
      )
  | Neg e | Not e ->
      let t = check_expr env funcs e in
      (match t with IntType -> IntType)
  | Call (fname, args) ->
      if not (Hashtbl.mem funcs fname) then
        raise (Semantic_error ("函数未声明: " ^ fname));
      let finfo = Hashtbl.find funcs fname in
      let param_len = List.length finfo.params in
      if List.length args <> param_len then
        raise (Semantic_error (Printf.sprintf "函数 %s 参数数量不匹配: 期望%d, 实际%d" fname param_len (List.length args)));
      List.iter2 (fun arg (_, ptype) ->
        let t = check_expr env funcs arg in
        match t, ptype with
        | IntType, IntType -> ()
      ) args finfo.params;
      (match finfo.ret_type with Int -> IntType | Void -> IntType)  (* 允许void函数调用在表达式中，后续可加强 *)

(* 检查语句 *)
let rec check_stmt env funcs stmt =
  match stmt with
  | Block stmts ->
      let new_env = { env with vars = []; parent = Some env } in
      List.fold_left (fun e s -> check_stmt e funcs s) new_env stmts
  | Expr e -> ignore (check_expr env funcs e); env
  | VarDecl (typ, name, e) ->
      if var_declared_in_current_scope env name then
        raise (Semantic_error ("变量重复声明: " ^ name));
      let t = check_expr env funcs e in
      (match typ, t with
      | "int", IntType -> ()
      | _ -> raise (Semantic_error ("变量声明类型错误: " ^ name)));
      { env with vars = (name, IntType) :: env.vars }
  | Assign (name, e) ->
      (match find_var env name with
      | Some IntType ->
          let t = check_expr env funcs e in
          (match t with IntType -> ())
      | None -> raise (Semantic_error ("变量未声明: " ^ name)));
      env
  | If (cond, then_stmt, else_opt) ->
      let t = check_expr env funcs cond in
      (match t with IntType -> ());
      let _ = check_stmt env funcs then_stmt in
      (match else_opt with Some s -> ignore (check_stmt env funcs s) | None -> ());
      env
  | While (cond, body) ->
      let t = check_expr env funcs cond in
      (match t with IntType -> ());
      let loop_env = { env with in_loop = true } in
      ignore (check_stmt loop_env funcs body);
      env
  | Break ->
      if not env.in_loop then raise (Semantic_error "break 只能出现在循环中");
      env
  | Continue ->
      if not env.in_loop then raise (Semantic_error "continue 只能出现在循环中");
      env
  | Return None ->
      (match env.ret_type with
      | Some Int -> raise (Semantic_error "int函数必须返回值")
      | Some Void -> ()
      | None -> raise (Semantic_error "return 语句不在函数内"));
      env
  | Return (Some e) ->
      (match env.ret_type with
      | Some Int ->
          let t = check_expr env funcs e in
          (match t with IntType -> ())
      | Some Void -> raise (Semantic_error "void函数不能返回值")
      | None -> raise (Semantic_error "return 语句不在函数内"));
      env

(* 检查函数定义 *)
let check_function funcs (func: function_def) =
  (* 检查参数名唯一 *)
  let param_names = List.map (fun p -> p.pname) func.params in
  let param_set = List.sort_uniq String.compare param_names in
  if List.length param_names <> List.length param_set then
    raise (Semantic_error ("函数参数名重复: " ^ func.name));
  (* 构建初始环境 *)
  let env = {
    vars = List.map (fun p -> (p.pname, IntType)) func.params;
    parent = None;
    in_loop = false;
    ret_type = Some func.return_type;
  } in
  (* 检查函数体 *)
  ignore (List.fold_left (fun e s -> check_stmt e funcs s) env func.body);
  (* int函数必须所有路径return int，这里简单检查最后一条语句是否return，完整性可加强 *)
  if func.return_type = Int then
    let rec has_return stmts =
      match List.rev stmts with
      | (Return (Some _)) :: _ -> true
      | (If (_, t, Some e)) :: _ -> has_return [t] && has_return [e]
      | (If (_, _, None)) :: _ -> false
      | (Block ss) :: _ -> has_return ss
      | _ -> false
    in
    if not (has_return func.body) then
      raise (Semantic_error ("int函数 " ^ func.name ^ " 不是所有路径都return"));
  ()

(* 检查整个程序 *)
let check_program (prog: program) =
  (* 构建全局函数表 *)
  let funcs = Hashtbl.create 16 in
  List.iter (fun f ->
    if Hashtbl.mem funcs f.name then
      raise (Semantic_error ("函数重复定义: " ^ f.name));
    Hashtbl.add funcs f.name { ret_type = f.return_type; params = List.map (fun p -> (p.pname, IntType)) f.params }
  ) prog;
  (* 检查 main 函数 *)
  if not (Hashtbl.mem funcs "main") then
    raise (Semantic_error "缺少main函数");
  let mainf = Hashtbl.find funcs "main" in
  (match mainf.ret_type, mainf.params with
  | Int, [] -> ()
  | _ -> raise (Semantic_error "main函数必须为int main(void)"));
  (* 检查所有函数 *)
  List.iter (fun f -> check_function funcs f) prog