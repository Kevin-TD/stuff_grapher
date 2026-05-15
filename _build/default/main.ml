open Printf
open Ast

let filename = "./test/" ^ Sys.argv.(1) ^ ".d"

(* im calling this "desmos clone" (dcl) *)
(* file type .d or whatever it doesnt really matter *)
(* its lowkey untyped *)

(* statements can be in any order! simply must define everything *)
(* TODO: disallow variable re-definitions? *)
(* TODO: error if a symbol is still unresolved after the resolver runs? *)

(* lazy function evaluation: eval functions only when called. dont worry about them at definition *)
(* TODO: testing global variables with function calls. or at least document it. how it works is that the function adds its own env to the
global env and whichever name appears first (which will be the function env) is selected  *)

(* undefs in list types will be tricky... *)
(* TODO: list indexing *)
(* TODO: testing suite *)

(* TODO: Fn should be of string list not expr list to make it clear its params *)
(* TODO: code cleanup LOL! *)
(* TODO: better errors *)

(* dcl lists will be 1-indexed *)


type environment = (string * expr) list

let lookup (var_name : string) (env : environment) = 
  match List.find_opt (fun (x, _) -> x = var_name) env with
  | Some (_, Unresolved _) | None -> None
  | Some (_, e) -> Some e

let bool_wrap (b : bool) = match b with
  | true -> True
  | false -> False

(* integer exponentiation *)
let rec pow a = function
  | 0 -> 1
  | 1 -> a
  | n -> 
    let b = pow a (n / 2) in
    b * b * (if n mod 2 = 0 then 1 else a)

let rec parse_prog (p : prog) (env : environment) = 
  match List.nth_opt p 0 with
  | Some e -> ( 
    match e with 
    | Assign (x, e) -> 
      parse_prog (List.tl p) ((x, parse_expr e env) :: env)
    | FunctionDef (name, params, body) -> 
      parse_prog (List.tl p) ((name, Fn (params, body)) :: env)
  )
  | None -> env

