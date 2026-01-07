# Chapter 4
## GPS: The General Problem Solver

> The General Problem Solver (GPS) was the first program to separate its problem-solving strategy from knowledge of particular problems.
>
> -Newell & Simon, *Human Problem Solving* (1972)

In this chapter we develop a program to solve a wide variety of problems.
The program is called GPS, for General Problem Solver.
GPS was one of the first AI programs ever written, developed by Allen Newell and Herbert Simon in 1957.
It's a beautiful example of a simple idea with surprisingly broad applicability.

The key insight behind GPS is *means-ends analysis*: to achieve a goal, find the difference between where you are and where you want to be, then find an action that reduces that difference.
This idea goes back at least to Aristotle, who wrote in the *Nicomachean Ethics*:

> We deliberate not about ends, but about means.
> For a doctor does not deliberate whether he shall heal, nor an orator whether he shall persuade... They assume the end and consider how and by what means it is to be attained.

This chapter will show how to implement GPS in MeTTa using pattern matching and backward chaining.
Along the way, we'll see how MeTTa's features—particularly the Atomspace and nondeterminism—provide a natural fit for this kind of reasoning.

## 4.1 The School Problem

Let's start with a concrete example.
Suppose you want to drive your son to school, but your car won't start because the battery is dead.
What do you do?

Most people can solve this easily: call the auto shop, have them install a new battery, then drive to school.
But how do we get a computer to reason like this?

Here's the problem spelled out:

**Initial state:**
- Son is at home
- Car needs a new battery
- Have money
- Have a phone book

**Goal:** Son is at school

**Available actions:**
- *Drive son to school* — requires: son at home, car works
- *Shop installs battery* — requires: car needs battery, shop knows problem, shop has money
- *Tell shop the problem* — requires: in communication with shop
- *Telephone shop* — requires: know phone number
- *Look up phone number* — requires: have phone book
- *Give shop money* — requires: have money

GPS works backward from the goal.
We want "son at school."
What action achieves that?
*Drive son to school*.
But that requires the car to work.
The car needs a battery.
So we need the shop to install one.
For that, we need to tell them the problem and pay them.
To tell them, we need to call them.
To call, we need the phone number.
To get the number, we look it up.

Working backward from the goal, we build up a plan:

1. Look up the phone number
2. Telephone the shop
3. Tell them the problem
4. Give them money
5. Shop installs battery
6. Drive son to school

This is means-ends analysis in action.
Each action is a *means* to achieve an *end* (a goal), and each action may have its own preconditions that become subgoals.

## 4.2 Representing Operators in MeTTa

In GPS, actions are called *operators*.
Each operator has:
- A name (what action to take)
- A goal (what condition it achieves)
- Preconditions (what must be true before the action)

In MeTTa, we represent operators as facts in the Atomspace:

```metta
(op look-up-number know-phone-number (have-phone-book))
```

This says: the operator `look-up-number` achieves the goal `know-phone-number` when the precondition `have-phone-book` is satisfied.

For multiple preconditions, we list them in a tuple:

```metta
(op drive-son-to-school son-at-school (son-at-home car-works))
```

Here are all the operators for the school problem:

```metta
(op look-up-number know-phone-number (have-phone-book))
(op telephone-shop in-communication-with-shop (know-phone-number))
(op tell-shop-problem shop-knows-problem (in-communication-with-shop))
(op give-shop-money shop-has-money (have-money))
(op shop-installs-battery car-works
    (car-needs-battery shop-knows-problem shop-has-money))
(op drive-son-to-school son-at-school (son-at-home car-works))
```

The current state is also represented as facts:

```metta
(state son-at-home)
(state car-needs-battery)
(state have-money)
(state have-phone-book)
```

Notice how clean this is.
We're not manipulating data structures—we're simply declaring what we know.
The operators and state live together in the Atomspace, queryable by pattern matching.

## 4.3 The GPS Algorithm

The core of GPS is surprisingly simple.
To achieve a goal:

1. If the goal is already in the current state, we're done
2. Otherwise, find an operator that achieves this goal
3. Recursively achieve all the operator's preconditions
4. Add the operator's action to our plan

