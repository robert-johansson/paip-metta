# Chapter 6
## Building Software Tools

> The tools we use have a profound (and devious!) influence on our thinking habits, and, therefore, on our thinking abilities.
>
> -Edsger Dijkstra

In this chapter we build reusable tools for AI programming.
We focus on two fundamental techniques that appear throughout AI: **pattern matching** and **search**.

Pattern matching lets us transform data based on its structure.
Search lets us explore spaces of possibilities to find solutions.
Both are so fundamental that most AI programs use them in some form.

## 6.1 The Pattern Matcher

In Chapter 5, we saw how ELIZA uses pattern matching to respond to user input.
The patterns were implicit in the function definitions.
Now we'll build an *explicit* pattern matcher that returns bindings we can inspect and manipulate.

### Why an Explicit Pattern Matcher?

MeTTa already has powerful pattern matching through its `=` rules.
Why build our own?

1. **Inspectable bindings** - We can examine what matched what
2. **Patterns as data** - Patterns can come from the atomspace, not just code
3. **Custom matching** - We can extend the matching behavior

### The Basic Pattern Matcher

Our pattern matcher takes a pattern and an input, returning *bindings*—a record of which variables matched which values:

```metta
!(match-pattern (var x) hello)
; => (bindings (x hello))

!(match-pattern ((var a) (var b)) (1 2))
; => (bindings (b 2) (a 1))
```

The pattern `(var x)` matches anything and binds it to `x`.
Compound patterns match element by element.

### Variable Consistency

A key feature: the same variable must match the same value:

```metta
!(match-pattern ((var x) (var x)) (a a))
; => (bindings (x a))

!(match-pattern ((var x) (var x)) (a b))
; => fail
```

This is implemented by checking if a variable is already bound:

```metta
(= (pm-var $name $input $bindings)
   (let $existing (lookup $name $bindings)
     (if (== $existing not-found)
         (extend $name $input $bindings)
         (if (== $existing $input) $bindings fail))))
```

### Literal Patterns

To match a specific value, use `(lit value)`:

```metta
!(match-pattern ((lit hello) (var who)) (hello world))
; => (bindings (who world))

!(match-pattern ((lit hello) (var who)) (bye world))
; => fail
```

### The Rule-Based Translator

Building on the pattern matcher, we can create a rule-based translator—a function that finds matching rules and applies transformations:

```metta
(= (response-rules)
   ((rule ((lit hello) (var x)) ((lit hi) (lit there) (var x)))
    (rule ((lit I) (lit am) (var mood)) ((lit why) (lit are) (lit you) (var mood)))
    ()))

!(translate (hello friend))
; => (hi there friend)

!(translate (I am happy))
; => (why are you happy)
```

This is essentially how ELIZA works, but with explicit, inspectable rules.

## 6.2 Search: The Heart of AI

Search is central to AI.
Planning is search through action sequences.
Diagnosis is search through possible causes.
Game playing is search through move sequences.

The key insight: most search algorithms follow the same pattern:
1. Maintain a **frontier** of nodes to explore
2. Pick a node from the frontier
3. If it's a goal, succeed
4. Otherwise, expand it and add successors to the frontier
5. Repeat

The difference between search algorithms is *how they manage the frontier*.

## 6.3 Search in MeTTa: Two Approaches

MeTTa offers two ways to implement search:

**1. Nondeterministic (MeTTa-native)**: Let the runtime explore all paths
**2. Explicit queue**: Manage the frontier ourselves

Both are valuable.
Nondeterminism is elegant and natural for MeTTa.
Explicit queues give us control over search order.

### Nondeterministic Search

The most MeTTa-like approach uses nondeterminism to explore alternatives:

```metta
; Children as nondeterministic choice
(= (tree-child $n)
   (superpose ((* 2 $n) (+ 1 (* 2 $n)))))

; Depth-limited search
(= (search $node $goal $successors $depth)
   (if (== $node $goal)
       (found $node)
       (if (> $depth 0)
           (let $child ($successors $node)
             (search $child $goal $successors (- $depth 1)))
           (superpose ()))))
```

