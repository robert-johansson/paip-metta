;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Maze Navigation
;
; This file demonstrates two approaches:
; 1. GPS on a simple linear path (no cycles)
; 2. A more MeTTa-native path finder using nondeterminism
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Part 1: GPS on Simple Path
;
; GPS works well when there's a clear forward direction.
; For mazes with cycles, GPS can loop infinitely.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Simple corridor: 1 -> 2 -> 3 -> 4 -> exit
(state at-1)

(op go-1-to-2 at-2 (at-1))
(op go-2-to-3 at-3 (at-2))
(op go-3-to-4 at-4 (at-3))
(op go-4-to-exit at-exit (at-4))

; Include gps.metta for (solve goal)
; !(solve at-exit)
; Expected: (plan go-1-to-2 go-2-to-3 go-3-to-4 go-4-to-exit)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Part 2: MeTTa-Native Path Finder
;
; For mazes with cycles, we need a different approach.
; This uses MeTTa's nondeterminism to find ALL paths.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Maze as a graph (bidirectional edges)
; 1 -- 2 -- 3
; |    |    |
; 4 -- 5 -- 6
; |    |    |
; 7 -- 8 -- 9

(edge 1 2) (edge 2 1) (edge 2 3) (edge 3 2)
(edge 1 4) (edge 4 1) (edge 2 5) (edge 5 2) (edge 3 6) (edge 6 3)
(edge 4 5) (edge 5 4) (edge 5 6) (edge 6 5)
(edge 4 7) (edge 7 4) (edge 5 8) (edge 8 5) (edge 6 9) (edge 9 6)
(edge 7 8) (edge 8 7) (edge 8 9) (edge 9 8)

; Visited set operations
(= (not-in $x ()) True)
(= (not-in $x ($h $t)) (if (== $x $h) False (not-in $x $t)))
(= (add-to $x $set) ($x $set))

; Prepend to route
(= (prepend $x (route)) (route $x))
(= (prepend $x (route $a)) (route $x $a))
(= (prepend $x (route $a $b)) (route $x $a $b))
(= (prepend $x (route $a $b $c)) (route $x $a $b $c))
(= (prepend $x (route $a $b $c $d)) (route $x $a $b $c $d))
(= (prepend $x (route $a $b $c $d $e)) (route $x $a $b $c $d $e))
(= (prepend $x (route $a $b $c $d $e $f)) (route $x $a $b $c $d $e $f))
(= (prepend $x (route $a $b $c $d $e $f $g)) (route $x $a $b $c $d $e $f $g))
(= (prepend $x empty) empty)

; Path finding with cycle detection
; (path from to visited) returns route or empty
(= (path $x $x $v) (route $x))
(= (path $from $to $visited)
   (match &self (edge $from $next)
     (if (not-in $next $visited)
         (let $result (path $next $to (add-to $from $visited))
           (prepend $from $result))
         empty)))

; Find all non-empty paths
(= (find-paths $from $to)
   (let $p (path $from $to ())
     (if (== $p empty) (superpose ()) $p)))

; Test: all paths from corner 1 to corner 9
; !(find-paths 1 9)
; Returns multiple routes like:
;   (route 1 4 7 8 9)     - down, down, right, right
;   (route 1 2 5 8 9)     - right, down, down, right
;   (route 1 2 3 6 9)     - right, right, down, down
;   ... and more!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This showcases MeTTa's nondeterminism: instead of
; returning one path, we get ALL valid paths.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
