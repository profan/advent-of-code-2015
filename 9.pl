#!/usr/bin/swipl -f -q

:- initialization main.

path_cost(_, [], Cost, Cost).

path_cost(LastPlace, [P|Places], CostSoFar, Cost) :-
	path(LastPlace, P, PathCost),
	NewCost is CostSoFar + PathCost,
	path_cost(P, Places, NewCost, Cost).

path_cost([P|Places], Cost) :- path_cost(P, Places, 0, Cost).

find_path(Pred, Places, FoundDist) :-
	findall(Perm, permutation(Places, Perm), Possible),
	get_path(Pred, Possible, FoundDist).

max_cost(P, MaxSoFar, Max) :- path_cost(P, PathCost), Max is max(MaxSoFar, PathCost).
min_cost(P, MinSoFar, Min) :- path_cost(P, PathCost), Min is min(MinSoFar, PathCost).
get_path(Pred, [P|Paths], Dist) :- path_cost(P, PathCost), foldl(Pred, Paths, PathCost, Dist).

main :-
	consult('9-data.pl'),
	Path = [tristram, alphacentauri, snowdin, tambi, faerun, norrath, straylight, arbre],
	find_path(min_cost, Path, MinDist),
	format('Part 1: Shortest Distance: ~w \n', [MinDist]),
	find_path(max_cost, Path, MaxDist),
	format('Part 2: Longest Distance: ~w', [MaxDist]),
	halt(0).
