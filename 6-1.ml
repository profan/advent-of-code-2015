#!/usr/bin/env ocamlscript
Ocaml.ocamlflags := ["-thread"];
Ocaml.packs := [ "core" ]
--

open Core.Std.In_channel

type point = int * int

module PointSet = Set.Make(
    struct
        let compare = Pervasives.compare
        type t = point
    end
)

let read file = read_lines file
let print_set s = PointSet.iter (fun (x, y) -> Printf.printf "(%d, %d)" x y) s

let tokenize str = 
    let tokens = Core.Core_string.split_on_chars ~on: [' '; ','] str in
        begin match tokens with
        | a::b::c::d::e::f::g::rest -> (a ^ b, (int_of_string c, int_of_string d), (int_of_string f, int_of_string g))
        | a::c::d::e::f::g::rest -> (a, (int_of_string c, int_of_string d), (int_of_string f, int_of_string g))
        | [] -> ("", (0, 0), (0, 0))
        | _ -> ("", (0, 0), (0, 0))
        end

let read_instructions tokens =
    begin match tokens with
    | "turn on"::lower::upper::rest -> "Turn On!"
    | "turn off"::lower::upper::rest -> "Turn Off!"
    | "toggle"::lower::upper::rest -> "Toggle!"
    | [] -> "Nay!"
    | _ -> "Aww!"
    end

let process_lines input = List.map (fun line -> tokenize line) input

let coords = PointSet.empty
let data = read_lines "6.input";;
let processed_data = process_lines data;;

Printf.printf "%s" (read_instructions processed_data)
