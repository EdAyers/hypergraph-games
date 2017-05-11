# Hypergraph Games

Read _Combinatorial Games_ by  Beck.

A __hypergraph game__ is a set $X$ of _positions_ (finite unless otherwise stated) and a hypergraph $H \subseteq \mathcal{P} X$. Recall that a hypergraph is just a set of subsets of vertices, we call it a hypergraph because we are more interested in questions with analogues in graph theory. We also demand that $H$ is $n$-uniform. This means that each $A \in H$ has cardinality $n$. The $H$ are called the __winning lines__ of the game.

In a play of the __game on $H$__, two players P1 and P2 take it in turns to paint an $x\in X$ their colour. The first to completely colour all the vertices of an $A \in H$ wins the game. The game is classed as a draw if at the 'end of time' neither player has managed to do so.

__Example:__ Naughts and Crosses

Write $[n]$ to mean the set $\{1, 2, \cdots , n\}$ (not zero indexed!).

Take $X$ to be $[3]^2$ and $H$ to consist of all the vertical, horizontal and diagonal lines of length $3$. 
Giving the classic 'naughts and crosses'.

To generalise:

A __combinatorial line__ in $[n]^d$ is a set of the form 

$\{ (x_1,\cdots, x_d) : (\forall i,j \in I. x_i = x_j ) \wedge (\forall i \notin I. x_i = a_i ) \}$

for some non-empty $I\subseteq [d]$ and fixed values $a_i \in X$. 

A __line__ is a set of the form 

$\{ (x_1, \cdots , x_d) : (\forall i,j \in I. x_i = x_j ) \wedge (\forall i,j \in J. x_i = x_j ) \wedge (\forall i \in I. \forall j \in J. x_i = n + 1 - x_j) \wedge (\forall i \notin I \cup J. x_i = a_i) \}$

for some $I, J \subseteq [d]$ where at least one is non-empty and $a_i \in X$.

Some combinatorial lines in $[4]^3$:

$\{(x,x,4) : x \in [4]\}$

$\{(3,x,2) : x \in [4]\}$

Some lines in $[4]^3$:

$\{ (x, 5 - x, 1) : x \in [4] \}$

$\{ (x, x, 5 - x) : x \in [4] \}$

__Example:__ Ramsey game

Take $N \geq S$. The $(K_N,K_S)$ __Ramsey game__ is played with $X$ being the set of unordered pairs in $[N]^2$. That is, the edges of $[N]$. $H$ is the set of all full subgraphs of $X$ with $k$ vertices. Players take turns to colour in edges.

<div>
<script type="text/javascript" src="ramsey.js"></script>
<div style="float:left; width: 33%">
<div id="ramLeft"></div>
<script type="text/javascript">
  var hexDiv = document.getElementById("ramLeft");
  Elm.Ramsey.embed(hexDiv, {n:4, s:3});
</script>
</div>
<div style="float: center; width: 33%">
<div id="ramCenter"></div>
<script type="text/javascript">
  var hexDiv = document.getElementById("ramCenter");
  Elm.Ramsey.embed(hexDiv, {n:5, s:3});
</script>
</div>
<div style="float : right; width: 33%">
<div id="ramRight"></div>
<script type="text/javascript">
  var hexDiv = document.getElementById("ramRight");
  Elm.Ramsey.embed(hexDiv, {n:6, s:4});
</script>
</div>
</div>

__Example:__ Binary tree game

$X$ is a binary tree of depth $n$. Winning lines are just paths from root to leaf. A good example of an obvious winning strategy.

## Winning strategies

Every position in a game has a __value__ obtained by backtracking from a winning position.

If the position contains a winning line for P1, then it's value is __winning__.
If it's P1's turn and there exists a move which leads to a winning value position, then the current position is winning too.
If it's P2's turn and all moves lead to a winning position, then the value is winning too.
Repeat the analysis, swapping P1 for P2 and 'winning' for '__losing__'.
Otherwise, we say the position is __drawing__.

We say P1 __has a winning strategy__ if the start position is winning

For any game, we can prove that exactly one of the following holds:

i) P1 has a winning strategy
ii) P2 has a winning strategy (that is, the starting position is losing)
iii) Each player has a drawing strategy. 

This follows immediately for finite $X$, since we may assign a value to each state, working backwards from maximally coloured positions.

### Infinite $X$

The classic example of this the __unrestricted $n$-in-a-row game__. $X = \mathbb{Z}^2$ and $H$ contains all horizontal, vertical and diagonal $n$-lines.

