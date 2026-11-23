/*
  Introduction to AI - Winter 2026 - Assignment 2
  Team members (name, ID, tutorial):
    1. <name>, <ID>, <tutorial>
    2. <name>, <ID>, <tutorial>
*/

% Switch KB by (un)commenting. Never copy KB facts into this file.
:- include('KB1.pl').
%:- include('KB2.pl').

/* =====================================================================
   SHARED CONTRACT  (UPDATED - see note on the fluent below)
   ---------------------------------------------------------------------
   Situations:  s0  |  result(Action, S)      Actions: k(H,V) | b(H,V)
   Cells are (Column,Row), Column in 1..W, Row in 1..H.

   FLUENT (we use ONE fluent; the limit is two):
     pieces(Ks, Bs, S)
        Ks : list of the cells (X,Y) holding a KNIGHT in situation S.
        Bs : list of the cells (X,Y) holding a BISHOP in situation S.
        S  : situation, s0 or result(Action, S0).
     Why one list-valued fluent: an action k(H,V) does not say WHICH knight
     moves. The mover is chosen inside the successor-state axiom, together
     with the poss check, from ONE evaluation of the previous situation.
     Separate fluents knight(X,Y,S)/bishop(X,Y,S) are each evaluated
     independently, so they could pick different movers for the same
     action and give an inconsistent board.

   PERSON A (pure movement rules, no situations):
     inside(H,V)             : (H,V) is on the grid.
     knight_move(A,B,H,V)    : knight can go (A,B) -> (H,V). Must also work
                               when H,V are unbound (generate the moves).
     bishop_move(A,B,H,V)    : bishop diagonal move, same requirement.
     free(H,V,Ks,Bs)         : (H,V) holds no knight and no bishop.

   PERSON B (situation calculus): pieces/3, poss/4, goal/3 + iterative
   deepening.
   ===================================================================== */

%% ================= PERSON A: movement rules (TEMPORARY STAND-INS) =========
/* inside(H,V): the cell (H,V) is on the board.
   H is the column (1..W) and V is the row (1..H); grid(W,Hg) comes from
   the knowledge base. If H and V are unbound, this lists every cell. */
inside(H, V) :-
    grid(W, Hg),
    between(1, W, H),
    between(1, Hg, V).

/* knight_move(A,B,H,V): a knight on (A,B) can jump to (H,V).
   A knight moves in an L-shape: 2 cells in one direction and 1 cell
   sideways. That gives 8 possible jumps, written as (change in column
   - change in row). If H,V are known this checks the jump; if they are
   unbound it generates all 8 destinations. It does NOT check the board
   edges: poss/4 calls inside/2 for that. */
knight_move(A, B, H, V) :-
    member(DX-DY, [1-2, 2-1, 2-(-1), 1-(-2),
                   (-1)-(-2), (-2)-(-1), (-2)-1, (-1)-2]),
    H is A + DX,
    V is B + DY.

/* bishop_move(A,B,H,V): a bishop on (A,B) can go to (H,V).
   A bishop moves diagonally by any distance, and other pieces never block
   it (only the destination must be empty, which free/4 checks).

   Clause 1 (destination known): it is a diagonal move when the distance
   across equals the distance up/down, and the bishop really moves
   (H differs from A). The cut stops Prolog from trying clause 2.

   Clause 2 (destination unknown): generate every diagonal cell by trying
   each distance D and each of the 4 diagonal directions. Cells outside
   the board are removed later by inside/2. */
bishop_move(A, B, H, V) :-
    nonvar(H), nonvar(V), !,
    H =\= A,
    abs(H - A) =:= abs(V - B).
bishop_move(A, B, H, V) :-
    grid(W, Hg),
    N is max(W, Hg) - 1,
    between(1, N, D),
    member(SX, [1, -1]),
    member(SY, [1, -1]),
    H is A + SX * D,
    V is B + SY * D.

/* free(H,V,Ks,Bs): cell (H,V) is empty. Ks is the list of knight cells
   and Bs the list of bishop cells, so the cell must be in neither list.
   This is what enforces "no captures and no two pieces on one cell". */
free(H, V, Ks, Bs) :-
    \+ memberchk((H,V), Ks),
    \+ memberchk((H,V), Bs).

