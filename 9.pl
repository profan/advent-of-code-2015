#!/usr/bin/swipl -f -q

:- initialization main.

path(london, dublin, 464).
path(london, belfast, 518).
path(dublin, belfast, 141).

path(dublin, london, 464).
path(belfast, london, 518).
path(belfast, dublin, 141).

path_cost(_, [], Cost, Cost).

path_cost(LastPlace, [P|Places], CostSoFar, Cost) :-
	path(LastPlace, P, PathCost),
	NewCost is CostSoFar + PathCost,
	path_cost(P, Places, NewCost, Cost).

path_cost([P|Places], Cost) :-
	path_cost(P, Places, 0, Cost).

find_shortest_path(Places, FoundDist) :-
	findall(Perm, permutation(Places, Perm), Possible),
	min_path(Possible, FoundDist).

min_cost(P, MinSoFar, Min) :- 
	path_cost(P, PathCost),
	Min is min(MinSoFar, PathCost).

min_path([P|Paths], MinDist) :-
	path_cost(P, PathCost),
	foldl(min_cost, Paths, PathCost, MinDist).

main :-
	find_shortest_path([dublin, london, belfast], Distance),
	format('Shortest Distance: ~w', [Distance]),
	halt(0).