The above winning strategy lemma still holds if all the members of $H$ are finite. That is, for the above example, $n$ is finite.

To prove this, it's enough to show that if P1 has no winning strategy then P2 must have a strategy to ensure P1 doesn't win. Suppose the premiss is true, then after P1's move, there exists a reply from P2 which leads to a position that is drawing or losing.
So at the next time step, P1 is still not winning. So at no time can P1 cover a winning $A \in H$, and since all the $A$ have finitely many elements, P1 never wins, so P2 has a strategy to thwart P1.

#### Lecture 2

##Strategy Stealing

__Proposition 1:__ A hypergraph game is never winning for P2. 

__Proof:__ Suppose P2 has a winning strategy. Here is the strategy for P1; 'pretend' to play nowhere, and then use P2's strategy for the remaining moves.
That is, play some $x$ and then play P2's strategy with colours reversed as if $x$ has not been played. If the strategy makes him play $x$, play anywhere, call it $x_2$. This works because a winning position is still winning if you add an extra square. This is a contrapositive proof, so it doesn't prove P1 always wins.

The same proof applies if $X$ is infinite.

Alternatively, if a draw is impossible, then P1 always wins. Strategy stealing applies in any situation where the game is symmetric for both players and "playing an extra square can't hurt you". 

Here are some examples which are _not_ hypergraph games, because $H$ is different for each player.

**Hex:** Play on a finite triangular grid and take turns picking vertices and the first person to make a path across from one side to another wins. P1 tries to get from top to bottom, P2 left to right. People play tournaments of this.

<div style="text-align: center; margin-left: auto; margin-right: auto; width: 50%">
<script type="text/javascript" src="hex.js"></script>
<div id="hex"></div>
<script type="text/javascript">
  var hexDiv = document.getElementById("hex");
  Elm.Hex.embed(hexDiv);
</script>
</div>

**Exercise:** Prove that Hex can't end in a draw.

**Bridge-it:** Have two offset, overlayed square grids A,B. P1 can join adjacent points on grid A. P2 on grid B. First to make a path from top-bottom or left-right wins. Lines can't cross.

Which of our games so far are P1 wins?

__Ramsey game:__ 
Take the game $(K_N, K_S)$. 
Ramsey's theorem states that, for $N$ large enough, a 2-coloured graph with vertices on N always contains a monocromatic subgraph of shape $S$. It follows immediately that the game can't end in a draw for some sufficiently large $N$.

The Ramsey number is the least such $N$. Known that $\sqrt{2^S} \leq R(S) \leq 4^S$. Hence we have a P1 winning if $4^S \leq N$. But these are non-constructive.

Let's look at some explicit winning strategies.

When $S = 3$, $N > 4$, we can win by creating a double-pronged threat. 

Sketch out the move tree!!

Can guarantee a win in 4 moves.

### $S = 4$

No strategies are known. There are some purported strategies.
It's hard because you can't just make immediate threats. You have to move in such a way that you make threats faster than your opponent can close them up.

### Binary tree game

Recall that there is an easy strategy for P1 regardless of the tree size.

### $[n]^d$ game

Hales - Jennet theoerm states: If $[n]^d$ is 2-coloured, then for $d$ large enough there is a monochromatic line. (And in fact, a combinatorial line)
The least such $d$ is denoted $HJ(n)$. Thus, if $d$ is above this, it's a player 1 win.
Unfortunately, the best known bound on $HJ$ is quite big. Shelah showed $HJ(n) \leq f_4(n + 4)$ where

$$f_0(n) := 2n$$

$$f_{j+1}(0):= 1$$

$$f_{j+1}(n + 1) := f_{j}(f_{j+1}(n))$$

This sequence of $f_j$ is called the __Ackermann Hierarchy__.

Warning; adding a new winning line may change the game from being a P1 draw to a win and vice versa. This is called non-monotonicity.

Exercise ; find an example? the example Imre gave was shot down.

## The disjoint union of two games

Have games $G$, $H$. If each draws separately, then the disj-union game must also draw. Follows from the 'extra moves can't hurt you' principle.
If $G$ wins and $H$ draws, then $G \sqcup H$ is a P1 win. I think P2 can sometimes force a draw if $H$ is infinite.
If $G$, $H$ are both wins, what is $G \sqcup H$?


#### Lecture 3

## $n \times n$ Naughts and Crosses is always a draw

