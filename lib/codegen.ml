open Ast

(* RISC-V32 寄存器名 *)
let zero = "zero"
let sp = "sp"
let ra = "ra"
let fp = "s0"
let a0 = "a0"
let t0 = "t0"
let t1 = "t1"

(* 标签生成器 *)
let label_counter = ref 0
let new_label () =
  incr label_counter;
  "L" ^ string_of_int !label_counter

(* 代码生成环境：变量名->偏移，当前局部变量偏移 *)
type env = {
  var_offset: (string * int) list;
  current_offset: int;
}

let new_env () = { var_offset = []; current_offset = -16 }  (* 局部变量从-16(fp)开始，避免与ra/fp重叠 *)

(* 添加局部变量：负偏移，从-16(fp)开始递减 *)
let add_local_var env name =
  let offset = env.current_offset - 4 in
  { var_offset = (name, offset) :: env.var_offset; current_offset = offset }

(* 添加参数：正偏移，从8开始 *)
let add_param env name idx =
  let offset = 8 + idx * 4 in
  { var_offset = (name, offset) :: env.var_offset; current_offset = env.current_offset }

let find_var env name =
  try List.assoc name env.var_offset
  with Not_found -> failwith ("Undefined variable: " ^ name)

(* 计算栈空间需求，不生成代码 *)
let rec calc_stack_size env = function
  | Block stmts ->
      List.fold_left calc_stack_size env stmts
  | VarDecl (_, name, _) ->
      add_local_var env name
  | If (_, s1, s2_opt) ->
      let env1 = calc_stack_size env s1 in
      (match s2_opt with Some s2 -> calc_stack_size env1 s2 | None -> env1)
  | While (_, s) ->
      calc_stack_size env s
  | _ -> env

(* 生成表达式代码，结果放 t0 *)
let rec gen_expr env oc = function
  | Num n -> Printf.fprintf oc "  li %s, %d\n" t0 n
  | Var id ->
      let offset = find_var env id in
      Printf.fprintf oc "  lw %s, %d(%s)\n" t0 offset fp
  | Neg e ->
      gen_expr env oc e;
      Printf.fprintf oc "  sub %s, %s, %s\n" t0 zero t0
  | Not e ->
      gen_expr env oc e;
      Printf.fprintf oc "  seqz %s, %s\n" t0 t0
  | Binop (e1, And, e2) ->
      let false_label = new_label () in
      let end_label = new_label () in
      gen_expr env oc e1;
      Printf.fprintf oc "  beqz %s, %s\n" t0 false_label;
      gen_expr env oc e2;
      Printf.fprintf oc "  mv %s, %s\n" t0 t0;
      Printf.fprintf oc "  j %s\n" end_label;
      Printf.fprintf oc "%s:\n  li %s, 0\n%s:\n" false_label t0 end_label
  | Binop (e1, Or, e2) ->
      let true_label = new_label () in
      let end_label = new_label () in
      gen_expr env oc e1;
      Printf.fprintf oc "  bnez %s, %s\n" t0 true_label;
      gen_expr env oc e2;
      Printf.fprintf oc "  mv %s, %s\n" t0 t0;
      Printf.fprintf oc "  j %s\n" end_label;
      Printf.fprintf oc "%s:\n  li %s, 1\n%s:\n" true_label t0 end_label
  | Binop (e1, op, e2) ->
      gen_expr env oc e1;
      Printf.fprintf oc "  addi sp, sp, -4\n";
      Printf.fprintf oc "  sw %s, 0(sp)\n" t0;
      gen_expr env oc e2;
      Printf.fprintf oc "  lw %s, 0(sp)\n" t1;
      Printf.fprintf oc "  addi sp, sp, 4\n";
      (match op with
      | Add -> Printf.fprintf oc "  add %s, %s, %s\n" t0 t1 t0
      | Sub -> Printf.fprintf oc "  sub %s, %s, %s\n" t0 t1 t0
      | Mul -> Printf.fprintf oc "  mul %s, %s, %s\n" t0 t1 t0
      | Div -> Printf.fprintf oc "  div %s, %s, %s\n" t0 t1 t0
      | Mod -> Printf.fprintf oc "  rem %s, %s, %s\n" t0 t1 t0
      | Lt -> Printf.fprintf oc "  slt %s, %s, %s\n" t0 t1 t0
      | Gt -> Printf.fprintf oc "  sgt %s, %s, %s\n" t0 t1 t0
      | Le -> Printf.fprintf oc "  sgt %s, %s, %s\n  xori %s, %s, 1\n" t0 t1 t0 t0 t0
      | Ge -> Printf.fprintf oc "  slt %s, %s, %s\n  xori %s, %s, 1\n" t0 t1 t0 t0 t0
      | Eq -> Printf.fprintf oc "  xor %s, %s, %s\n  seqz %s, %s\n" t0 t1 t0 t0 t0
      | Ne -> Printf.fprintf oc "  xor %s, %s, %s\n  snez %s, %s\n" t0 t1 t0 t0 t0
      | _ -> ())
  | Call (fname, args) ->
      let n = List.length args in
      List.iteri (fun i arg ->
        gen_expr env oc arg;
        if i < 8 then
          Printf.fprintf oc "  mv a%d, %s\n" i t0
        else (
          Printf.fprintf oc "  addi %s, %s, -4\n" sp sp;
          Printf.fprintf oc "  sw %s, 0(%s)\n" t0 sp
        )
      ) args;
      Printf.fprintf oc "  call %s\n" fname;
      if n > 8 then
        Printf.fprintf oc "  addi %s, %s, %d\n" sp sp ((n-8)*4);
      Printf.fprintf oc "  mv %s, %s\n" t0 a0

