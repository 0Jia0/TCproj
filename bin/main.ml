(* open Toyc
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
  if Array.length Sys.argv != 2 then begin
prerr_endline "用法: toycproj <输入文件.tc>";
exit 1
  end;

  let input_file = Sys.argv.(1) in

  if not (Filename.check_suffix input_file ".tc") then begin
prerr_endline "错误: 输入文件必须是 .tc 扩展名";
exit 1
  end;

  try
let source = read_file input_file in
printf "[INFO] 成功读取文件: %s\n" input_file;

let lexbuf = Lexing.from_string source in
lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = input_file };

let ast = 
  try Parser.program Lexer.token lexbuf 
  with Parsing.Parse_error ->
    let pos = lexbuf.lex_curr_p in
    let char_pos = pos.pos_cnum - pos.pos_bol in
    
    (* 获取错误位置的上下文 *)
    let lines = String.split_on_char '\n' source in
    let error_line = if pos.pos_lnum <= List.length lines then
      List.nth lines (pos.pos_lnum - 1)
    else "无法获取错误行" in
    
    (* 打印详细错误信息 *)
    printf "=== 语法错误详情 ===\n";
    printf "文件: %s\n" pos.pos_fname;
    printf "行号: %d\n" pos.pos_lnum;
    printf "字符位置: %d\n" char_pos;
    printf "全局字符位置: %d\n" pos.pos_cnum;
    printf "错误行内容: %s\n" error_line;
    
    (* 显示错误位置的指示器 *)
    if char_pos > 0 && char_pos <= String.length error_line then (
      printf "错误位置: %s^\n" (String.make (char_pos - 1) ' ');
      printf "错误字符: '%c'\n" error_line.[char_pos - 1];
    );
    
    let msg = sprintf "语法错误在 %s:%d:%d" 
      pos.pos_fname pos.pos_lnum char_pos in
    failwith msg
in
printf "[INFO] 语法分析完成，生成AST\n";

(* 语义分析 *)
Semantic.check_program ast;
printf "[INFO] 语义分析完成，无错误\n";

(* 代码生成 *)
let output_file = (Filename.chop_suffix input_file ".tc") ^ ".s" in
let oc = open_out output_file in
Codegen.gen_program oc ast;
close_out oc;
printf "[SUCCESS] 编译成功! 输出文件: %s\n" output_file;

  with
  | Lexer.LexicalError msg -> 
    prerr_endline ("词法错误: " ^ msg); exit 1
  | Semantic.Semantic_error msg ->
    prerr_endline ("语义错误: " ^ msg); exit 1
  | Failure msg -> 
    prerr_endline ("错误: " ^ msg); exit 1
  | Sys_error msg -> 
    prerr_endline ("系统错误: " ^ msg); exit 1
  | e -> 
    prerr_endline ("未处理的异常: " ^ Printexc.to_string e); exit 1 *)

(*编译器主程序-希冀平台测试使用，标准输入输出代码*)
open Toyc
open Printf

let read_stdin () =
  let buf = Buffer.create 4096 in
  (try
    while true do
      Buffer.add_channel buf stdin 4096
    done
  with End_of_file -> ());
  Buffer.contents buf

let () =
  let enable_opt = ref false in
  let argc = Array.length Sys.argv in
  if argc > 2 then begin
    prerr_endline "用法: toycproj [-opt]";
    exit 1
  end;
  if argc = 2 then begin
    if Sys.argv.(1) = "-opt" then enable_opt := true
    else begin
      prerr_endline "未知参数";
      exit 1
    end
  end;

  try
    let source = read_stdin () in
    let lexbuf = Lexing.from_string source in
    lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = "" };

    let ast =
      try Parser.program Lexer.token lexbuf
      with Parsing.Parse_error ->
        let pos = lexbuf.lex_curr_p in
        let msg = sprintf "语法错误在 %d:%d"
            pos.pos_lnum (pos.pos_cnum - pos.pos_bol) in
        failwith msg
    in

    Semantic.check_program ast;

    (* 直接输出到 stdout *)
    Codegen.gen_program stdout ast;

  with
  | Lexer.LexicalError msg ->
    prerr_endline ("词法错误: " ^ msg); exit 1
  | Semantic.Semantic_error msg ->
    prerr_endline ("语义错误: " ^ msg); exit 1
  | Failure msg ->
    prerr_endline ("错误: " ^ msg); exit 1
  | Sys_error msg ->
    prerr_endline ("系统错误: " ^ msg); exit 1
  | e ->
    prerr_endline ("未处理的异常: " ^ Printexc.to_string e); exit 1