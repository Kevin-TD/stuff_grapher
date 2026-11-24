{
    open Parser

    let greek : (string, unit) Hashtbl.t = Hashtbl.create 64
    let () =
      List.iter (fun g -> Hashtbl.replace greek g ())
        [ "alpha"; "beta"; "gamma"; "delta"; "epsilon"; "varepsilon"; "zeta";
          "eta"; "theta"; "vartheta"; "iota"; "kappa"; "lambda"; "mu"; "nu";
          "xi"; "omicron"; "pi"; "varpi"; "rho"; "varrho"; "sigma"; "varsigma";
          "tau"; "upsilon"; "phi"; "varphi"; "chi"; "psi"; "omega";
          "Gamma"; "Delta"; "Theta"; "Lambda"; "Xi"; "Pi"; "Sigma";
          "Upsilon"; "Phi"; "Psi"; "Omega" ]
}

rule token = parse
    | [' ' '\t'] { token lexbuf }
    | '#' [^ '\n']* '\n'  { Lexing.new_line lexbuf; token lexbuf }
    | '#' [^ '\n']* eof   { token lexbuf }
    | "\\quad" { token lexbuf }
    | '\n' { Lexing.new_line lexbuf; NEWLINE }
    | eof { EOF }
    | '=' { EQUAL }
    | '-' { MINUS }
    | '+' { PLUS }
    | '*' { MUL }
    | "\\cdot" { MUL }
    | '/' { DIV }
    | "\\left(" { LEFT_PAREN }
    | "\\right)" { RIGHT_PAREN }
    | '(' { LEFT_PAREN }
    | ')' { RIGHT_PAREN }
    | "\\left{" { LEFT_CURLY_BRACE }
    | "\\right}" { RIGHT_CURLY_BRACE }
    | '{' { LEFT_CURLY_BRACE }
    | '}' { RIGHT_CURLY_BRACE }
    | "\\left[" { LEFT_SQUARE_BRACKET }
    | "\\right]" { RIGHT_SQUARE_BRACKET }
    | '[' { LEFT_SQUARE_BRACKET }
    | ']' { RIGHT_SQUARE_BRACKET }
    | "\\rightarrow" { RIGHT_ARROW }
    | "\\leftarrow" { LEFT_ARROW }
    | "\\ne" { NE }
    | "\\neq" { NE }
    | "\\le" { LTE }
    | "\\ge" { GTE }
    | '^' ([^ '{'] as c) { SUPERSCRIPT_ONE (String.make 1 c) }
    | '^' { SUPERSCRIPT }
    | '<' { LT }
    | '>' { GT }
    | "<=" { LTE }
    | ">=" { GTE }
    | ':' { COLON }
    | ',' { COMMA }
    | '.' { ACCESS_DOT }
    | ['0'-'9']+ as r { NUMBER r }
    | ['0'-'9']+ '.'? ['0'-'9']+ as r { NUMBER r }
    | "\\operatorname" { OPERATOR_NAME }
    | "\\operatorname{if}" { IF }
    | "\\operatorname{then}" { THEN }
    | "\\operatorname{else}" { ELSE }
    | "\\operatorname{for}" { FOR }
    | "\\operatorname{when}" { WHEN }
    | "\\operatorname{let}" { LET }
    | "\\operatorname{in}" { IN }
    | "\\operatorname{fun}" { FUN }
    | ['A'-'Z' 'a'-'z'] ['A'-'Z' 'a'-'z' '0'-'9' '_']* as id { IDENT id }
    | '\\' (['A'-'Z' 'a'-'z']+ as g) '_' (['A'-'Z' 'a'-'z' '0'-'9']+ as s)
      { if Hashtbl.mem greek g then IDENT (g ^ "_" ^ s)
        else failwith ("unexpected subscript on \\" ^ g) }
    | '\\' (['A'-'Z' 'a'-'z']+ as g)
      { if Hashtbl.mem greek g then IDENT g else FUNCTION g }
    | "_" ([^ '{'] as c) { SUBSCRIPT_ONE (String.make 1 c) }
    | '_' { SUBSCRIPT }