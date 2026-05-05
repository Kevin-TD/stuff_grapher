
module MenhirBasics = struct
  
  exception Error
  
  let _eRR =
    fun _s ->
      raise Error
  
  type token = 
    | NUMBER of 
# 6 "parser.mly"
       (float)
# 15 "parser.ml"
  
    | NEWLINE
    | IDENT of 
# 5 "parser.mly"
       (string)
# 21 "parser.ml"
  
    | EQUAL
    | EOF
  
end

include MenhirBasics

# 1 "parser.mly"
  
open Ast

# 34 "parser.ml"

type ('s, 'r) _menhir_state = 
  | MenhirState00 : ('s, _menhir_box_main) _menhir_state
    (** State 00.
        Stack shape : <empty>.
        Start symbol: main. *)

  | MenhirState07 : (('s, _menhir_box_main) _menhir_cell1_stmt, _menhir_box_main) _menhir_state
    (** State 07.
        Stack shape : stmt.
        Start symbol: main. *)


and ('s, 'r) _menhir_cell1_stmt = 
  | MenhirCell1_stmt of 's * ('s, 'r) _menhir_state * (Ast.stmt)

and _menhir_box_main = 
  | MenhirBox_main of (Ast.prog) [@@unboxed]

let _menhir_action_1 =
  fun s ->
    (
# 17 "parser.mly"
                  ( s )
# 59 "parser.ml"
     : (Ast.prog))

let _menhir_action_2 =
  fun id n ->
    (
# 26 "parser.mly"
      ( Assign (id, Number n) )
# 67 "parser.ml"
     : (Ast.stmt))

let _menhir_action_3 =
  fun () ->
    (
# 20 "parser.mly"
                ( [] )
# 75 "parser.ml"
     : (Ast.prog))

let _menhir_action_4 =
  fun rest s ->
    (
# 21 "parser.mly"
                                  ( s :: rest )
# 83 "parser.ml"
     : (Ast.prog))

let _menhir_action_5 =
  fun s ->
    (
# 22 "parser.mly"
                 ( [s] )
# 91 "parser.ml"
     : (Ast.prog))

let _menhir_print_token : token -> string =
  fun _tok ->
    match _tok with
    | NUMBER _ ->
        "NUMBER"
    | NEWLINE ->
        "NEWLINE"
    | IDENT _ ->
        "IDENT"
    | EQUAL ->
        "EQUAL"
    | EOF ->
        "EOF"

let _menhir_fail : unit -> 'a =
  fun () ->
    Printf.eprintf "Internal failure -- please contact the parser generator's developers.\n%!";
    assert false

include struct
  
  [@@@ocaml.warning "-4-37"]
  
  let _menhir_run_04 : type  ttv_stack. ttv_stack -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _v _tok ->
      match (_tok : MenhirBasics.token) with
      | EOF ->
          let s = _v in
          let _v = _menhir_action_1 s in
          MenhirBox_main _v
      | _ ->
          _eRR ()
  
  let rec _menhir_run_08 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_stmt -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _v _tok ->
      let MenhirCell1_stmt (_menhir_stack, _menhir_s, s) = _menhir_stack in
      let rest = _v in
      let _v = _menhir_action_4 rest s in
      _menhir_goto_stmts _menhir_stack _v _menhir_s _tok
  
  and _menhir_goto_stmts : type  ttv_stack. ttv_stack -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState00 ->
          _menhir_run_04 _menhir_stack _v _tok
      | MenhirState07 ->
          _menhir_run_08 _menhir_stack _v _tok
  
  let rec _menhir_run_01 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | EQUAL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NUMBER _v_0 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let (n, id) = (_v_0, _v) in
              let _v = _menhir_action_2 id n in
              (match (_tok : MenhirBasics.token) with
              | NEWLINE ->
                  let _menhir_stack = MenhirCell1_stmt (_menhir_stack, _menhir_s, _v) in
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  (match (_tok : MenhirBasics.token) with
                  | IDENT _v_0 ->
                      _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v_0 MenhirState07
                  | EOF ->
                      let _v_1 = _menhir_action_3 () in
                      _menhir_run_08 _menhir_stack _v_1 _tok
                  | _ ->
                      _eRR ())
              | EOF ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let s = _v in
                  let _v = _menhir_action_5 s in
                  _menhir_goto_stmts _menhir_stack _v _menhir_s _tok
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  let _menhir_run_00 : type  ttv_stack. ttv_stack -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | IDENT _v ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState00
      | EOF ->
          let _v = _menhir_action_3 () in
          _menhir_run_04 _menhir_stack _v _tok
      | _ ->
          _eRR ()
  
end

let main =
  fun _menhir_lexer _menhir_lexbuf ->
    let _menhir_stack = () in
    let MenhirBox_main v = _menhir_run_00 _menhir_stack _menhir_lexbuf _menhir_lexer in
    v
