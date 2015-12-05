-module(four_par).
-export([sfind_hash/2, tc_hash/2, find_hash/2, listener/4, hash_process/3, test/0, run/0]).

-record(params, {base, n, zeroes}).

%% the hub which spawns processes and kills when one says they're completed
listener(CreatorPid, Params, Procs, Result) ->
	receive
		{start, N} ->
			StartProc = fun(P, PN) -> spawn(?MODULE, hash_process, [self(), P, PN]) end,
			NewProcs = [StartProc(Params#params{n = PN-1}, PN) || PN <- lists:seq(1, N-1)],
			listener(CreatorPid, Params, NewProcs, Result); %% just *assume* this is the first thing that happens, so no procs exist by now
		{ack, SenderPid} ->
			listener(CreatorPid, Params, [P || P <- Procs, P /= SenderPid], Result);
		{done, SenderPid, N} ->
			NewProcs = [P || P <- Procs, P /= SenderPid],
			[Pid ! kill || Pid <- NewProcs], %% send kill to all others now
			NewRes = case {Result, N} of
				{unset, R} -> R;
				{_, R} when N > Result -> R;
				{_, R} when N < Result -> Result
			end,
			case NewProcs of
				[] ->
					CreatorPid ! {result, NewRes};
				A -> %% still got me some array left, loop-de-loop
					listener(CreatorPid, Params, NewProcs, NewRes)
			end
	end.

hash_process(OwnerPid, Params, Step) ->
	receive
		kill -> 
			OwnerPid ! {ack, self()},
			exit(kill)
	after 0 ->
		case find_par(Params) of
			N when is_number(N) ->
				OwnerPid ! {done, self(), N};
			no ->
				N = Params#params.n,
				hash_process(OwnerPid, Params#params{n = N + Step}, Step)
			end
	end.

find_par({params, Base, N, Zeroes}) ->
	Bits = Zeroes * 4,
	Hash = erlang:md5([Base | integer_to_list(N)]),
	case Hash of
		<<0:Bits, _/bitstring>> ->
			N;
		_ ->
			no
	end.

find_hash(Base, Zeroes) ->
	P = #params{base = Base, n = 0, zeroes = Zeroes},
	L = spawn(?MODULE, listener, [self(), P, [], unset]),
	L ! {start, 8},
	receive
		{result, ComputedResult} ->
			ComputedResult
	end.

tc_hash(Base, Zeroes) ->
	{Us, Return} = timer:tc(fun() -> find_hash(Base, Zeroes) end),
	io:format("took: ~p microseconds, result: ~p \n", [Us, Return]).

sfind_hash(Base, Zeroes) ->
	spawn(?MODULE, tc_hash, [Base, Zeroes]).

test() ->
	609043 = find_hash("abcdef", 5),
	1048970 = find_hash("pqrstuv", 5).

run() ->
	{find_hash("bgvyzdsv", 5), find_hash("bgvyzdsv", 6)}.