The `let $child ($successors $node)` binds `$child` to *each* successor nondeterministically.
MeTTa automatically explores all paths.

```metta
!(search-find 1 7 tree-child 5)
; => (found 7)
```

### Graph Search with Cycle Detection

For graphs with cycles, we track visited nodes:

```metta
(= (visited? $x ()) False)
(= (visited? $x ($h $t))
   (if (== $x $h) True (visited? $x $t)))

(= (graph-search $node $goal $visited)
   (if (== $node $goal)
       (found $node)
       (if (visited? $node $visited)
           (superpose ())  ; Backtrack
           (let $next (neighbor $node)
             (graph-search $next $goal ($node $visited))))))
```

The visited set uses nested tuples: `($item ($item2 ()))`.
When we reach a visited node, `(superpose ())` backtracks to try other paths.

## 6.4 Depth-First vs Breadth-First

With nondeterminism, MeTTa naturally performs depth-first search—it explores each path fully before backtracking.

To see the difference between DFS and BFS, we need explicit queue management.

### Explicit Queue Search

```metta
(= (tree-search-q () $goal $successors $enqueue-fn)
   not-found)

(= (tree-search-q ($node $rest) $goal $successors $enqueue-fn)
   (if (== $node $goal)
       (found $node)
       (tree-search-q
         ($enqueue-fn ($successors $node) $rest)
         $goal $successors $enqueue-fn)))
```

The `$enqueue-fn` determines the search order:

**Depth-first**: Add new nodes at the *front* (LIFO)
```metta
(= (enqueue-all-front () $queue) $queue)
(= (enqueue-all-front ($h $t) $queue)
   (enqueue-all-front $t ($h $queue)))
```

**Breadth-first**: Add new nodes at the *back* (FIFO)
```metta
(= (enqueue-all-back () $queue) $queue)
(= (enqueue-all-back ($h $t) $queue)
   (enqueue-all-back $t (enqueue-back $h $queue)))
```

### When to Use Each

**Depth-first search**:
- Memory efficient (stores only current path)
- Good when solutions are deep
- May miss shallow solutions
- Can loop forever on infinite spaces

**Breadth-first search**:
- Finds shortest path (by number of steps)
- Memory intensive (stores entire frontier)
- Good when solutions are shallow
- Always terminates if solution exists

## 6.5 Best-First Search

Sometimes we have a heuristic—an estimate of how good a node is.
Best-first search always expands the most promising node:

```metta
(= (best-first-q ($node $rest) $goal $successors $cost-fn)
   (if (== $node $goal)
       (found $node)
       (let $expanded (append-lists ($successors $node) $rest)
         (best-first-q
           (sort-by-cost $cost-fn $expanded)
           $goal $successors $cost-fn))))
```

With a distance heuristic:

```metta
(= (dist-from $target $node)
   (if (> $node $target)
       (- $node $target)
       (- $target $node)))

!(best-first 1 12 tree-children (dist-from 12))
; => (found 12)
```

Best-first search is greedy—it may not find the optimal path.
A* search improves on this by considering cost-so-far plus estimated-cost-to-go.

## 6.6 The Power of Nondeterminism

MeTTa's nondeterminism changes how we think about search.

In traditional languages, we write search loops that maintain state.
In MeTTa, we write recursive functions and let the runtime explore.

Consider path finding:

```metta
(= (find-path $start $goal)
   (path-search $start $goal () ()))

(= (path-search $node $goal $visited $path)
   (if (== $node $goal)
       (reverse-path ($node $path))
       (if (visited? $node $visited)
           (superpose ())
           (let $next (neighbor $node)
             (path-search $next $goal
               ($node $visited)
               ($node $path))))))
```

