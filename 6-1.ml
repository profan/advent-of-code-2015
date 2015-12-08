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
        | a::b::c::d::e::f::g::rest -> (a ^ " " ^ b, (int_of_string c, int_of_string d), (int_of_string f, int_of_string g))
        | a::c::d::e::f::g::rest -> (a, (int_of_string c, int_of_string d), (int_of_string f, int_of_string g))
        | [] -> ("", (0, 0), (0, 0))
        | _ -> ("", (0, 0), (0, 0))
        end

let tokenize_lines input = List.map (fun line -> tokenize line) input

let walk_range (x1, y1) (x2, y2) =
    let x_range = Core.Std.List.range x1 x2 in
    List.flatten [List.map (fun x ->
        let y_range = Core.Std.List.range y1 y2 in
        List.map (fun y -> (x, y)) y_range) x_range]

let read_instructions tokens =
    List.fold_left (fun acc x ->
        begin match x with
        | ("turn on", lower, upper) ->
            let path = walk_range lower upper in
                List.fold_left PointSet.add acc path
        | ("turn off", lower, upper) ->
            let path = walk_range lower upper in
                List.fold_left PointSet.remove acc path
        | ("toggle", lower, upper) ->
            let path = walk_range lower upper in
                List.fold_left (fun acc x -> 
                    let existence = PointSet.exists x acc in
                        begin match existence with
                        | true -> PointSet.remove x acc
                        | false -> PointSet.add x acc
                        end) acc path
        | _ -> acc
        end) PointSet.empty tokens

let data = read_lines "6.input";;
let processed_data = tokenize_lines data;;

read_instructions processed_data
