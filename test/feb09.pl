nope:-conc([],[1],[]).
syntax:-conc([],[1],[]).

conc([],L2,L2).
conc([X|T],L2,[X|R]):-conc(T,L2,R).

zipper([],L2,L2).
zipper(L1,[],L1).
zipper([X|R1],[Y|R2],[X,Y|R]):-zipper(R1,R2,R).

pali([],[]).
pali([X|R],[X|S]):-pali(R,PR),conc(PR,[X],S).

split([],_,[],[]).
split([X|L],E,[X|K],G):-X =< E ,split(L,E,K,G).
split([X|L],E,K,[X|G]):-X > E ,split(L,E,K,G).

qs([],[]).
qs([E|R],S):-split(R,E,K,G),qs(K,SK),qs(G,GS),conc(SK,[E|GS],S).

rev([],[]).
rev([X|R],S):-rev(R,RR),conc(RR,[X],S).

aqs(X,Y):-qs(X,Z),rev(Z,Y).

halfen([],[],[]).
halfen([X],[X],[]). 
halfen([A,B|T],[A|R],[B|S]):-halfen(T,R,S).

merge(X,[],X).
merge([],X,X).
merge([A|R],[B|S],[B|T]):-A>B,merge([A|R],S,T).
merge([A|R],[B|S],[A|T]):-A=<B,merge(R,[B|S],T).

ms([],[]).
ms([X],[X]).
ms(L,S):-halfen(L,X,Y),ms(X,SX),ms(Y,SY),merge(SX,SY,S).

modify([],[]).
modify([X|T],L):-X mod 2 =:= 0,modify(T,L).
modify([X|T],[X|L]):-X mod 2 =:= 1,modify(T,L).

absolute([],[]).
absolute([X|R],[X|S]):-X >= 0,absolute(R,S).
absolute([X|R],[Y|S]):-X < 0,Y is -X,absolute(R,S).

count([],_,0).
count([A|T],E,N):-A > E,A < E*E,count(T,E,M),N is M+1.
count([A|T],E,N):-A =< E,count(T,E,N).
count([A|T],E,N):-A >= E*E,count(T,E,N).

cs09t12([],_,_,0).
cs09t12([H|T],D,E,N):-H>E,H=<(E+D),cs09t12(T,D,E,M),N is M+1.
cs09t12([_|T],D,E,N):-cs09t12(T,D,E,N).

cs09t09([],0).
cs09t09([X],X).
cs09t09([X,Y|R],N):-cs09t09(R,M), N is M+X-Y.
cs09t09(X, X).