Here's the MeTTa implementation:

```metta
; Base case: goal already satisfied
(= (gps $goal $acc)
   (match &self (state $goal) $acc))

; Recursive case: find and apply an operator
(= (gps $goal $acc)
   (match &self (op $action $goal ($r1))
     (let $acc1 (gps $r1 $acc)
       (add $acc1 $action))))
```

Let's trace through this.
The function `gps` takes a goal and an accumulator (the plan so far).
It first tries to match `(state $goal)` in the Atomspace.
If the goal is already a state, we return the current plan unchanged.

If not, we look for an operator: `(op $action $goal ...)`.
The `match &self` finds any operator in the Atomspace whose second element is our goal.
Then we recursively achieve the preconditions, building up the plan.

For operators with multiple preconditions, we chain the recursive calls:

```metta
(= (gps $goal $acc)
   (match &self (op $action $goal ($r1 $r2))
     (let* (($acc1 (gps $r1 $acc))
            ($acc2 (gps $r2 $acc1)))
       (add $acc2 $action))))
```

The `let*` ensures we achieve preconditions in order, threading the accumulator through each step.

## 4.4 Running GPS

Let's run GPS on the school problem:

```metta
!(solve son-at-school)
```

Result:
```
(plan look-up-number telephone-shop tell-shop-problem
      give-shop-money shop-installs-battery drive-son-to-school)
```

The plan is exactly what we expected.
GPS works backward from `son-at-school`:

1. Need `drive-son-to-school`, which requires `son-at-home` (✓) and `car-works`
2. Need `shop-installs-battery` for `car-works`, requires three things
3. Need `tell-shop-problem` for `shop-knows-problem`
4. Need `telephone-shop` for `in-communication-with-shop`
5. Need `look-up-number` for `know-phone-number`
6. Have `have-phone-book` (✓) — base case!

Then the recursion unwinds, building the plan from innermost to outermost.

### Testing Other Cases

What if the car already works?

```metta
(state son-at-home)
(state car-works)

!(solve son-at-school)
; => (plan drive-son-to-school)
```

Just one action needed.

What if we don't have the phone book?

```metta
(state son-at-home)
(state car-needs-battery)
(state have-money)
; No phone book!

!(solve son-at-school)
; => []  (empty - no solution)
```

GPS returns an empty result when no solution exists.
Without the phone book, we can't look up the number, can't call the shop, can't get the battery fixed.

## 4.5 The Monkey and Bananas

To show that GPS is truly general, let's apply it to a completely different domain: the classic monkey and bananas puzzle.

A monkey is in a room with bananas hanging from the ceiling.
There's also a chair in the room.
The monkey must figure out how to get the bananas.

```metta
; Initial state
(state at-door)         ; Monkey at the door
(state on-floor)        ; Monkey on the floor
(state empty-handed)    ; Monkey's hands are empty

; Operators
(op walk-to-chair at-middle-of-room (at-door on-floor))
(op push-chair chair-at-bananas (at-middle-of-room on-floor))
(op climb-on-chair on-chair (chair-at-bananas on-floor))
(op grasp-bananas have-bananas (on-chair empty-handed))
(op eat-bananas satisfied (have-bananas))

!(solve satisfied)
; => (plan walk-to-chair push-chair climb-on-chair
;         grasp-bananas eat-bananas)
```

The same GPS code that solved the school problem now solves the monkey puzzle.
We only changed the operators and initial state.

This is the power of separating *problem-solving strategy* (GPS) from *domain knowledge* (operators).
GPS doesn't know anything about cars, phone books, monkeys, or bananas.
It only knows how to chain operators together to achieve goals.

## 4.6 Maze Navigation

For mazes, GPS faces a challenge: cycles.
In a maze, you can go from room A to room B and back to A.
Without tracking where you've been, GPS would loop forever.

The original GPS didn't handle this well.
But MeTTa gives us a more elegant solution: use nondeterminism to explore all paths, tracking visited nodes to avoid cycles.

