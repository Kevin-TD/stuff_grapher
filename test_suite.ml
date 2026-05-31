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
    ExprList (List.init (y - x + 1) (fun i -> Integer (x + i)))

let int_lst_to_expr_lst (lst : int list) =
    ExprList (List.map (fun i -> Integer i) lst)

let tests = [
    {
        name = "add";
        env_to_satisfy = [
            ("x", "x not equal to int 1", fun e -> e = Integer 1);
            ("y", "y not equal to int 5", fun e -> e = Integer 5);
            ("z", "z not equal to int 6", fun e -> e = Integer 6);
        ]
    };
    {
        name = "swap_order";
        env_to_satisfy = [
            ("w1", "w1 not (roughly) equal to real num 9.209", real_eq_expr 9.209);
            ("w", "w != Int 7", fun e -> e = Integer 7);
            ("z", "z != Int 4", fun e -> e = Integer 4);
            ("y", "y != Int 3", fun e -> e = Integer 3);
            ("x", "x != Int 1", fun e -> e = Integer 1);
            ("h", "h != Int 1", fun e -> e = Integer 1);
        ]
    };
    {
        name = "fun_call";
        env_to_satisfy = [
            ("j1", "j1 != Int 11", fun e -> e = Integer 11);
            ("j2", "j2 != Int 47", fun e -> e = Integer 47)
        ]
    };
    {
        name = "bools_and_conds";
        env_to_satisfy = [
            ("z3", "z3 != False", fun e -> e = False);
            ("z2", "z2 != True", fun e -> e = True);
            ("x", "x != True", fun e -> e = True);
            ("y", "y != Int 1", fun e -> e = Integer 1);
            ("z1", "z1 != True", fun e -> e = True);
            ("e2", "e2 != Int 1", fun e -> e = Integer 1);
            ("h", "h != False", fun e -> e = False);
            ("i1", "i1 != Int 6", fun e -> e = Integer 6);
            ("i2", "i2 != Int 5", fun e -> e = Integer 5);
            ("k1", "k1 != Int 2", fun e -> e = Integer 2);
            ("k2", "k2 != Int 3", fun e -> e = Integer 3);
            ("k3", "k3 != Int 4", fun e -> e = Integer 4);
            ("k4", "k4 != Int 5", fun e -> e = Integer 5)
        ]
    };
    {
        name = "list_and_indexing";
        env_to_satisfy = [
            ("a", "a != [5, 6, 3]", 
                fun e -> e = ExprList ([Integer 5; Integer 6; Integer 3]);
            );
            ("b1", "b1 != 5", fun e -> e = Integer 5);
            ("b2", "b2 != 6", fun e -> e = Integer 6);
            ("b3", "b3 != 3", fun e -> e = Integer 3);
            ("b4", "b4 != 6", fun e -> e = Integer 6)
        ]
    };
    {
        name = "factorial";
        env_to_satisfy = [
            ("x", "x != Int 120", fun e -> e = Integer 120)
        ]
    };
    {
        name = "anon_funcs";
        env_to_satisfy = [
            ("x1", "x1 != Int 8", fun e -> e = Integer 8);
            ("b1", "b1 != Int 3", fun e -> e = Integer 3);
            ("k1", "k1 != Int 3", fun e -> e = Integer 3);
            ("kk1", "kk1 != Int 2", fun e -> e = Integer 2)
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
            ("h", "h != -5", fun e -> e = Integer (-5))
        ]
    };
    {
        name = "range";
        env_to_satisfy = [
            ("x", "x != [1...10]", fun e -> e = make_range 1 10);
            ("y", "y != [-5...10]", fun e -> e = make_range (-5) 10);
            ("z", "z != [1]", fun e -> e = ExprList [Integer(1)]);
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
            ("j9", "j9 != Int(2)", fun e -> e = Integer 2);
            ("j10", "j10 != pi", real_eq_expr Builtins.pi_const);
        ]
    };
    {
        name = "list_comp";
        env_to_satisfy = [
            ("z", "z != 10", fun e -> e = Integer 10);
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
            ("y", "y != 1", fun e -> e = Integer 1);
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
            ("r", "r != 5", fun e -> e = Integer 5)
        ]
    }
]

let do_test (t : test) =
    let (_, result_env) = parse_input (FileName (Config.env_test_dirname ^ t.name ^ Config.file_ext)) Config.emit_test_eval_output in
    List.iter 
    (fun (x, if_err, cond_to_satsify) -> match lookup x result_env with
        | Some result_expr -> 
            if cond_to_satsify result_expr then ()
            else print_endline 
            ("FAIL: test " ^ t.name ^ ". var " ^ x ^ " received value " ^ string_of_expr result_expr ^ ", but unsatisfied due to: " ^ if_err)
        | None -> print_endline ("FAIL: test " ^ t.name ^ " failed. " ^ x ^ " not found")
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