$[3]^2$ is a draw by checking cases
$[4]^2$ is a draw by checking cases
$[5]^2$ has an interesting proof of a draw:

The idea is to pair off points on the $5\times 5$ grid in such a way that each row, column and the two diagonals contain a pair.
This is called a _pairing strategy_. Here is one:

<table>
  <tr> 
    <td> A</td>
<td> 6</td>
<td>3 </td>
<td>6 </td>
    <td> B</td>
  </tr>
  <tr> 
    <td> 1</td>
<td>7 </td>
<td>7 </td>
<td> 4</td>
    <td>5 </td>
  </tr>
<tr> 
  <td> 8</td>
<td> 2</td>
<td> </td>
<td> 4</td>
  <td>8 </td>
</tr>
<tr> 
  <td> 1</td>
<td>2 </td>
<td> 9</td>
<td> 9</td>
  <td> 5</td>
</tr>
<tr> 
  <td>B </td>
<td> 10</td>
<td> 3</td>
<td> 10</td>
  <td> A</td>
</tr>
</table>

P2's plan is; wherever P1 moves, simply find the partner square and play there. If P1 plays in the blank square then play wherever you like. This strategy is guarenteed to at least draw.

Similiarly, for $[6]^2$, there exists a pairing strategy so its also a draw.

We can now show that all of the 2D games are draws. For $[n]^2$ gives a paring strategy for $[n + 2]^2$.
Take the $n\times n$ drawing strategy, and plonk it in the center of our $(n + 1) \times (n + 1)$ grid.
Now the only winning lines that are not paired are the 4 extremal rows and columns. But we can simply place 4 new pairings `a`, `b`, `c`, `d` in these.
So we have a pairing strategy here. Consult the beautiful ASCII art to see what I mean.

```

 (n + 2) x (n + 2)
--------------------
|       a a        |  <- a
|   -----------    |
| d |   n x n |  b |
| d |         |  b |
|   -----------    |
|       c c        |  <- c
--------------------
  ^              ^
  d              b

```

Hence P2 has a drawing strategy for all $[n]^2$ for all $n > 2$.


## Games on an infinite board

The 3-in-a-row strategy is done by making 2 winning threats at the same time by making an 'L' shape.
4-in-a-row is a similar thing, make a double threat.
5-in-a-row is thought to be a P1 win. It is played competitively in Japan, where they add extra rules to make it easier for P2.

If $X = \infty$, the game might be a P1 win. But not in bounded time because $\exists R$ such that P1 can guarantee a win in time $\leq R$.
This is een the case if all lines have size $\leq n$. The degrees are bounded (each $x \in X$ belongs to $\leq k$ lines for some $k$)

__Example:__ Let $B$ be a binary tree game of depth 4. Let $T_n$ be the game consisting of a row of $n$ triangles each linked by a different corner. Winning lines are the triangles.

$T_n$ is a draw.

Let $H$ by the disjoint union of $B, T_2, T_3, \cdots$.
Then P1 wins making a line in $B$, but if P2 plays twice in $T_n$ then P1 has to spend time replying to prevent a P2 win. So it's a P1 win but not in bounded time.

__Open question__: Could 5-in-a-row be a P1 win but in bouded time?

We know that it's a P1 win on a 15x15 board. 

We could show that 5-in-a-row is unbounded win if we could somehow show that playing at larger and larger distances increases the time it takes for P1 to win.

__30-in-a-row:__ Draw, by considering a decomosition of $\mathbb{Z}^2$ into copies of $[5]^2$ which are staggered (to deal with diagonals). Each line of 30 contains a winning line in a copy of $[5]^2$, therefore a pairing draw for P2. P1 watches, and when P2 plays, he plays his $[5]^2$ game reply in that sub-space. Similar arguments are proven down to 8-in-a-row. 

__Hex:__ No strategy known beyond about side-length 7.

__Bridge-it:__ Explicit player 1 win! But not in a boring way. Based on the 'Shannon switching game'.

Play on edges of a graph $G$, P2 wins if he can connect all of the vertices with his edges. (ie, contains a spanning tree). P1 wins otherwise.

__Example:__ If $G$ has a bridge, then trivially a P1 win. 

__Example:__ 

```
+--+-\
|  |  +
+--+-/
```

is a P1 win.

__Example:__ On a tetrahedron it's a P2 win.

__Proposition 2:__ P2 wins the Shannon Switching Game on $G$ if and only if $G$ has two edge-disjoint spanning trees.

