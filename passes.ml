open Ast

(** runs analyses/passes to enforce rules *)

type test_status =
    | Pass
    | Fail

let no_var_redef_check (env : environment) =
    let stat = ref Pass in
    let var_counts : ((string * int ref) list) ref = ref [] in
    List.iter 
    (fun (var_name, _) ->
        match List.find_opt (fun (v, _) -> v = var_name) !var_counts with
        | Some (_, c) -> c := !c + 1
        | None -> var_counts := (var_name, ref 1) :: !var_counts 
    ) env;
    List.iter 
    (fun (var_name, count) ->
        if !count > 1 then (
            print_endline ("Pass no_var_redef_check FAILED: var " ^ var_name ^ " defined in " ^ string_of_int (!count) ^ " places");
            stat := Fail;
        )
    ) !var_counts;
    !stat