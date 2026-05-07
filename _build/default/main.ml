open Printf
open Ast
open Core

let filename = "./test/test2.d"
let ( = ) = Stdlib.(=)

(* statements can be in any order! simply must define everything *)
(* TODO: function calls and function defs *)
(* TODO: disallow variable re-definitions *)
(* TODO: error if a symbol is still unresolved after the resolver runs *)

type environment = (string * expr) list

let lookup_var (var_name : string) (env : environment) = 
  match List.find env ~f:(fun (x, _) -> String.equal x var_name) with
  | Some (_, Unresolved _) | None -> None
  | Some (_, e) -> Some e

let rec parse_prog (p : prog) (env : environment) = 
  match List.hd p with
  | Some e -> begin 
    match e with 
    | Assign (x, e) -> 
      parse_prog (List.tl_exn p) ((x, parse_expr e env) :: env)
    | FunctionDef (name, params, body) -> failwith "later"
  end
  | None -> env

and parse_expr (e : expr) (env : environment) = match e with
  | Number _ as n -> n
  | True | False as b -> b
  | Ident x as id -> (match lookup_var x env with
    | Some e -> e
    | None -> Unresolved id
  )
  | Plus (e1, e2) as e -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Number n1, Number n2 -> Number (n1 +. n2)
    | _ -> Unresolved e
  )
  | Minus (e1, e2) -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Number n1, Number n2 -> Number (n1 -. n2)
    | _ -> Unresolved e
  )
  | Mult (e1, e2) -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Number n1, Number n2 -> Number (n1 *. n2)
    | _ -> Unresolved e
  )
  | Div (e1, e2) -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Number n1, Number n2 -> Number (n1 /. n2)
    | _ -> Unresolved e
  )
  | Exp (e1, e2) -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Number n1, Number n2 -> Number (n1 ** n2)
    | _ -> Unresolved e
  )
  | Neg e -> (
    match parse_expr e env with
    | Number n -> Number (-1. *. n)
    | _ -> Unresolved e
  )
  | _ -> failwith "shh"

let rec find_undefs (e : expr) (env : environment) = match e with
  | Unresolved u -> find_undefs u env
  | Number _ | True | False -> []
  | Ident x -> if (lookup_var x env = None) then [x] else []
  | Plus (e1, e2) | Minus (e1, e2) | Mult (e1, e2) | Div (e1, e2) | Exp (e1, e2) -> (
    find_undefs e1 env @ find_undefs e2 env
  )
  | Neg e -> find_undefs e env
  | _ -> []

let rec resolve_all (env : environment) (idx : int) = 
  match List.nth env idx with
  | Some (x, e) -> (match e with 
    | Unresolved v -> 
      if find_undefs e env = [] then 
        let env = List.filter env ~f:(fun (x', e' ) -> not (x = x')) in
        resolve_all ((x, parse_expr v env) :: env) 0 
      else 
        resolve_all env (idx + 1)
    | _ -> resolve_all env (idx + 1)
  )
  | None -> env

let main =
  let inx = In_channel.create filename in
  let lexbuf = Lexing.from_channel inx in
  let res =
    try Parser.main Lexer.token lexbuf
    with _ -> failwith "parsing error"
  in
   print_prog res;
   let env = List.rev (parse_prog res []) in
   let env = resolve_all env 0 in
   List.iter env 
    ~f:(fun (x, e) -> 
      print_endline (x ^ ": " ^ string_of_expr e); 
    )
