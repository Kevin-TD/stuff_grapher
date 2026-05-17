open Interpreter
open Test_suite
open Debug_config

let filename = "./test/" ^ Sys.argv.(1) ^ ".sgl"

let () = if debug then run_tests ()

let _ =
    parse_file filename debug