(* 生成语句代码 *)
let rec gen_stmt env oc ret_label break_label cont_label = function
  | Block stmts ->
      let old_env = env in
      let rec aux env = function
        | [] -> env
        | s::ss -> aux (gen_stmt env oc ret_label break_label cont_label s) ss
      in
      ignore (aux env stmts);
      old_env
  | Expr e -> gen_expr env oc e; env
  | VarDecl (_, id, e) ->
      let new_env = add_local_var env id in
      gen_expr env oc e;
      let offset = find_var new_env id in
      Printf.fprintf oc "  sw %s, %d(%s)\n" t0 offset fp;
      new_env
  | Assign (id, e) ->
      gen_expr env oc e;
      let offset = find_var env id in
      Printf.fprintf oc "  sw %s, %d(%s)\n" t0 offset fp;
      env
  | If (cond, s1, s2_opt) ->
      let else_label = new_label () in
      let end_label = new_label () in
      gen_expr env oc cond;
      Printf.fprintf oc "  beqz %s, %s\n" t0 else_label;
      let env1 = gen_stmt env oc ret_label break_label cont_label s1 in
      Printf.fprintf oc "  j %s\n" end_label;
      Printf.fprintf oc "%s:\n" else_label;
      let env2 = match s2_opt with Some s2 -> gen_stmt env oc ret_label break_label cont_label s2 | None -> env1 in
      Printf.fprintf oc "%s:\n" end_label;
      env2
  | While (cond, s) ->
      let start_label = new_label () in
      let end_label = new_label () in
      Printf.fprintf oc "%s:\n" start_label;
      gen_expr env oc cond;
      Printf.fprintf oc "  beqz %s, %s\n" t0 end_label;
      let env' = gen_stmt env oc ret_label end_label start_label s in
      Printf.fprintf oc "  j %s\n" start_label;
      Printf.fprintf oc "%s:\n" end_label;
      env'
  | Break -> Printf.fprintf oc "  j %s\n" break_label; env
  | Continue -> Printf.fprintf oc "  j %s\n" cont_label; env
  | Return None -> Printf.fprintf oc "  li %s, 0\n  j %s\n" a0 ret_label; env
  | Return (Some e) ->
      gen_expr env oc e;
      Printf.fprintf oc "  mv %s, %s\n  j %s\n" a0 t0 ret_label; env

(* 生成函数代码 *)
let gen_function oc func =
  let ret_label = func.name ^ "_ret" in
  (* 参数入环境，正偏移 *)
  let env =
    List.mapi (fun i p -> (i, p)) func.params
    |> List.fold_left (fun env (i, p) -> add_param env p.pname i) (new_env ())
  in
  
  (* 只计算栈空间，不生成代码 *)
  let env_body = calc_stack_size env (Block func.body) in
  let stack_size = -env_body.current_offset in
  let total_stack = 16 + stack_size in
  
  (* 生成函数标签和序言 *)
  Printf.fprintf oc "\n%s:\n" func.name;
  Printf.fprintf oc "  addi %s, %s, -%d\n" sp sp total_stack;
  Printf.fprintf oc "  sw %s, %d(%s)\n" ra (total_stack-4) sp;
  Printf.fprintf oc "  sw %s, %d(%s)\n" fp (total_stack-8) sp;
  Printf.fprintf oc "  addi %s, %s, %d\n" fp sp total_stack;
  
  (* 保存前8个参数到fp+8, fp+12... *)
  List.iteri (fun i _ ->
    if i < 8 then
      Printf.fprintf oc "  sw a%d, %d(%s)\n" i (8 + i * 4) fp
  ) func.params;
  
  (* 生成函数体 - 只调用一次 *)
  ignore (gen_stmt env oc ret_label "" "" (Block func.body));
  
  (* 返回标签和尾声 *)
  Printf.fprintf oc "%s:\n" ret_label;
  Printf.fprintf oc "  lw %s, %d(%s)\n" ra (total_stack-4) sp;
  Printf.fprintf oc "  lw %s, %d(%s)\n" fp (total_stack-8) sp;
  Printf.fprintf oc "  addi %s, %s, %d\n" sp sp total_stack;
  Printf.fprintf oc "  ret\n"

(* 生成整个程序 *)
let gen_program oc program =
  Printf.fprintf oc ".text\n  .globl main\n";
  List.iter (gen_function oc) program
(* 生成整个程序 *)
(* let gen_program oc program =
  Printf.fprintf oc ".text\n";
  Printf.fprintf oc ".globl _start\n";
  Printf.fprintf oc "_start:\n";
  Printf.fprintf oc "  call main\n";
  Printf.fprintf oc "  li a7, 93\n";     (* exit syscall number *)
  Printf.fprintf oc "  mv a0, a0\n";     (* exit code in a0 *)
  Printf.fprintf oc "  ecall\n";         (* system call *)
  Printf.fprintf oc "\n.globl main\n";
  List.iter (gen_function oc) program *)