__Note__ It's more convenient to prove for multigraphs (graphs with possibly multiple edges per pair of verticies). 

__proof ($\Rightarrow$)__ Let P1 play as follows. Play some move and then pretend he hasn't played it and follow P2's strategy. But we know that P2 wins, so he creates a spanning tree and it's disjoint from P1's subgraph. But we know that since P1 is just copying P2, he must also make a spanning tree, disjoint from P2's.

__proof ($\Leftarrow$)__ Whenever P1 plays a move $x$ in one of the spanning trees, we get two separated vertex sets $A, B$, then P2 plays the edge $e$ which connects something $A$ to something in $B$ using the other spanning tree. Call the contracted graph $G' = (G - x) / e$. That is, $G$ with $x$ removed and contracted on $e$. We have that $G'$ still has two edge-disjoint spanning trees - hence P2 wins on $G'$ by induction. So he also wins on $G$ because he also has the edge $e$.


### Lecture 4

## Applying the Shannon switching game to Bridge-it

Each P2 move exactly cancels one P1 edge - so we may as well just play on the graph of the P1 vertices. With the players claiming edges on the same graph. Get back to the original game by flipping P2's moves along the $x=-y$ diagonal.

```

a    .    .    b
a    .    .    b 
a -- a    .    b

```

If we let P1 start with edge 1, then P1's task is in graph with vertices $a$ identified and $b$ identified. P1 must join these together.
In fact, we can connect all of the vertices as there exists two disjoint spanning trees. Try it out on a $3\times 4$ board.

**Proposition 3:** If $G, H$ are P1 wins, then so is $G \sqcup H$. 

**Notation:** The game *$G$-with-pass* means the game $G$ but now P2 is allowed to pass.

**Definition:**  The *delay* of $G$ (for a P1 win) is the least $R$ such that there exists a winning strategy in the game $G$-with-pass in which P2 always passes $\leq R$ times.
Note that we are only dealing with _finite_ games here. Might not exist for infinite $X$.

**Example:** Take the binary tree with depth 3 with a disjoint size 2 winning line $L$. Let's be player 1.
If I play in $L$, then you can pass but then I win the next time. You can delay me winning for longer if you block by also playing in $L$, then we are playing just the binary tree game and the delay for this is 2.

**Proof of Proposition3:** Let $G$ have delay $a$ and $H$ have delay $b$. Suppose $a \leq b$. The idea is that playing in one game is like passing in the other.
Let $S$ be a P1 strategy in $G$-with-pass  for which P2 passes $\leq N$ times. Let $T$ be a P2 strategy in $H$-with-pass for which P2 passes $\geq b $ times.
Let P1 play in $G$ according to $S$ unless P2 plays in $H$, in which case, we reply in $H$ according to $T$. 
If called upon to pass in $H$, we play in $G$ according to $S$ assuming P2 has just passed there.
Suppose P1 does not win. Then P2 won on $H$. That means that P1 passed at least $b$ times on $H$, by the definition of $T$. 
So P2 passed at least $b$ times on $G$.
Thus, in $G$-with-pass, P2 could now pass for a $(b + 1)$th time. 
This contradicts the definition of $S$.
So we are done.

**Note:** This interpretation of 'delay' is due to Bowler. 

## Some open problems

1. If the $[n]^d$ game is a draw, must the $[n + 1]^d$ game be a draw? It's annoying because of the diagonals.
2. If the $[n]^d$ game is a P1 win, must the $[n]^{d + 1}$ game be a P1 win?
3. If the $(K_N, K_S)$ Ramsey game is a P1 win, must the $(K_{N+1}, K_S)$ game be a P1 WIN? 
4. Similarly, we know that $(K_N,K_S)$ is a P1 win for all $N \geq R(S)$, what about when the $K_N$ graph is replaced with the infinite graph on $\mathbb{N}$
5. If we play the game composed of infinite disjoint copies of the $(K_N, K_S)$ game. Is it a P1 win?
6. For $S$ fixed, we have $(K_N, K_S), (K_{N+1}, K_S), (K_{N+2}, K_S), \cdots$ all P1 wins for a sufficiently large $N$. 
    Is the winning time bounded? In other words, is there a $T$ such that on any $(K_n, K_S)$, with $n = N, N+1, N+2, \cdots$, P1 wins in time $\leq T$?


#### Lecture 5

