(** loads in constants from constants.json. dune macro used to statically embed the constants *)

open Yojson.Safe.Util

let consts = Yojson.Safe.from_string [%blob "../core/constants.json"]

(** symbol to indicate that the result of the expression can be "discarded" (not assigned to a name) *)
let wildcard_var_symbol = consts |> member "wildcard_var_symbol" |> to_string

(** list of greek letter names to be auto-transformed into its symbol in the web frontend*)
let greek_symbols = consts |> member "greek_symbols" |> to_list |> List.map to_string

(** list of operators in SGL that should be treated as an operator (non-italics) in the web frontend *)
let auto_operator_names = consts |> member "auto_operator_names" |> to_list |> List.map to_string

(** list of names to exclude from being treated as a standard operator name *)
let exclude_names = consts |> member "exclude_names" |> to_list |> List.map to_string

(** list of special functions that the latex frontend should automatically treat as operators *)
let auto_operator_functions = consts |> member "auto_operator_functions" |> to_list |> List.map to_string