open Interpreter
open Ast

let is_unresolved = function
    | Unresolved _ -> true
    | _ -> false

let is_resolved e = not (is_unresolved e)

(** var [v : string] in an environemnt must satsify some specification [s : expr -> bool]. [if_err : string] is emitted if it is not satisfied, so   
[env_to_satisfy : (v * if_err * s) list] *)
type test = {
    name: string;
    env_to_satisfy: (string * string * (expr -> bool)) list
}

(** checks if real nums [r] and [v] are equal by seeing if their difference [ |r - v| ] is no more than [ 10e-3 ]  *)
let real_eq (r : float) (v : float) =
    let epsilon = 10e-3 in
    let diff = r -. v in
    -1. *. epsilon <= diff && diff <= epsilon

let real_eq_expr (v : float) (e : expr) = 
    match e with
    | Real r -> real_eq r v
    | _ -> false

let make_range x y = 
    List.init (y - x + 1) (fun i -> float_of_int (x + i))

let int_lst_to_expr_lst (lst : int list) =
    ExprList (List.map (fun i -> Real (float_of_int i)) lst)

let expr_lst_to_reals (e_lst : expr list) = 
    let reals = List.filter (fun ex -> match ex with 
        | Real _ -> true
        | _ -> false)
    e_lst in
    List.map (fun ex -> match ex with
        | Real r -> r
        | _ -> failwith "impossible error unwrapping reals") 
    reals

let rec float_lst_eqs fl1 fl2 = match fl1, fl2 with
    | [], [] -> true
    | [], _ -> false
    | _, [] -> false
    | (h1 :: t1), (h2 :: t2) -> real_eq h1 h2 && float_lst_eqs t1 t2

let ex_eq_reals fl e = match e with
    | ExprList l -> float_lst_eqs fl (expr_lst_to_reals l)
    | _ -> false

let eq_reals (fl : float list) (e : expr) =
    match e with
    | ExprList l -> fl = expr_lst_to_reals l
    | _ -> false