__Proposition 4:__  Open problem 4 is true if and only if open problem 6 is true. 
That is; (the $(K_{\omega}, K_S)$ game is a P1 win) $\Leftrightarrow$ ($(K_N, K_S)$ is a win in bounded time)

__Note:__ 
WLOG. In $(K_t, K_S)$ or $(K_N, K_S)$, $t$-th move on board $K_{[2t]}$. Proof by induction on $t$.

__proof $(6 \Rightarrow 4)$ :__ We have a $t$ such that P1 wins $(K_{2t)}, K_S)$ in time $\leq t$ (by choosing say $t \geq \frac{1}{2}R(S)$ ).
To ensure $(K_{2t}, K_S)$ is a P1 win, say the strategy is $S$.
To sin as P1 in $(K_N, K_S)$, follow strategy $S$ up to time $t$, which is well defined by the above note.

__proof $(4 \Rightarrow 6)$:__ Suppose 6 is false. So for all $t$ there exists a $f(t)$ such that P2 can survive in $(K_{f(t)}, K_S)$ for time $\geq t$.
Call this strategy $S_ t$. To draw as P2, in $(K_{\omega}, K_S)$, P1 starts, he joins point 1 to point 2. P2 can either draw from 1 or 2 to some other place or draw anywhere else. So infinitely many of the $S_ t$ pick the same reply, P2 plays there. 
P1 now moves, then there are infinitely many (of _those_ infinitely many $S_t$)) which agree on P2's reply, P2 plays there.
Continue this.
At time $T$, P1's play has agreed with infinitely many $S_t$ join particular with some $S _t$, $t > T$. Hence P2 has not lost by time $T$.

__Remark:__ That is a 'compactness argument' very similar to "in a compact metric space, every sequence has a convergent subsequence".

__Fact:__ problem 5 is true if and only if it's true on the game $K_N \sqcup K_N$. 
P1 has a winning strategy in which he starts on one copy of $K_ N$, stays there while P2 stays there _and_ can stay there for the move immediately after P2 first plays in the other board.

Last time this course was given this fact was an open question. Now it has been proven by Bowler.

Could $(K_N, K_4)$ be a win *not* in bounded time? Suppose that making $K_4 - e$, is much easier than making a $K_4$. Suppose also that making an (isolated) $K_4 - e$ does not help you make a $K_4$. As P2, we make a $K_4 - e$ too, $P1$ must reply to block the win.
P2 can now play to a new vertex from a vertex not connected to P1's last move. If P1 does not respond nearby, then P2 can make a double-threat and win on the next move. So P1 must play between the tetrahedron and this new point. But now P2 can play to a new vertex and so on forever. So P2 can get P1 into a loop foreve if the graph is infinite.

Recently, six authors Hefetz, Kusch, Narins, Pokrovsky, Requice, Sarid gave a 5-graph $H$ (a collection of 5-sets) such that on $(K_{\omega}, H)$, P2 can draw. By making a load of threats that P1 can't ignore. An amazing counterexample.

Similarly, maybe 5-in-a-row is a win but not in bounded time, by something along the above reasonings. That is, there is some strategy for P2, playing arbitrarily far away (distance $l$) such that we have a P1 win in time $l^2$.

## Maker breaker games

In the __maker-breaker game__ on $H$, P1 wins if he occupies an $L \in H$ and P2 wins otherwise. So we don't have to worry about P2 winning by occupying a line. We call this the __strong version__ of a hypergraph game. P1 is the __maker__ and P2 is called the __breaker__.

__Example:__ on $[3]^2$

```

3 2 2'
5 1 -
- - -

```

Start at 1 - P2 plays 2 or 2'.
Now P1 plays 3 - P2 must play 4
Now P1 plays 5 and wins on the next move.

Why should we study maker-breaker games? 

1) Trying to 'make a line' is cleaner or more natural than the double goal of "make a line and stop your opponent from doing it first".

2) Can give info on the strong game - eg if the breaker wins then the strong game is a draw.

3) We have monotonicity; adding lines or points preserves maker wins. Eg, in the $[n]^d$ game, there's a __break-point__ $d_0$, this gives a breaker win for all $d < d_0$ and and a maker win for all $d > d_0$.  Eg, in $(K_N, K_S)$  there exists a break-point N_0 similarly.
So far we know $N_0 \leq 4^S$ and $d_0 \leq$ is some iterated tower.

4) "Thomason philosophy": The strong game is too delicate to be interesting. As P1's advantage at the start is at most one move.

