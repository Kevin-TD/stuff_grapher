let () = if Config.run_tests then Test_suite.run_tests ()

let _ =
    let test_specified = Sys.argv.(1) in
    let test_file = Sys.argv.(2) in
    let filename = "test/" ^ test_specified ^ "/" ^ test_file ^ Config.file_ext in
    let _ = Interpreter.parse_file filename Config.emit_output in 
    ()