let tests = [
    {
        name = "add";
        env_to_satisfy = [
            ("x", "x != 1", real_eq_expr 1.);
            ("y", "y != 5", real_eq_expr 5.);
            ("z", "z != 6", real_eq_expr 6.);
        ]
    };
    {
        name = "swap_order";
        env_to_satisfy = [
            ("w1", "w1 != 23.1177", real_eq_expr 23.1177);
            ("w", "w != 7", real_eq_expr 7.);
            ("z", "z != 4", real_eq_expr 4.);
            ("y", "y != 3", real_eq_expr 3.);
            ("x", "x != 1", real_eq_expr 1.);
            ("h", "h != 1", real_eq_expr 1.);
        ]
    };
    {
        name = "fun_call";
        env_to_satisfy = [
            ("j1", "j1 != Int 11", real_eq_expr 11.);
            ("j2", "j2 != Int 47", real_eq_expr 47.)
        ]
    };
    {
        name = "bools_and_conds";
        env_to_satisfy = [
            ("z3", "z3 != False", fun e -> e = False);
            ("z2", "z2 != True", fun e -> e = True);
            ("x", "x != True", fun e -> e = True);
            ("y", "y != Int 1", real_eq_expr 1.);
            ("z1", "z1 != True", fun e -> e = True);
            ("e2", "e2 != Int 1", real_eq_expr 1.);
            ("h", "h != False", fun e -> e = False);
            ("i1", "i1 != Int 6", real_eq_expr 6.);
            ("i2", "i2 != Int 5", real_eq_expr 5.);
            ("k1", "k1 != Int 2", real_eq_expr 2.);
            ("k2", "k2 != Int 3", real_eq_expr 3.);
            ("k3", "k3 != Int 4", real_eq_expr 4.);
            ("k4", "k4 != Int 5", real_eq_expr 5.)
        ]
    };
    {
        name = "list_and_indexing";
        env_to_satisfy = [
            ("a", "a != [5, 6, 3]", 
                ex_eq_reals [5.; 6.; 3.];
            );
            ("b1", "b1 != 5", real_eq_expr 5.);
            ("b2", "b2 != 6", real_eq_expr 6.);
            ("b3", "b3 != 3", real_eq_expr 3.);
            ("b4", "b4 != 6", real_eq_expr 6.)
        ]
    };
    {
        name = "factorial";
        env_to_satisfy = [
            ("x", "x != Int 120", real_eq_expr 120.)
        ]
    };
    {
        name = "anon_funcs";
        env_to_satisfy = [
            ("x1", "x1 != Int 8", real_eq_expr 8.);
            ("b1", "b1 != Int 3", real_eq_expr 3.);
            ("k1", "k1 != Int 3", real_eq_expr 3.);
            ("kk1", "kk1 != Int 2", real_eq_expr 2.)
        ]
    };
    {
        name = "partial_app";
        env_to_satisfy = [
            ("h1", "h1 != -9.4", fun e -> match e with
            | Real r -> real_eq r (-9.4)
            | _ -> false)
        ]
    };
    {
        name = "neg_swap";
        env_to_satisfy = [
            ("h", "h != -5", real_eq_expr (-5.))
        ]
    };
    {
        name = "range";
        env_to_satisfy = [
            ("x", "x != [1...10]", ex_eq_reals (make_range 1 10));
            ("y", "y != [-5...10]", ex_eq_reals (make_range (-5) 10));
            ("z", "z != [1]", ex_eq_reals [1.]);
            ("z1", "z1 != []", fun e -> e = ExprList [])
        ]
    };
    {
        name = "builtins";
        env_to_satisfy = [
            ("j1", "j1 != e", real_eq_expr Builtins.e_const);
            ("j2", "j2 != sqrt(e)", real_eq_expr (sqrt Builtins.e_const));
            ("j3", "j3 != e", real_eq_expr Builtins.e_const);
            ("j4", "j4 != 0", real_eq_expr 0.);
            ("j5", "j5 != 1", real_eq_expr 1.);
            ("j6", "j6 != sqrt(3)/2", real_eq_expr (sqrt(3.) /. 2.));
            ("j7", "j7 != sqrt(2)/2", real_eq_expr (sqrt(2.) /. 2.));
            ("j8", "j8 != sin(1)", real_eq_expr (sin (1.)));
            ("j9", "j9 != Int(2)", real_eq_expr 2.);
            ("j10", "j10 != pi", real_eq_expr Builtins.pi_const);
        ]
    };
    {
        name = "list_comp";
        env_to_satisfy = [
            ("z", "z != 10", real_eq_expr 10.);
            ("a1", "a1 != [6...15]", fun e -> e = int_lst_to_expr_lst [6;7;8;9;10;11;12;13;14;15]);
            ("a2", "a2 != [11...20]", fun e -> e = int_lst_to_expr_lst [11;12;13;14;15;16;17;18;19;20]);
            ("a3", "a3 != [1...4]", fun e -> e = int_lst_to_expr_lst [1;2;3;4]);
            ("a4", "a4 != [10]", fun e -> e = int_lst_to_expr_lst [10]);
            ("a5", "a5 != [2,4,6,8,10]", fun e -> e = int_lst_to_expr_lst [2;4;6;8;10]);
            ("a6", "a6 != [0,2,4,...,20]", fun e -> e = int_lst_to_expr_lst [0;2;4;6;8;10;12;14;16;18;20])
        ]
    };
    {
        name = "comp_and_eq";
        env_to_satisfy = [
            ("y", "y != 1", real_eq_expr 1.);
            ("a1", "a1 != [5]", fun e -> e = int_lst_to_expr_lst [5]);
            ("a2", "a2 != [6...15]", fun e -> e = int_lst_to_expr_lst [6;7;8;9;10;11;12;13;14;15])
        ]
    };
    {
        name = "list_comp_find_unres";
        env_to_satisfy = [
            ("_1", "code @ line 1 != [10]", fun e -> e = int_lst_to_expr_lst [10]);
            ("_2", "code @ line 2 != [11...20]", fun e -> e = int_lst_to_expr_lst [11;12;13;14;15;16;17;18;19;20])
        ]
    };
    {
        name = "fun_param";
        env_to_satisfy = [
            ("r", "r != 5", real_eq_expr 5.)
        ]
    };
    {
        name = "let_in";
        env_to_satisfy = [
            ("x", "x != 6", real_eq_expr 6.);
            ("a1", "a1 != 6", real_eq_expr 6.);
            ("a2", "a2 != 7", real_eq_expr 7.);
            ("a3", "a3 != 3", real_eq_expr 3.);
            ("a4", "a4 != 1", real_eq_expr 1.);
            ("a5", "a5 != 0", real_eq_expr 0.);
        ]
    };
    {
        name = "tuple2d";
        env_to_satisfy = [
            ("v1", "v1 != 1", real_eq_expr 1.);
            ("v2", "v2 != 2", real_eq_expr 2.);
            ("v3", "v3 != 20", real_eq_expr 20.);
            ("v4", "v4 != 0", real_eq_expr 0.);
            ("v5", "v5 != 1", real_eq_expr 1.);
            ("v6", "v6 != 32", real_eq_expr 32.);
        ]
    }
]

let do_test (t : test) =
    let (_, result_env) = parse_input (FileName (Config.env_test_dirname ^ t.name ^ Config.file_ext)) Config.emit_test_eval_output in
    let test_filename = Config.env_test_dirname ^ t.name ^ Config.file_ext in
    List.iter
    (fun (x, if_err, cond_to_satsify) -> match lookup x result_env with
        | Some result_expr -> 
            if cond_to_satsify result_expr then ()
            else print_endline 
            ("FAIL " ^ test_filename ^ ": var " ^ x ^ " received value " ^ string_of_expr result_expr ^ ", but unsatisfied due to: " ^ if_err)
        | None -> print_endline ("FAIL " ^ test_filename ^ ": " ^ x ^ " not found")
    ) 
    t.env_to_satisfy

let warn_if_not_tested (ts : test list) =
    let test_filenames = Sys.readdir Config.env_test_dirname in
    Array.iter 
        (fun filename -> 
            if not (List.exists (fun {name; _} -> filename = name ^ Config.file_ext) ts) then
                print_endline ("WARNING: file " ^ Config.env_test_dirname ^ filename ^ " does not have a test")
        )
    test_filenames
    
let run_tests () =
    List.iter do_test tests;
    warn_if_not_tested tests