```metta
; Maze edges (bidirectional)
(edge 1 2) (edge 2 1) (edge 2 3) (edge 3 2)
(edge 1 4) (edge 4 1) ; ... more edges

; Path finding with cycle detection
(= (path $x $x $visited) (route $x))  ; Base: arrived!

(= (path $from $to $visited)
   (match &self (edge $from $next)
     (if (not-in $next $visited)
         (let $result (path $next $to (add-to $from $visited))
           (prepend $from $result))
         empty)))
```

The key difference: we pass a `$visited` set through the recursion.
If we've already visited a node, we don't go there again.

And here's where MeTTa shines.
Because `match` returns *all* matching edges, and MeTTa naturally handles nondeterminism, we get *all* valid paths:

```metta
!(find-paths 1 9)
; => (route 1 4 7 8 9)
;    (route 1 2 5 8 9)
;    (route 1 2 3 6 9)
;    ... and more!
```

A single query returns every path through the maze.
This is fundamentally different from traditional GPS, which returns one solution.
MeTTa's nondeterminism transforms a search problem into a declarative query.

## 4.7 The Blocks World

The blocks world is a classic AI domain: blocks on a table that can be stacked.

```metta
; Initial: A, B, C all on table
(state a-on-table)
(state b-on-table)
(state c-on-table)
(state a-clear)
(state b-clear)
(state c-clear)

; Operators
(op put-a-on-b a-on-b (a-clear b-clear))
(op put-b-on-c b-on-c (b-clear c-clear))
; ... etc
```

Simple stacking works fine with GPS:

```metta
!(solve a-on-b)  ; => (plan put-a-on-b)
```

But the blocks world reveals a fundamental limitation of simple GPS: *goal interaction*.

Consider the **Sussman anomaly**:
- Initial: C is on A, both on table, B on table
- Goal: A on B AND B on C

If you achieve "A on B" first, you might interfere with "B on C".
The goals interact—achieving one can undo progress on another.

