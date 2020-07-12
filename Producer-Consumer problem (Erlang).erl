-module(gd309).
-export([consumer/3, logger/1, buffer/1, buffer/4, main/0]).

logger(Count) ->
    receive {data, Msg} ->
        io:fwrite("Got ~w~n", [Count] ++ Msg)
    end,
    logger(Count+1).

consumer(Count, Logger, Buffer) ->
Buffer!{isEmptyQ ,self()} ,
receive 
	empty -> 
		Logger!"C: Buffer empty. I wait.", wait,
			receive notEmpty -> Logger!"C: Buffer not empty. I get the message.",
			consumerGo(Count, Logger, Buffer)
			end;
	notEmpty -> Logger!"P: Buffer not empty. I get the message.", consumerGo(Count, Logger, Buffer)
end,
consumer(Count, Logger, Buffer).

consumerGo(Count, Logger, Buffer) -> 
Buffer!{getData, self()},
receive  
{data, Msg} -> Logger!("C: Got data: #" ++ integer_to_list(Count) ++ "=" ++ Msg)
end,
consumer(Count+1, Logger, Buffer).


buffer(MaxSize) ->
buffer([], MaxSize, none, none).
buffer(BufferData, MaxSize, WaitingConsumer, WaitingProducer) ->
    case (WaitingProducer =/= none) of
        true -> WaitingProducer ! notFull;
        false -> nothing
    end,
    receive 
        {isFullQ, Pid} ->
            case length(BufferData) >= MaxSize of
                true ->
                    Pid!full,
                    buffer(BufferData, MaxSize, none, Pid);
                false ->
                    Pid!notFull
            end;
        {isEmptyQ, Cid} ->
            case length(BufferData) > 0 of
                true ->
                    Cid!notEmpty,
                    buffer(BufferData, MaxSize, none, none);
                false ->
                    Cid!empty,
                    buffer(BufferData, MaxSize, Cid, WaitingProducer)
            end;
        {data, Msg} ->
            NewBufferData  = [Msg | BufferData],
            case WaitingConsumer =:= none of
                true -> buffer(NewBufferData, MaxSize, none, none);
                false -> WaitingConsumer!notEmpty,
                buffer(NewBufferData , MaxSize, none, none)
            end;
        {getData, Cid} ->
            if length(BufferData) =:= 0 ->
                buffer(BufferData, MaxSize, none, WaitingProducer);
                true ->
                    [X | _] = BufferData,
                    Cid!{data, X},
                    NewBufferData  = lists:delete(X, BufferData),
                    buffer(NewBufferData , MaxSize, none, WaitingProducer)
            end
    end,
    buffer(BufferData, MaxSize, WaitingConsumer, WaitingProducer).
		
	
	main() ->
    Logger = spawn(gd309, logger, [0]),
    Buffer = spawn(gd309, buffer, [5]),
    spawn(producer, producer, [5, Logger, Buffer]),
    spawn(gd309, consumer, [1, Logger, Buffer]).