One function, but MeTTa explores ALL valid paths.
Each call to `(neighbor $node)` branches into multiple possibilities.
Failed paths simply return empty results.

## 6.7 Search and the Atomspace

A powerful pattern: store the search space in the atomspace.

```metta
; Graph edges as facts
(edge 1 2) (edge 2 1)
(edge 2 3) (edge 3 2)
(edge 1 4) (edge 4 1)
...

; Get neighbors via pattern matching
(= (neighbor $n)
   (match &self (edge $n $next) $next))
```

The `match &self` is nondeterministic—it returns ALL matching edges.
This naturally integrates search with knowledge representation.

## 6.8 When to Use Each Approach

**Use nondeterminism when**:
- You want all solutions (not just the first)
- The search space is stored in the atomspace
- DFS is acceptable

**Use explicit queues when**:
- You need specific search order (BFS, best-first)
- You want to control the frontier
- You're comparing search strategies

Both approaches can be combined.
Start with nondeterminism; switch to explicit queues when you need more control.

## 6.9 Summary

We've built two fundamental AI tools:

**Pattern Matcher**:
- Matches patterns against inputs
- Returns explicit bindings
- Supports variables and literals
- Enables rule-based transformation

**Search Algorithms**:
- Nondeterministic search (MeTTa-native)
- Explicit queue search (DFS, BFS)
- Graph search with cycle detection
- Best-first search with heuristics

These tools will reappear throughout the book:
- STUDENT (Chapter 7) uses pattern matching for parsing
- Logic Programming (Chapter 11) uses search and backtracking
- Game Playing (Chapter 18) uses tree search with evaluation

## 6.10 Exercises

**Exercise 6.1 [s]** Extend the pattern matcher to support `(any)` patterns that match anything without binding:
```metta
!(match-pattern ((any) (var x)) (hello world))
; => (bindings (x world))
```

**Exercise 6.2 [m]** Implement iterative deepening: run depth-limited search with increasing depth limits until a solution is found.
This combines DFS's memory efficiency with BFS's completeness.

**Exercise 6.3 [m]** Add path tracking to the nondeterministic tree search.
Return `(path 1 3 6 12)` instead of just `(found 12)`.

**Exercise 6.4 [h]** Implement beam search: best-first search but only keep the top N nodes.
This trades completeness for efficiency on large search spaces.

**Exercise 6.5 [h]** Implement A* search with cost-so-far tracking.
The heuristic should be `f(n) = g(n) + h(n)` where `g` is cost-so-far and `h` is estimated cost-to-go.

## 6.11 Answers

### Answer 6.1

```metta
; Add any pattern - matches but doesn't bind
(= (pm (any) $input $bindings) $bindings)

!(match-pattern ((any) (var x)) (hello world))
; => (bindings (x world))
```

### Answer 6.2

```metta
(= (iterative-deepening $start $goal $successors $max-depth)
   (id-search $start $goal $successors 1 $max-depth))

(= (id-search $start $goal $successors $depth $max)
   (if (> $depth $max)
       not-found
       (let $result (search-find $start $goal $successors $depth)
         (if (== $result (found $goal))
             $result
             (id-search $start $goal $successors (+ $depth 1) $max)))))
```

### Answer 6.3

```metta
(= (search-path $node $goal $successors $depth $path)
   (if (== $node $goal)
       (reverse-path ($node $path))
       (if (> $depth 0)
           (let $child ($successors $node)
             (search-path $child $goal $successors (- $depth 1) ($node $path)))
           (superpose ()))))
```

---

*In this chapter we've built pattern matching and search tools that will serve us throughout the book.
Pattern matching transforms data; search explores possibilities.
MeTTa's nondeterminism makes search particularly elegant—we describe what we're looking for, and the runtime finds all solutions.*

**MeTTa files:** `metta/chapter6/patmatch.metta`, `metta/chapter6/search.metta`