%% ================= PERSON B: situation calculus ===========================

/* ---- poss(Action, Ks, Bs, Rest) -----------------------------------------
   Action is possible in a situation whose knights are Ks and bishops Bs.
     - the destination (H,V) is inside the grid,
     - it is empty (no captures, no two pieces on a cell),
     - some piece of the right type can reach it with a legal move.
   Rest is the list of that type's pieces LEFT BEHIND, i.e. the pieces other
   than the one that moved. select/3 backtracks over every candidate mover,
   so every legal choice of mover is explored.
   The mover is picked first so knight_move/bishop_move can GENERATE the
   destinations when the action is not yet known (planning mode).
   Bishops are never blocked on the way; only the destination matters. */
poss(k(H,V), Ks, Bs, Rest) :-
    select((P,Q), Ks, Rest),
    knight_move(P, Q, H, V),
    inside(H, V),
    free(H, V, Ks, Bs).
poss(b(H,V), Ks, Bs, Rest) :-
    select((P,Q), Bs, Rest),
    bishop_move(P, Q, H, V),
    inside(H, V),
    free(H, V, Ks, Bs).

/* ---- Fluent pieces(Ks, Bs, S) and its successor-state axioms -------------
   Initial situation: read from the KB. */
pieces(Ks, Bs, s0) :-
    findall((X,Y), knight_at(X,Y), Ks),
    findall((X,Y), bishop_at(X,Y), Bs).

/* Successor-state axiom, action k(H,V) (knight moves to (H,V)):
     knights after = (H,V)  [made true by the action]
                     + every knight that was there before and did not move
                       (the mover is the one removed by poss/4);
     bishops after = bishops before                 [frame: untouched]. */
pieces(Ks, Bs, result(k(H,V), S)) :-
    pieces(Ks0, Bs, S),
    poss(k(H,V), Ks0, Bs, Rest),
    Ks = [(H,V)|Rest].

/* Successor-state axiom, action b(H,V) (bishop moves to (H,V)):
     bishops after = (H,V) + every bishop that did not move;
     knights after = knights before                 [frame: untouched]. */
pieces(Ks, Bs, result(b(H,V), S)) :-
    pieces(Ks, Bs0, S),
    poss(b(H,V), Ks, Bs0, Rest),
    Bs = [(H,V)|Rest].

/* ---- goal/3 ---------------------------------------------------------------
   goal((KX,KY),(BX,BY),S): in situation S some knight is on (KX,KY) and
   some bishop is on (BX,BY).
   - S given (a full plan): just CHECK it, no search (so wrong plans fail
     finitely instead of looping).
   - S unbound: FIND a plan with iterative deepening.                      */
goal(K, B, S) :-
    ground(S), !,
    holds(K, B, S).
goal(K, B, S) :-
    achievable(K, B),
    ids(K, B, S).

holds(K, B, S) :-
    pieces(Ks, Bs, S),
    memberchk(K, Ks),
    memberchk(B, Bs).

/* Cheap impossibility tests so that unreachable goals fail instead of
   deepening forever: both cells on the grid, different cells, and a bishop
   never changes square colour, so some bishop must start on the target's
   colour. */
achievable((KX,KY), (BX,BY)) :-
    inside(KX, KY),
    inside(BX, BY),
    (KX,KY) \== (BX,BY),
    bishop_at(X, Y),
    (X + Y) mod 2 =:= (BX + BY) mod 2, !.

/* Iterative deepening on the NUMBER OF MOVES: try plans of 0 moves, then 1,
   then 2, ... Each round builds an unbound plan skeleton of exactly N moves
   (plan_shape/2) and lets pieces/3 fill in the actions. Every round is
   finite, so Prolog's depth-first search cannot run away, and the first plan
   found is a shortest one. (call_with_depth_limit/3 bounds call-stack depth,
   not move count, which returned longer plans first, so it is not used.) */
ids(K, B, S) :-
    between(0, inf, N),
    plan_shape(N, S),
    holds(K, B, S).

% plan_shape(N, S): S = result(_, result(_, ... s0)) with N unbound actions.
plan_shape(0, s0).
plan_shape(N, result(_, S)) :-
    N > 0,
    N1 is N - 1,
    plan_shape(N1, S).