/*
  Introduction to AI - Winter 2026 - Assignment 2
  Team members (name, ID, tutorial):
    1. youssef hazem, 58-2769, 12
    2. monica victor, <ID>, <tutorial>
*/

% Switch KB by (un)commenting. Never copy KB facts into this file.
:- include('KB1.pl').
% :- include('KB2.pl').

/* =====================================================================
   SHARED CONTRACT  (both people code against these names; do not rename)
   ---------------------------------------------------------------------
   Situations:  s0  |  result(Action, S)      Actions: k(H,V) | b(H,V)

   FLUENTS (max 2 allowed):
     knight(X, Y, S)  : a knight stands on cell (X,Y) in situation S.
                        X = column in 1..W, Y = row in 1..H, S = situation.
     bishop(X, Y, S)  : a bishop stands on cell (X,Y) in situation S.
                        Same arguments as knight/3.

   HELPERS (no situation argument, pure geometry)          -> PERSON A
     inside(H, V)             : (H,V) lies on the grid.
     knight_move(A, B, H, V)  : knight can go (A,B) -> (H,V).
     bishop_move(A, B, H, V)  : bishop can go (A,B) -> (H,V), A,B =/= H,V.
     empty(H, V, S)           : no knight and no bishop on (H,V) in S.

   POSSIBILITY                                              -> PERSON A
     poss(Action, S) : Action can be done in S (piece of that type can
                       reach the cell, cell is inside the grid and empty).

   SITUATION CALCULUS                                       -> PERSON B
     knight/3 and bishop/3 : base case s0 (from knight_at/2, bishop_at/2)
                             + successor-state axioms for result(A,S).
     goal/3 and iterative deepening.
   ===================================================================== */

%% ---------------- PERSON A: movement rules ----------------
% TODO inside/2
% TODO knight_move/4
% TODO bishop_move/4
% TODO empty/3
% TODO poss/2


%% ---------------- PERSON B: situation calculus ----------------
% TODO knight/3 : base case + successor-state axiom
% TODO bishop/3 : base case + successor-state axiom
% TODO goal/3 + iterative deepening (call_with_depth_limit/3)


%% ---------------- TEMPORARY STUBS (delete once A's real poss/2 exists) ----
% Lets B test fluents before A finishes. Remove this line when merging.
% poss(_, _).