and parse_expr (ex : expr) (env : environment) = match ex with
  | Integer _ | Real _ as n -> n
  | True | False as b -> b
  | Ident x as id -> (match lookup x env with
    | Some e -> e
    | None -> Unresolved id
  )
  | Plus (e1, e2) as e -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> Integer (i1 + i2)
    | Integer i, Real r 
    | Real r, Integer i -> Real (r +. float_of_int i)
    | Real r1, Real r2 -> Real (r1 +. r2)
    | _ -> Unresolved e
  )
  | Minus (e1, e2) as e -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> Integer (i1 - i2)
    | Integer i, Real r -> Real (float_of_int i -. r)
    | Real r, Integer i -> Real (r -. float_of_int i)
    | Real r1, Real r2 -> Real (r1 -. r2)
    | _ -> Unresolved e
  )
  | Mult (e1, e2) as e -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> Integer (i1 * i2)
    | Integer i, Real r 
    | Real r, Integer i -> Real (r *. float_of_int i)
    | Real r1, Real r2 -> Real (r1 *. r2)
    | _ -> Unresolved e
  )
  | Div (e1, e2) as e -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> Integer (i1 / i2)
    | Integer i, Real r -> Real (float_of_int i /. r)
    | Real r, Integer i -> Real (r /. float_of_int i)
    | Real r1, Real r2 -> Real (r1 /. r2)
    | _ -> Unresolved e
  )
  | Exp (e1, e2) as e -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> Integer (pow i1 i2)
    | Integer i, Real r -> Real ((float_of_int i) ** r)
    | Real r, Integer i -> Real (r ** (float_of_int i))
    | Real r1, Real r2 -> Real (r1 +. r2)
    | _ -> Unresolved e
  )
  | Neg e -> (
    match parse_expr e env with
    | Integer i -> Integer (-1 * i)
    | Real r -> Real (-1. *. r)
    | _ -> Unresolved e
  )
  | Gt (e1, e2) as e -> (match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> bool_wrap (i1 > i2)
    | Integer i, Real r -> bool_wrap (float_of_int i > r)
    | Real r, Integer i -> bool_wrap (r > float_of_int i)
    | Real r1, Real r2 -> bool_wrap (r1 > r2)
    | _ -> Unresolved e
  )
  | Gte (e1, e2) as e -> (match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> bool_wrap (i1 >= i2)
    | Integer i, Real r -> bool_wrap (float_of_int i >= r)
    | Real r, Integer i -> bool_wrap (r >= float_of_int i)
    | Real r1, Real r2 -> bool_wrap (r1 >= r2)
    | _ -> Unresolved e
  )
  | Lt (e1, e2) as e -> (match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> bool_wrap (i1 < i2)
    | Integer i, Real r -> bool_wrap (float_of_int i < r)
    | Real r, Integer i -> bool_wrap (r < float_of_int i)
    | Real r1, Real r2 -> bool_wrap (r1 < r2)
    | _ -> Unresolved e
  )
  | Lte (e1, e2) as e -> (match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> bool_wrap (i1 <= i2)
    | Integer i, Real r -> bool_wrap (float_of_int i <= r)
    | Real r, Integer i -> bool_wrap (r <= float_of_int i)
    | Real r1, Real r2 -> bool_wrap (r1 <= r2)
    | _ -> Unresolved e
  )
  | Compare (t1, t2) as t -> (match parse_expr t1 env, parse_expr t2 env with
    | Unresolved _, _ | _, Unresolved _ -> Unresolved t
    | e1, e2 -> bool_wrap (e1 = e2)
  )
  | NotEqual (t1, t2) as t -> (match parse_expr t1 env, parse_expr t2 env with
    | Unresolved _, _ | _, Unresolved _ -> Unresolved t
    | e1, e2 -> bool_wrap (e1 <> e2)
  )
  | FunctionCall (name, args) as e -> (match lookup name env with
    | Some (Fn (params, body)) -> (
      if not (List.length args = List.length params) then
        failwith "mismatch b/w arglen and paramlen"
      else
        let fn_env = 
          List.mapi 
          (fun i e -> match e with 
            | Ident x -> 
              (x, parse_expr (List.nth args i) env)
            | _ -> failwith "fn params should all be ident"
          ) params
        in 
        let upd_env = fn_env @ env in
        let res = parse_expr body upd_env in
        res
    )
    | None -> Unresolved e
    | _ -> failwith "type-error functioncall idk yet."
  )
  | If_else (precond, true_branch, false_branch) as e -> (
    match parse_expr precond env with
    | True -> parse_expr true_branch env
    | False -> parse_expr false_branch env
    | Unresolved _ -> Unresolved e
    | _ -> failwith "precond should be bool type"
  )
  | ExprList l -> ExprList (List.map (fun e -> parse_expr e env) l)
  | _ as e -> failwith ("too lazy to parse " ^ string_of_expr e)

let rec find_undefs (e : expr) (env : environment) = match e with
  | Unresolved u -> find_undefs u env
  | Integer _ | Real _ | True | False -> []
  | Ident x -> if (lookup x env = None) then [x] else []
  | Plus (e1, e2) | Minus (e1, e2) | Mult (e1, e2) | Div (e1, e2) | Exp (e1, e2) 
  | Compare (e1, e2) | Gt (e1, e2) | Gte (e1, e2) | Lt (e1, e2)
  | Lte (e1, e2) | NotEqual (e1, e2)  -> (
    find_undefs e1 env @ find_undefs e2 env
  )
  | If_else (e1, e2, e3) ->
    find_undefs e1 env @ find_undefs e2 env @ find_undefs e3 env
  | Neg e -> find_undefs e env
  | ExprList l -> 
    List.fold_left (fun acc x -> acc @ find_undefs x env) [] l
  | FunctionCall (x, l) -> 
    find_undefs (ExprList l) env
  | _ -> failwith ("too lazy to find the undefs for " ^ string_of_expr e)

let rec resolve_all (env : environment) (idx : int) = 
  match List.nth_opt env idx with
  | Some (x, e) -> (match e with 
    | Unresolved v ->
      if find_undefs e env = [] then 
        let env = List.filter (fun (x', _) -> not (x = x')) env in
        resolve_all ((x, parse_expr v env) :: env) 0 
      else 
        resolve_all env (idx + 1)
    | _ -> resolve_all env (idx + 1)
  )
  | None -> env

let main =
  let inx = Core.In_channel.create filename in
  let lexbuf = Lexing.from_channel inx in
  let res =
    try Parser.main Lexer.token lexbuf
    with _ -> failwith "parsing error"
  in
   print_prog res;
   let env = List.rev (parse_prog res []) in
   let env = resolve_all env 0 in
   List.iter (fun (x, e) -> 
      print_endline (x ^ ": " ^ string_of_expr e); 
    ) env
