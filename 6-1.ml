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
let process_lines input = List.iter (fun line -> Printf.printf "%s \n" line) input

let coords = PointSet.empty
let data = read_lines "6.input";;
process_lines data
