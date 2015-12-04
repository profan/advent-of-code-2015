-module(four_one).

-export([find_hash/2]).

find_hashi(Key, <<0:20, _/bitstring>>, N) ->
	Key ++ integer_to_list(N);

find_hashi(Base, _, N) ->
	find_hashi(Base, erlang:md5(Base ++ integer_to_list(N+1)), N+1).

find_hash(Key, N) ->
	find_hashi(Key, erlang:md5(Key ++ integer_to_list(N)), N).
