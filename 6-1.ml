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
    end)

let to_num_t x y = (int_of_string x, int_of_string y)

let tokenize str = 
    let tokens = Core.Core_string.split_on_chars ~on: [' '; ','] str in
        begin match tokens with
        | cmd::switch::x1::y1::any::x2::y2::rest -> (cmd ^ " " ^ switch, to_num_t x1 y1, to_num_t x2 y2)
        | cmd::x1::y1::any::x2::y2::rest -> (cmd, to_num_t x1 y1, to_num_t x2 y2)
        | _ -> ("", (0, 0), (0, 0))
        end

let tokenize_lines input = List.map (fun line -> tokenize line) input

let walk_range (x1, y1) (x2, y2) =
    let x_range = Core.Std.List.range x1 x2 ~start: `inclusive ~stop: `inclusive in
    List.flatten (List.map (fun x ->
        let y_range = Core.Std.List.range y1 y2 ~start: `inclusive ~stop: `inclusive in
        List.map (fun y -> (x, y)) y_range) x_range)

let read_instructions tokens =
    List.fold_left (fun acc x ->
        begin match x with
        | ("turn on", lower, upper) ->
            let path = walk_range lower upper in
                List.fold_left (fun acc x -> PointSet.add x acc) acc path
        | ("turn off", lower, upper) ->
            let path = walk_range lower upper in
                List.fold_left (fun acc x -> PointSet.remove x acc) acc path
        | ("toggle", lower, upper) ->
            let path = walk_range lower upper in
                List.fold_left (fun acc x -> 
                    let existence = PointSet.mem x acc in
                        begin match existence with
                        | true -> PointSet.remove x acc
                        | false -> PointSet.add x acc
                        end) acc path
        | _ -> acc
        end) PointSet.empty tokens

(* begin the processings *)
let data = read_lines "6.input";;
let processed_data = tokenize_lines data;;
Printf.printf "Lit lights: %d" (PointSet.cardinal (read_instructions processed_data))
