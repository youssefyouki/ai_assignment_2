% Usage:  swipl -l chess_58-2769.pl tests.pl      then:   ?- run_kb1.   or   ?- run_kb2.
% Include the matching KB at the top of chess_58-2769.pl first!
% "find" tests: goal must succeed and the returned plan must verify when checked.
% "yes"/"no" tests: checking a given plan.

t_find(K,B)   :- ( goal(K,B,S), goal(K,B,S) -> format("PASS find ~w ~w -> ~w~n",[K,B,S]) ; format("FAIL find ~w ~w~n",[K,B]) ).
t_yes(K,B,S)  :- ( goal(K,B,S) -> format("PASS yes  ~w~n",[S]) ; format("FAIL yes  ~w~n",[S]) ).
t_no(K,B,S)   :- ( goal(K,B,S) -> format("FAIL no   ~w~n",[S]) ; format("PASS no   ~w~n",[S]) ).

run_kb1 :-
    t_find((4,3),(2,2)),
    t_find((3,4),(5,4)),
    t_yes((3,4),(4,4),result(k(3,4),result(k(4,2),result(k(2,1),result(b(4,4),s0))))),
    t_yes((4,3),(2,2),result(k(4,3),result(k(2,1),result(b(2,2),s0)))),
    t_no((4,3),(2,2),result(k(4,3),result(b(1,2),s0))),
    t_no((4,3),(2,2),result(k(2,5),result(b(2,2),s0))).

run_kb2 :-
    t_find((6,1),(3,3)),
    t_find((4,1),(3,2)),
    t_find((6,1),(3,2)),
    t_no((3,3),(3,3),_),
    t_no((6,1),(3,3),result(k(2,1),result(k(4,2),result(b(3,3),result(k(2,1),s0))))).
