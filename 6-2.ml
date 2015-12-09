#!/usr/bin/env ocamlscript
Ocaml.ocamlflags := ["-thread"];
Ocaml.packs := [ "core" ]
--

open Core.Std.In_channel

type point = int * int

module PointMap = Map.Make(
    struct
        let compare = Pervasives.compare
        type t = point
    end)

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
    let x_range = Core.Std.List.range x1 x2 ~start: `inclusive ~stop: `inclusive in
    List.flatten (List.map (fun x ->
        let y_range = Core.Std.List.range y1 y2 ~start: `inclusive ~stop: `inclusive in
        List.map (fun y -> (x, y)) y_range) x_range)

let change_value map key incr =
    let existing = try PointMap.find key map with Not_found -> 0 in
        begin match (existing, incr) with
        | (0, (-1)) -> map
        | (e, n) -> PointMap.add key (e + n) map
        end

let read_instructions tokens =
    List.fold_left (fun map x ->
        begin match x with
        | ("turn on", lower, upper) ->
            let path = walk_range lower upper in
                List.fold_left (fun acc x -> change_value acc x 1) map path
        | ("turn off", lower, upper) ->
            let path = walk_range lower upper in
                List.fold_left (fun acc x -> change_value acc x (-1)) map path
        | ("toggle", lower, upper) ->
            let path = walk_range lower upper in
                List.fold_left (fun acc x -> change_value acc x 2) map path
        | _ -> map
        end) PointMap.empty tokens

let total_brightness map = PointMap.fold (fun k v acc -> acc + v) map 0

(* begin the processings *)
let data = read_lines "6.input";;
let processed_data = tokenize_lines data;;
Printf.printf "Total Brightness: %d" (total_brightness (read_instructions processed_data))
