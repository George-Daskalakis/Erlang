-module(assessment1).
-export([pos_bids/1, success/2, pick/2, winners/2, mybidList/0, myboard2/0, myboard3/0, init/2, drop/2, subst/3, subst2/3, myboard/0, isxwin/1, linexwin/1, wincol/1]).

-type atoms() :: string().
-type int() :: integer().


-type bidlist() :: list({atoms(),int()}).
-spec mybidList() -> bidlist().
mybidList() -> [ {joe,1000}, {robert,3000}, {grace,1000}, {ada, 500} ].

%this return the list with only positive bids
pos_bids([]) -> []; 
pos_bids([{Person,Amount}|Xs]) when Amount >= 0 -> [{Person,Amount}] ++ pos_bids(Xs);
pos_bids([{_,_}|Xs]) -> pos_bids(Xs).

%returns true if the sum of the bids is greater than the threshhold
success(Bidlist, Threshhold) -> 
case (lists:sum(lists:map(fun({_, C}) -> C end, Bidlist)) >= Threshhold) of 
 true -> true;
 false -> false
end.


%Find the winners using recursive call
winnersRec([], _Threshhold) -> [];
winnersRec([{Person, Amount}|Xs], Threshhold) -> 
case (Amount >= Threshhold) of
true -> [{Person,Amount}];
false -> [{Person,Amount}] ++ winnersRec(Xs, Threshhold - Amount)
end.

%calls the winners recursive method removing any bids less than 0
winners(_Threshold,[]) -> [];
winners(Threshhold, Bids) -> winnersRec(pos_bids(Bids), Threshhold).

%checks if the first word is in the second
init(First, Second) -> 
case (string:sub_string(Second, 1, string:length(First)) == First) of
true -> true;
false -> false
end.

%drops the number of letters from a word 
drop(Number, Word) -> 
case (string:length(Word)< Number) of
true -> "";
false -> lists:sublist(Word, 1+Number, string:length(Word))
end.

%substitutes the occurence of the word Old in St with New 
subst(Old, New, St) -> 
case(init(Old, St) == true) of
true -> re:replace(St, Old, New,[{return,list}]);
false -> St
end.

%2d
subst2(_, _, []) -> [];
subst2(Old, New, [X | Xs]) ->
    case (init(Old, [X | Xs])) of
      true ->
      New ++ subst2(Old, New, drop(length(Old), [X | Xs]));
      false -> [X | subst2(Old, New, Xs)]
    end.

myboard() -> [[x,b,b],[x,x,x],[x,b,o]].

%Checks if x wins 
isxwin([X,B,A]) -> 
case ((X == B) andalso (B == A) andalso (X == x)) of
true -> true; 
false -> false
end. 

%Checks if the board has a line x winning
linexwin([]) -> false;
linexwin([X|Xs]) -> 
case (isxwin(X) == true) of
true -> true; 
false -> linexwin(Xs)
end. 

%picks the nth elemnt from a list
pick(N, [X|_]) when N == 0 -> X; 
pick(N, [_|Xs]) when N > 0 -> pick(N-1, Xs).

%checks every line to see if they are equal vertically or horizontally or diagonallyD
wincol([]) -> false;
wincol([[A,B,C],[D,E,F],[G,H,I]]) -> 
if  (A == D) andalso (D == G) -> true;
	(B == E) andalso (E == H) -> true;
	(C == F) andalso (F == I) -> true;
	true -> false
end. 

 

myboard2() -> [[x,o,b],[o,o,o],[x,o,o]].
myboard3() -> [[x,b,b],[o,x,o],[x,b,o]].


