(* 编译器主程序 *)
open Lexer
open Parser
open Semantic
open Codegen
open Printf

(* 读取文件内容的函数 *)
let read_file filename =
  let ch = open_in filename in
  let len = in_channel_length ch in
  let content = really_input_string ch len in
  close_in ch;
  content

(* 主函数 *)
let () =
  (* 检查命令行参数 *)
  if Array.length Sys.argv != 2 then begin
    prerr_endline "用法: toycproj <输入文件.tc>";
    exit 1
  end;
  
  let input_file = Sys.argv.(1) in
  
  (* 检查文件扩展名 *)
  if not (Filename.check_suffix input_file ".tc") then begin
    prerr_endline "错误: 输入文件必须是 .tc 扩展名";
    exit 1
  end;
  
  try
    (* 读取源文件 *)
    let source = read_file input_file in
    printf "[INFO] 成功读取文件: %s\n" input_file;
    
    (* 词法分析 *)
    let lexbuf = Lexing.from_string source in
    lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = input_file };
    
    (* 语法分析 *)
    let lexbuf = Lexing.from_string source in
    lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = input_file };
    
    let ast = 
      try comp_unit token lexbuf 
      with Parsing.Parse_error ->
        let pos = lexbuf.lex_curr_p in
        let msg = sprintf "语法错误在 %s:%d:%d" 
                  pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol) in
        failwith msg
    in
    printf "[INFO] 语法分析完成，生成AST\n";
    
    (* 语义分析 *)
    let _ = Semantic.check_comp_unit ast in
    printf "[INFO] 语义分析完成，无错误\n";
    
    (* 代码生成 *)
    let output_file = (Filename.chop_suffix input_file ".tc") ^ ".s" in
    let asm_code = generate ast in
    
    (* 写入汇编文件 *)
    let oc = open_out output_file in
    output_string oc asm_code;
    close_out oc;
    
    printf "[SUCCESS] 编译成功! 输出文件: %s\n" output_file;
    
  with
  | LexicalError msg -> 
      prerr_endline ("词法错误: " ^ msg); exit 1
  | Failure msg -> 
      prerr_endline ("错误: " ^ msg); exit 1
  | Semantic_error msg -> 
      prerr_endline ("语义错误: " ^ msg); exit 1
  | Sys_error msg -> 
      prerr_endline ("系统错误: " ^ msg); exit 1
  | e -> 
      prerr_endline ("未处理的异常: " ^ Printexc.to_string e); exit 1