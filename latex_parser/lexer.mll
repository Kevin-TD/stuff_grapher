{
    open Parser
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
    | "\\operatorname" { OPERATOR_NAME }
    | "\\operatorname{if}" { IF }
    | "\\operatorname{then}" { THEN }
    | "\\operatorname{else}" { ELSE }
    | "\\cdot" { MUL }
    | "\\left(" { LEFT_PAREN }
    | "\\right)" { RIGHT_PAREN }
    | "\\left{" { LEFT_CURLY_BRACE }
    | "\\right}" { RIGHT_CURLY_BRACE }
    | '{' { LEFT_CURLY_BRACE }
    | '}' { RIGHT_CURLY_BRACE }
    | "\\left[" { LEFT_SQUARE_BRACKET }
    | "\\right]" { RIGHT_SQUARE_BRACKET }
    | "\\rightarrow" { RIGHT_ARROW }
    | "\\leftarrow" { LEFT_ARROW }
    | "\\ne" { NE }
    | '^' ([^ '{'] as c) { SUPERSCRIPT_ONE (String.make 1 c) }
    | '^' { SUPERSCRIPT }
    | '<' { LT }
    | '>' { GT }
    | "<=" { LTE }
    | ">=" { GTE }
    | ':' { COLON }
    | ',' { COMMA }
    | '.' { ACCESS_DOT }
    | ['0'-'9']+ as r (* i am STILL lazy *)
    { NUMBER r  }
    | ['0'-'9']+ '.'? ['0'-'9']+ as r
        { NUMBER r}
    | ['A'-'Z' 'a'-'z'] ['A'-'Z' 'a'-'z' '0'-'9' '_']* as id
    { IDENT id }
    | '\\' (['A'-'Z' 'a'-'z'] ['A'-'Z' 'a'-'z' '0'-'9']* as id) { FUNCTION id }
    | "_" ([^ '{'] as c) { SUBSCRIPT_ONE (String.make 1 c)}
    | '_' { SUBSCRIPT }

