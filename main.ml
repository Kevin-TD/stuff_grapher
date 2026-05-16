open Interpreter
open Ast
open Test_suite
open Debug_config

let filename = "./test/" ^ Sys.argv.(1) ^ ".d"

let () = if debug then run_tests ()

let main =
    parse_file filename debug