Our simple GPS doesn't model how actions change the state.
It assumes achieving one goal doesn't affect others.
This is fine for the school problem (installing a battery doesn't un-look-up the phone number), but fails when goals interfere.

Solving this requires more sophisticated planners that:
1. Track actual state changes
2. Detect goal conflicts
3. Find orderings that avoid interference

This led to systems like STRIPS, Warplan, and modern PDDL planners.
For our purposes, the blocks world teaches us that GPS has limits—but those limits point toward richer techniques.

## 4.8 What Makes GPS Work (and Fail)

GPS works because of three key ideas:

**1. Means-ends analysis**
Don't search blindly.
Look at what you want (ends) and find actions that get you there (means).
This focuses the search dramatically.

**2. Backward chaining**
Start from the goal and work backward.
This avoids exploring irrelevant actions.
If your goal is "son at school," you never consider operators that don't contribute to that goal.

**3. Declarative operators**
The problem knowledge is separate from the solving strategy.
Change the operators, solve a different problem.
The same GPS code works for school, monkeys, and mazes.

GPS fails when:

**1. Cycles exist**
Without visited tracking, GPS loops forever.
Our maze solution addresses this, but it's a different algorithm than pure GPS.

**2. Goals interact**
The Sussman anomaly shows that achieving goals independently can fail.
Real planning needs to consider action effects on all goals.

**3. Operators are too rigid**
GPS operators have fixed preconditions and effects.
What if an action has variable effects?
What if the same goal can be achieved different ways with different trade-offs?

## 4.9 MeTTa's Contribution

Implementing GPS in MeTTa taught us several things:

**Pattern matching is natural for search.**
Finding applicable operators is just a `match` query.
No loops, no explicit iteration—just declare what you're looking for.

**The Atomspace unifies knowledge.**
Operators and state live in the same space, queried the same way.
This makes the implementation clean and extensible.

**Nondeterminism enables exploration.**
The maze example showed how MeTTa can find all solutions, not just one.
This transforms search into querying.

**Backward chaining emerges from recursion.**
GPS's backward chaining is just recursive pattern matching.
Each recursive call achieves a subgoal; the base case is a fact in the Atomspace.

The GPS we built is simpler than the Lisp original in some ways (no explicit state threading) but captures the same essential algorithm.
More importantly, it's idiomatic MeTTa—using the language's strengths rather than fighting against them.

## 4.10 Summary

GPS demonstrates that a simple algorithm—backward chaining with means-ends analysis—can solve a surprising variety of problems.
By separating problem-solving strategy from domain knowledge, we can reuse the same code for school logistics, monkey puzzles, and maze navigation.

Key points:
- **Operators** encode domain knowledge: what actions achieve what goals
- **Backward chaining** works from goal to preconditions
- **Means-ends analysis** focuses search on relevant actions
- **MeTTa's pattern matching** makes operator lookup natural
- **Nondeterminism** enables finding all solutions
- **Limitations** include cycles and goal interaction

GPS is a foundation.
More sophisticated planners build on these ideas, handling state changes, goal conflicts, and uncertainty.
But the core insight—find the difference between current and goal state, then reduce it—remains central to AI planning.

## 4.11 Exercises

**Exercise 4.1 [m]** Add a new operator to the school problem: `ask-neighbor-for-ride`, which achieves `son-at-school` with precondition `neighbor-home`.
Add `(state neighbor-home)` to the initial state.
What plan does GPS find now?

**Exercise 4.2 [m]** Create a new domain: making breakfast.
Define operators for actions like `boil-water`, `add-coffee-grounds`, `pour-water`, `add-milk`.
Initial state might include `have-water`, `have-coffee`, `have-milk`.
Goal: `have-coffee-with-milk`.

**Exercise 4.3 [h]** The maze path finder returns all paths.
Modify it to return only the *shortest* path.
Hint: you'll need to track path length and filter results.

**Exercise 4.4 [h]** Extend GPS to handle operators with *effects* that change state.
Define operators as `(op action achieves (precond...) (adds...) (deletes...))`.
After applying an operator, update the state accordingly.
This is closer to how STRIPS planners work.

**Exercise 4.5 [d]** Implement a blocks world solver that handles the Sussman anomaly.
You'll need to:
1. Track actual state changes
2. Check if all goals are satisfied at the end
3. Potentially try different goal orderings

## 4.12 Answers

### Answer 4.1

```metta
; Add the new operator
(op ask-neighbor-for-ride son-at-school (neighbor-home))

; Add to state
(state neighbor-home)

!(solve son-at-school)
; GPS now finds: (plan ask-neighbor-for-ride)
; The simpler solution is preferred!
```

### Answer 4.2

```metta
; Coffee making domain
(state have-water)
(state have-coffee)
(state have-milk)
(state have-cup)
(state have-kettle)

(op boil-water hot-water (have-water have-kettle))
(op add-grounds coffee-in-cup (have-coffee have-cup))
(op pour-hot-water black-coffee (coffee-in-cup hot-water))
(op add-milk-to-coffee coffee-with-milk (black-coffee have-milk))

!(solve coffee-with-milk)
; => (plan boil-water add-grounds pour-hot-water add-milk-to-coffee)
```

### Answer 4.3

```metta
; Track path length
(= (shortest-path $from $to)
   (let $paths (collapse (find-paths $from $to))
     (min-by-length $paths)))

(= (min-by-length ($p)) $p)
(= (min-by-length ($p1 $p2 $rest))
   (if (shorter $p1 $p2)
       (min-by-length ($p1 $rest))
       (min-by-length ($p2 $rest))))

; ... helper functions for length comparison
```

### Answer 4.4 and 4.5

These are substantial extensions that would require tracking mutable state.
See the blocks.metta file for discussion of the challenges involved.
A full STRIPS-style planner is beyond our current scope but would make an excellent project.

---

*In this chapter we've seen how GPS uses backward chaining and means-ends analysis to solve problems across different domains.
The MeTTa implementation showcases pattern matching and the Atomspace, while the maze example demonstrates MeTTa's nondeterminism.
In Chapter 5, we'll build ELIZA, an early chatbot that uses pattern matching in a different way—to simulate conversation.*
