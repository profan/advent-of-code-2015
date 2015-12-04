-module(four_par).
-export([find_hash/2, test/0, run/0]).

-record(params, {base, n, zeroes}).

%% the hub which spawns processes and kills when one says they're completed
listener(CreatorPid, Params, Procs, Result) ->
	receive
		{start, N} ->
			StartProc = fun(P, PN) -> spawn(?MODULE, hash_process, [self(), P, PN]) end,
			NewProcs = [StartProc(Params#params{n = PN}, PN) || PN <- lists:seq(1, N-1)],
			listener(CreatorPid, Params, NewProcs, Result); %% just *assume* this is the first thing that happens, so no procs exist by now
		{ack, SenderPid} ->
			listener(CreatorPid, Params, [P || P <- Procs, P /= SenderPid], Result);
		{done, SenderPid, N} ->
			NewProcs = [P || P <- Procs, P = SenderPid],
			[Pid ! kill || Pid <- Procs], %% send kill to all others now
			NewRes = case {Result, N} of
				{unset, R} -> R;
				R when N > Result -> R;
				_ when N < Result -> Result
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
	after
		0 ->
			case find_par(Params) of
				N when is_number(N) ->
					OwnerPid ! {done, self(), N};
				no ->
					N = Params#params.n,
					hash_process(OwnerPid, Params#params{n = N + Step}, Step)
				end
	end.

find_par({Base, N, Zeroes}) ->
	Bits = Zeroes * 4,
	Hash = erlang:md5([Base | integer_to_list(N)]),
	case Hash of
		<<0:Bits, _/bitstring>> ->
			N;
		_ ->
			no
	end.

find_hash(Base, Zeroes) ->
	P = {Base, 0, Zeroes},
	L = spawn(?MODULE, listener, [self(), P, [], unset]),
	receive
		{result, ComputedResult} ->
			ComputedResult
	end.

test() ->
	609043 = find_hash("abcdef", 5),
	1048970 = find_hash("pqrstuv", 5).

run() ->
	{find_hash("bgvyzdsv", 5), find_hash("bgvyzdsv", 6)}.
