
(* token debugger. i wanna use this. but later. *)
let () =
  let lexbuf = Lexing.from_channel (open_in "test2.txt") in
  let rec loop () =
    let tok = Lexer.token lexbuf in
    (match tok with
     | Parser.FUNCTION s -> Printf.printf "FUNCTION %S\n" s
     | Parser.SUBSCRIPT -> print_endline "SUBSCRIPT"
     | Parser.LEFT_CURLY_BRACE -> print_endline "LEFT_CURLY_BRACE"
     | Parser.RIGHT_CURLY_BRACE -> print_endline "RIGHT_CURLY_BRACE"
     | Parser.IDENT s -> Printf.printf "IDENT %S\n" s
     | Parser.EQUAL -> print_endline "EQUAL"
     | Parser.NUMBER s -> Printf.printf "NUMBER %S\n" s
     | Parser.SUPERSCRIPT_ONE s -> Printf.printf "SUPERSCRIPT_ONE %S\n" s
     | Parser.EOF -> print_endline "EOF"
     | Parser.OPERATOR_NAME -> print_endline "OPERATOR_NAME"
     | Parser.ACCESS_DOT -> print_endline "ACCESS_DOT"
     | _ -> print_endline "TLDR"
    );
    if tok <> Parser.EOF then loop ()
  in loop ()

let parse_input filename =
  let lexbuf = Lexing.from_channel (open_in filename) 
  in
  lexbuf.Lexing.lex_curr_p <- { lexbuf.Lexing.lex_curr_p with
    Lexing.pos_fname = filename
  };
  let res =
    try Parser.main Lexer.token lexbuf
    with
    | Parser.Error ->
        let pos = lexbuf.Lexing.lex_curr_p in
        let line = pos.Lexing.pos_lnum in
        let col  = pos.Lexing.pos_cnum - pos.Lexing.pos_bol in
        failwith (Printf.sprintf "%s:%d:%d: parse error" filename line col)
    | Failure msg ->
        let pos = lexbuf.Lexing.lex_curr_p in
        let line = pos.Lexing.pos_lnum in
        let col  = pos.Lexing.pos_cnum - pos.Lexing.pos_bol in
        failwith (Printf.sprintf "%s:%d:%d: lex error: %s" filename line col msg)
    in res

let pr = parse_input "./test2.txt"
let () = Ast.print_prog pr