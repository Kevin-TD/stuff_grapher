(* TODO: write tests. just make sure it runs! *)
let pr = Interpreter.parse_input (FileName "./test/gamma.txt")
let () = Ast.print_prog pr