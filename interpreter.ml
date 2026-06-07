open Ast

(* this is for the Stuff Grapher (SG) project and its language, 
Stuff Grapher Language (SGL) *)
(* file extension .sgl *)
(* weakly typed *)
(* statements can be in any order *)
(* main difference, main reason why i made it, is cuz desmos doesnt allow
parameters to be functions. here, because everything is lazy, we can do that!
type checking isnt very strong but it allows me to easily implement that.  *)
(* additionally: *)
(* lists are 1-indexed *)

(* TODO: Fn should be of string list not expr list to make it clear its params *)
(* TODO: document sgl *)
(* TODO: error if infinite loop *)
(* TODO: rename parse_expr to eval_expr? *)
(* TODO: when building frontend, inverse trig functions should have sugar of sin^-1 and what not *)
(* TODO: fix resolve all so that we dont need both lookup_full and lookup *)
(* TODO: add factorial builtin *)
(* TODO: increase precision of nums? *)
(* TODO: improve errors for when externfn calls error  *)
(* TODO: points *)
(* TODO: sigma/sum, products *)
(* TODO: integrals, derivatives *)
(* TODO: consider removing ints and only use floats. list indexing will just floor the input *)
(* TODO: make it so it is valid to put a num right next to a expr so 3x would immediately parse as 3*x *)

(** allows unresolved types to return from lookup *)
let lookup_full (var_name : string) (env : environment) = 
  match List.find_opt (fun x -> x.name = var_name) env with
  | Some v -> Some v.value
  | None -> None

let lookup (var_name : string) (env : environment) = 
  match List.find_opt (fun x -> x.name = var_name) env with
  | None -> None
  | Some v -> (match v.value with
    | Unresolved _ -> None
    | _ -> Some v.value
  )

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
    | Assign (x, e, assign_pos) -> 
      let v = {name = x; line = Some assign_pos.line; value = parse_expr e env} in
      parse_prog (List.tl p) (v :: env)
  )
  | None -> env

