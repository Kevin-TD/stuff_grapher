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
    in
    print_endline "todo";
    