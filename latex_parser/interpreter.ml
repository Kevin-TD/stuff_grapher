type filename_or_string = FileName of string | String of string

let parse_input file_or_str =
  let (filename, lexbuf) = match file_or_str with
      | FileName s -> s, Lexing.from_channel (open_in s) 
      | String s -> "NA", Lexing.from_string s
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