and parse_expr (ex : expr) (env : environment) = 
  match ex with
  | Integer _ | Real _ as n -> n
  | True | False as b -> b
  | UndefinedError _ | IndexOutOfBoundsError _ 
  | FunctionCallError _ as err -> err
  | Unresolved _ as unres -> unres
  | Fn _ | ExternFn _ as f -> f
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
    | Unresolved _, _
    | _, Unresolved _ -> Unresolved e
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (e :: err)
    | _, _ -> UndefinedError [e]
  )
  | Minus (e1, e2) as e -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> Integer (i1 - i2)
    | Integer i, Real r -> Real (float_of_int i -. r)
    | Real r, Integer i -> Real (r -. float_of_int i)
    | Real r1, Real r2 -> Real (r1 -. r2)
    | Unresolved _, _
    | _, Unresolved _ -> Unresolved e
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (e :: err)
    | _, _ -> UndefinedError [e]
  )
  | Mult (e1, e2) as e -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> Integer (i1 * i2)
    | Integer i, Real r 
    | Real r, Integer i -> Real (r *. float_of_int i)
    | Real r1, Real r2 -> Real (r1 *. r2)
    | Unresolved _, _
    | _, Unresolved _ -> Unresolved e
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (e :: err)
    | _, _ -> UndefinedError [e]
  )
  | Div (e1, e2) as e -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> Real (float_of_int i1 /. float_of_int i2)
    | Integer i, Real r -> Real (float_of_int i /. r)
    | Real r, Integer i -> Real (r /. float_of_int i)
    | Real r1, Real r2 -> Real (r1 /. r2)
    | Unresolved _, _
    | _, Unresolved _ -> Unresolved e
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (e :: err)
    | _, _ -> UndefinedError [e]
  )
  | Exp (e1, e2) as e -> (
    match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> Integer (pow i1 i2)
    | Integer i, Real r -> Real ((float_of_int i) ** r)
    | Real r, Integer i -> Real (r ** (float_of_int i))
    | Real r1, Real r2 -> Real (r1 +. r2)
    | Unresolved _, _
    | _, Unresolved _ -> Unresolved e
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (e :: err)
    | _, _ -> UndefinedError [e]
  )
  | Neg ex as e -> (
    match parse_expr ex env with
    | Integer i -> Integer (-1 * i)
    | Real r -> Real (-1. *. r)
    | Unresolved _ -> Unresolved e
    | UndefinedError err -> UndefinedError (e :: err)
    | _ -> UndefinedError [e]
  )
  | Gt (e1, e2) as e -> (match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> bool_wrap (i1 > i2)
    | Integer i, Real r -> bool_wrap (float_of_int i > r)
    | Real r, Integer i -> bool_wrap (r > float_of_int i)
    | Real r1, Real r2 -> bool_wrap (r1 > r2)
    | Unresolved _, _
    | _, Unresolved _ -> Unresolved e
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (e :: err)
    | _, _ -> UndefinedError [e]
  )
  | Gte (e1, e2) as e -> (match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> bool_wrap (i1 >= i2)
    | Integer i, Real r -> bool_wrap (float_of_int i >= r)
    | Real r, Integer i -> bool_wrap (r >= float_of_int i)
    | Real r1, Real r2 -> bool_wrap (r1 >= r2)
    | Unresolved _, _
    | _, Unresolved _ -> Unresolved e
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (e :: err)
    | _, _ -> UndefinedError [e]
  )
  | Lt (e1, e2) as e -> (match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> bool_wrap (i1 < i2)
    | Integer i, Real r -> bool_wrap (float_of_int i < r)
    | Real r, Integer i -> bool_wrap (r < float_of_int i)
    | Real r1, Real r2 -> bool_wrap (r1 < r2)
    | Unresolved _, _
    | _, Unresolved _ -> Unresolved e
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (e :: err)
    | _, _ -> UndefinedError [e]
  )
  | Lte (e1, e2) as e -> (match parse_expr e1 env, parse_expr e2 env with
    | Integer i1, Integer i2 -> bool_wrap (i1 <= i2)
    | Integer i, Real r -> bool_wrap (float_of_int i <= r)
    | Real r, Integer i -> bool_wrap (r <= float_of_int i)
    | Real r1, Real r2 -> bool_wrap (r1 <= r2)
    | Unresolved _, _
    | _, Unresolved _ -> Unresolved e
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (e :: err)
    | _, _ -> UndefinedError [e]
  )
  | Compare (t1, t2) as t -> (match parse_expr t1 env, parse_expr t2 env with
    | Unresolved _, _ | _, Unresolved _ -> Unresolved t
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (t :: err)
    | e1, e2 -> bool_wrap (e1 = e2)
  )
  | NotEqual (t1, t2) as t -> (match parse_expr t1 env, parse_expr t2 env with
    | Unresolved _, _ | _, Unresolved _ -> Unresolved t
    | UndefinedError err, _
    | _, UndefinedError err -> UndefinedError (t :: err)
    | e1, e2 -> bool_wrap (e1 <> e2)
  )
  | FunctionCall (name, args) as ex -> (match lookup name env with
    | Some (Fn (params, body)) -> (
      if not (List.length args = List.length params) then
        FunctionCallError("mismatch b/w arglen and paramlen", ex)
      else
        let fn_env = 
          List.mapi 
          (fun i e -> match e with 
            | Ident x -> 
              {name = x; line = None; value = parse_expr (List.nth args i) env}
            (* TODO: handle the error better *)
            | _ -> failwith "fn params should all be ident"
          ) params
        in 
        let upd_env = fn_env @ env in
        let res = parse_expr body upd_env in
        res
    )
    | Some (ExternFn (arity, fn)) -> (
      if not (List.length args = arity) then
         FunctionCallError("mismatch b/w arglen and paramlen", ex)
      else
        let parsed_args = List.map (fun arg -> parse_expr arg env) args in 
        fn parsed_args
    )
    | None -> Unresolved ex
    | Some _ -> UndefinedError [ex]
  )
  | If_else (precond, true_branch, false_branch) as e -> (
    match parse_expr precond env with
    | True -> parse_expr true_branch env
    | False -> parse_expr false_branch env
    | Unresolved _ -> Unresolved e
    | UndefinedError err -> UndefinedError (e :: err)
    | _ -> UndefinedError [e]
  )
  | ExprList l -> 
    (* i will decide for now that an UndefinedError in one of the elements will NOT
     make the entire list an UndefinedError *)
    ExprList (List.map (fun e -> parse_expr e env) l)
  | IndexOf (e, idx) as t -> (match parse_expr e env, parse_expr idx env with
    | Unresolved _, _ | _, Unresolved _ -> Unresolved t
    | UndefinedError err, _ | _, UndefinedError err -> UndefinedError (t :: err)
    | ExprList l, Integer i -> (
      try (
        match List.nth_opt l (i - 1) with
        | Some e -> e
        | None -> IndexOutOfBoundsError t
      ) 
      with Invalid_argument _ -> UndefinedError [t]
    )
    | _ -> UndefinedError [t]
  )
  | ListComp (e, var_name, l) as t -> (match parse_expr l env with
    | ExprList l -> (
      let has_unresolved = ref false in
      let l_res = 
        List.init (List.length l) 
        (fun idx ->
          let cur_iter = List.nth l idx in
          let v = {name = var_name; line = None; value = cur_iter} in 
          let list_comp_env = v :: env in
          match parse_expr e list_comp_env with
          | Unresolved _ as u -> (
            has_unresolved := true;
            u
          )
          | _ as e -> e
        ) 
        in 
        if !has_unresolved then
          Unresolved t
        else
          ExprList l_res
    )
    | Unresolved _ -> Unresolved t
    | UndefinedError err -> UndefinedError (t :: err)
    | _ -> UndefinedError [t]
  ) 
  | ListCompFilter (e, filter, var_name, l) as t -> (match parse_expr l env with
    | ExprList l -> (
      let has_unresolved = ref false in
      let l_res = 
        List.init (List.length l) 
        (fun idx ->
          let cur_iter = List.nth l idx in
          let iter_var = {name = var_name; line = None; value = cur_iter} in
          let list_comp_env = iter_var :: env in
          let i_res = parse_expr e list_comp_env in
          let i_res_var = {name = var_name; line = None; value = i_res} in
          let i_res_env = i_res_var :: env in
          match (parse_expr filter i_res_env) with
            | True -> Some i_res
            | False -> None
            | Unresolved _ as u -> (
              has_unresolved := true;
              Some u
            )
            | UndefinedError _ as err -> Some err
            | _ as eval -> Some (UndefinedError [eval])
        )
        in 
        let l_res = List.filter (fun e -> e <> None) l_res in
        let l_res = List.map (fun e -> match e with Some e -> e | _ -> failwith "filtering somehow did not exclude all Nones") l_res in
        if !has_unresolved then
          Unresolved t
        else
          ExprList l_res
    )
    | Unresolved _ -> Unresolved t
    | UndefinedError err -> UndefinedError (t :: err)
    | _ -> UndefinedError [t]
  )
  | LetIn (s, e1, e2) as t -> (
    let e1' = parse_expr e1 env in
    match e1' with
    | Unresolved _ -> Unresolved t
    | UndefinedError err -> UndefinedError (t :: err)
    | _ -> (
      let let_env = {name = s; line = None; value = e1'} :: env in
      match parse_expr e2 let_env with
      | Unresolved _ -> Unresolved t
      | UndefinedError err -> UndefinedError (t :: err)
      | _ as res -> res
    )
  )

let rec find_unresolved (e : expr) (env : environment) = match e with
  | Unresolved u -> find_unresolved u env
  | Integer _ | Real _ | True | False | Fn _ | ExternFn _ 
  | UndefinedError _ | IndexOutOfBoundsError _ | FunctionCallError _ -> []
  | Ident x -> if (lookup x env = None) then [x] else []
  | Plus (e1, e2) | Minus (e1, e2) | Mult (e1, e2) | Div (e1, e2) | Exp (e1, e2) 
  | Compare (e1, e2) | Gt (e1, e2) | Gte (e1, e2) | Lt (e1, e2)
  | Lte (e1, e2) | NotEqual (e1, e2) | IndexOf (e1, e2)  -> (
    find_unresolved e1 env @ find_unresolved e2 env
  )
  | If_else (e1, e2, e3) ->
    find_unresolved e1 env @ find_unresolved e2 env @ find_unresolved e3 env
  | Neg e -> find_unresolved e env
  | ExprList l -> 
    List.fold_left (fun acc x -> acc @ find_unresolved x env) [] l
  | FunctionCall (s, l) -> 
    find_unresolved (Ident s) env @ find_unresolved (ExprList l) env
  | ListComp (e, var_name, l) ->
    let res = find_unresolved e env @ find_unresolved l env in
    let res = List.sort_uniq String.compare res in
    let res = List.filter (fun s -> not (s = var_name)) res in
    res
  | ListCompFilter (e, f, var_name, l) ->
    let res = find_unresolved e env @ find_unresolved f env @ find_unresolved l env in
    let res = List.filter (fun s -> not (s = var_name)) res in
    res
  | LetIn (_, e1, e2) -> 
    find_unresolved e1 env @ find_unresolved e2 env

let rec resolve_all (env : environment) (idx : int) = 
  match List.nth_opt env idx with
  | Some v -> (match v.value with 
    | Unresolved e ->
      if find_unresolved e env = [] then 
        let env = List.filter (fun v' -> not (v.name = v'.name)) env in
        resolve_all ({name = v.name; line = v.line; value = parse_expr e env} :: env) 0 
      else 
        resolve_all env (idx + 1)
    | ExprList lst as expr_lst -> 
      if find_unresolved expr_lst env = [] then (
        let lst = List.map (fun e -> match e with Unresolved e -> e | _ -> e) lst in
        let env = List.filter (fun v' -> not (v.name = v'.name)) env in
        resolve_all ({name = v.name; line = v.line; value = parse_expr (ExprList lst) env} :: env) (idx + 1)
      ) else 
        resolve_all env (idx + 1)
    | _ -> resolve_all env (idx + 1)
  )
  | None -> env

type filename_or_string = FileName of string | String of string

let parse_input file_or_str emit_output =
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
    in
    if emit_output then print_prog res;
    let env = List.rev (parse_prog res Builtins.env) in
    let env = resolve_all env 0 in
    if emit_output then 
      List.iter (fun v -> 
        if Builtins.name_is_taken v.name && not (Config.emit_builtins_in_env) then
          ()
        else
          print_endline (string_of_var v)) 
    env;
    Passes.run_passes env;
    (res, env)