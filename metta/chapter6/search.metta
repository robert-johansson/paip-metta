;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Search Algorithms
;
; A MeTTa implementation of classic search algorithms.
; Uses MeTTa's nondeterminism as the primary search
; mechanism, with explicit queue management shown for
; comparison with traditional approaches.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PART 1: NONDETERMINISTIC SEARCH (MeTTa-native)
;
; The most natural way to search in MeTTa is to use
; nondeterminism - let the runtime explore all paths.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EXAMPLE DOMAIN: Binary Tree
;
; Node n has children 2n and 2n+1
; We use nondeterminism to generate children
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Children as nondeterministic choice (bounded to prevent infinite search)
(= (tree-child $n)
   (if (> (* 2 $n) 63)
       (superpose ())
       (superpose ((* 2 $n) (+ 1 (* 2 $n))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DEPTH-LIMITED SEARCH
;
; Explores via nondeterminism with a depth limit.
; Returns (found $node) for each successful path.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Base case: at goal
(= (search $node $goal $successors $depth)
   (if (== $node $goal)
       (found $node)
       (if (> $depth 0)
           (let $child ($successors $node)
             (search $child $goal $successors (- $depth 1)))
           (superpose ()))))

; Filter to only return successful finds
(= (search-find $start $goal $successors $depth)
   (let $result (search $start $goal $successors $depth)
     (if (== $result (found $goal)) $result (superpose ()))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EXAMPLE DOMAIN: Graph with Cycles
;
; Edges stored as facts in the atomspace.
; Nondeterminism via `match` explores all edges.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Graph structure:
;   1 -- 2 -- 3
;   |    |    |
;   4 -- 5 -- 6

(edge 1 2) (edge 2 1)
(edge 2 3) (edge 3 2)
(edge 1 4) (edge 4 1)
(edge 2 5) (edge 5 2)
(edge 3 6) (edge 6 3)
(edge 4 5) (edge 5 4)
(edge 5 6) (edge 6 5)

; Get neighbors via pattern matching (nondeterministic)
(= (neighbor $n)
   (match &self (edge $n $next) $next))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VISITED SET OPERATIONS
;
; Using nested tuples: ($item $rest) or ()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (visited? $x ()) False)
(= (visited? $x ($h $t))
   (if (== $x $h) True (visited? $x $t)))

(= (add-visited $x $set) ($x $set))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPH SEARCH WITH CYCLE DETECTION
;
; Tracks visited nodes to avoid infinite loops
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Base case: reached goal
(= (graph-search $node $goal $visited)
   (if (== $node $goal)
       (found $node)
       (if (visited? $node $visited)
           (superpose ())  ; Already visited, backtrack
           (let $next (neighbor $node)
             (graph-search $next $goal (add-visited $node $visited))))))

; Entry point
(= (find-in-graph $start $goal)
   (graph-search $start $goal ()))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PATH-BUILDING SEARCH
;
; Returns the path taken, not just success/failure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Path represented as nested pairs: ($node ($prev ...))
(= (path-search $node $goal $visited $path)
   (if (== $node $goal)
       (reverse-path ($node $path))
       (if (visited? $node $visited)
           (superpose ())
           (let $next (neighbor $node)
             (path-search $next $goal
               (add-visited $node $visited)
               ($node $path))))))

; Reverse a nested-pair path to get proper order
(= (reverse-path $p) (rev-acc $p ()))
(= (rev-acc () $acc) $acc)
(= (rev-acc ($h $t) $acc) (rev-acc $t ($h $acc)))

; Entry point
(= (find-path $start $goal)
   (path-search $start $goal () ()))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PART 2: EXPLICIT QUEUE SEARCH (For Comparison)
;
; Traditional search uses explicit frontier queues.
; Less idiomatic in MeTTa but shows BFS vs DFS clearly.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; QUEUE OPERATIONS
;
; Using nested tuples as a queue: (item1 (item2 (item3 ())))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (empty-queue) ())
(= (queue-empty? ()) True)
(= (queue-empty? ($x $xs)) False)

(= (enqueue-front $item $queue) ($item $queue))

(= (enqueue-back $item ()) ($item ()))
(= (enqueue-back $item ($h $t)) ($h (enqueue-back $item $t)))

(= (dequeue ($h $t)) ($h $t))

; Enqueue all items from a list
(= (enqueue-all-front () $queue) $queue)
(= (enqueue-all-front ($h $t) $queue)
   (enqueue-all-front $t ($h $queue)))

(= (enqueue-all-back () $queue) $queue)
(= (enqueue-all-back ($h $t) $queue)
   (enqueue-all-back $t (enqueue-back $h $queue)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUCCESSOR FUNCTIONS (Return nested-pair lists)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Binary tree children as a list
(= (tree-children $n)
   (if (> (* 2 $n) 31)
       ()
       ((* 2 $n) ((+ 1 (* 2 $n)) ()))))

; Graph neighbors as a list (deterministic version)
(= (neighbor-list $n)
   (collapse (neighbor $n)))

; Convert collapsed list to nested pairs
(= (to-pairs ()) ())
(= (to-pairs ($h $t)) ($h (to-pairs $t)))

(= (graph-children $n)
   (let $raw (collapse (neighbor $n))
     (to-pairs $raw)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TREE SEARCH WITH EXPLICIT QUEUE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (tree-search-q () $goal $successors $enqueue-fn)
   not-found)

(= (tree-search-q ($node $rest) $goal $successors $enqueue-fn)
   (if (== $node $goal)
       (found $node)
       (tree-search-q
         ($enqueue-fn ($successors $node) $rest)
         $goal $successors $enqueue-fn)))

; DFS: enqueue at front (LIFO)
(= (dfs-tree $start $goal $successors)
   (tree-search-q ($start ()) $goal $successors enqueue-all-front))

; BFS: enqueue at back (FIFO)
(= (bfs-tree $start $goal $successors)
   (tree-search-q ($start ()) $goal $successors enqueue-all-back))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPH SEARCH WITH EXPLICIT QUEUE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (graph-search-q () $goal $successors $enqueue-fn $visited)
   not-found)

(= (graph-search-q ($node $rest) $goal $successors $enqueue-fn $visited)
   (if (== $node $goal)
       (found $node)
       (if (visited? $node $visited)
           (graph-search-q $rest $goal $successors $enqueue-fn $visited)
           (let $children (filter-unvisited ($successors $node) $visited)
             (graph-search-q
               ($enqueue-fn $children $rest)
               $goal $successors $enqueue-fn
               (add-visited $node $visited))))))

; Filter out visited nodes
(= (filter-unvisited () $visited) ())
(= (filter-unvisited ($h $t) $visited)
   (if (visited? $h $visited)
       (filter-unvisited $t $visited)
       ($h (filter-unvisited $t $visited))))

; DFS on graphs
(= (dfs-graph $start $goal $successors)
   (graph-search-q ($start ()) $goal $successors enqueue-all-front ()))

; BFS on graphs
(= (bfs-graph $start $goal $successors)
   (graph-search-q ($start ()) $goal $successors enqueue-all-back ()))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BEST-FIRST SEARCH
;
; Sort frontier by cost function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Insert into sorted list (by cost, ascending)
(= (insert-by-cost $item $cost-fn ()) ($item ()))
(= (insert-by-cost $item $cost-fn ($h $t))
   (if (< ($cost-fn $item) ($cost-fn $h))
       ($item ($h $t))
       ($h (insert-by-cost $item $cost-fn $t))))

; Sort list by cost
(= (sort-by-cost $cost-fn ()) ())
(= (sort-by-cost $cost-fn ($h $t))
   (insert-by-cost $h $cost-fn (sort-by-cost $cost-fn $t)))

; Distance heuristic
(= (dist-from $target $node)
   (if (> $node $target)
       (- $node $target)
       (- $target $node)))

; Best-first search
(= (best-first-q () $goal $successors $cost-fn)
   not-found)

(= (best-first-q ($node $rest) $goal $successors $cost-fn)
   (if (== $node $goal)
       (found $node)
       (let $expanded (append-lists ($successors $node) $rest)
         (best-first-q
           (sort-by-cost $cost-fn $expanded)
           $goal $successors $cost-fn))))

; Append two nested-pair lists
(= (append-lists () $ys) $ys)
(= (append-lists ($h $t) $ys) ($h (append-lists $t $ys)))

; Entry point
(= (best-first $start $goal $successors $cost-fn)
   (best-first-q ($start ()) $goal $successors $cost-fn))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TESTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Nondeterministic tree search:
; !(search-find 1 7 tree-child 5)
; ; => (found 7)

; !(search-find 1 12 tree-child 5)
; ; => (found 12)

; Graph search with cycle detection:
; !(find-in-graph 1 6)
; ; => (found 6)

; Path finding:
; !(find-path 1 6)
; ; => (6 (5 (2 (1 ()))))  or other valid paths

; Explicit queue DFS on tree:
; !(dfs-tree 1 7 tree-children)
; ; => (found 7)

; Explicit queue BFS on tree:
; !(bfs-tree 1 7 tree-children)
; ; => (found 7)

; Best-first search:
; !(best-first 1 12 tree-children (dist-from 12))
; ; => (found 12)
