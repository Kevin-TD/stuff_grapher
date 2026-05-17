open Interpreter
open Test_suite


let () = if Config.run_tests then run_tests ()

let _ =
    let filename = Config.test_dirname ^ Sys.argv.(1) ^ Config.file_ext in
    let _ = parse_file filename Config.emit_output in 
    ()