open Interpreter
open Ast
open Test_suite

let filename = "./test/" ^ Sys.argv.(1) ^ ".d"


let () = if debug_mode then run_tests ()

let main =
    let (prog, env) = parse_file filename in 
    print_prog prog;
    List.iter (fun (x, e) -> 
        print_endline (x ^ ": " ^ string_of_expr e); 
    ) env