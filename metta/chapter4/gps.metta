;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GPS - General Problem Solver
; MeTTa Implementation
;
; A MeTTa-native implementation of GPS using backward
; chaining and pattern matching rather than explicit
; state manipulation.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Operator Definition Format
;
; Operators are defined as facts in the atomspace:
;   (op action-name goal (precond1 precond2 ...))
;
; This declares that action-name achieves goal when
; all preconditions are satisfied.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GPS Algorithm
;
; (gps goal accumulator) returns a plan to achieve goal
; - If goal is in current state, return accumulator
; - Otherwise, find an operator that achieves goal
; - Recursively achieve all preconditions
; - Add the action to the plan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Base case: goal already satisfied
(= (gps $goal $acc)
   (match &self (state $goal) $acc))

; Recursive case: 1 precondition
(= (gps $goal $acc)
   (match &self (op $action $goal ($r1))
     (let $acc1 (gps $r1 $acc)
       (add $acc1 $action))))

; Recursive case: 2 preconditions
(= (gps $goal $acc)
   (match &self (op $action $goal ($r1 $r2))
     (let* (($acc1 (gps $r1 $acc))
            ($acc2 (gps $r2 $acc1)))
       (add $acc2 $action))))

; Recursive case: 3 preconditions
(= (gps $goal $acc)
   (match &self (op $action $goal ($r1 $r2 $r3))
     (let* (($acc1 (gps $r1 $acc))
            ($acc2 (gps $r2 $acc1))
            ($acc3 (gps $r3 $acc2)))
       (add $acc3 $action))))

; Recursive case: 4 preconditions
(= (gps $goal $acc)
   (match &self (op $action $goal ($r1 $r2 $r3 $r4))
     (let* (($acc1 (gps $r1 $acc))
            ($acc2 (gps $r2 $acc1))
            ($acc3 (gps $r3 $acc2))
            ($acc4 (gps $r4 $acc3)))
       (add $acc4 $action))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Plan Construction
;
; Plans are tuples: (plan action1 action2 ...)
; The (add plan action) function appends an action
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (add (plan) $a) (plan $a))
(= (add (plan $a) $b) (plan $a $b))
(= (add (plan $a $b) $c) (plan $a $b $c))
(= (add (plan $a $b $c) $d) (plan $a $b $c $d))
(= (add (plan $a $b $c $d) $e) (plan $a $b $c $d $e))
(= (add (plan $a $b $c $d $e) $f) (plan $a $b $c $d $e $f))
(= (add (plan $a $b $c $d $e $f) $g) (plan $a $b $c $d $e $f $g))
(= (add (plan $a $b $c $d $e $f $g) $h) (plan $a $b $c $d $e $f $g $h))
(= (add (plan $a $b $c $d $e $f $g $h) $i) (plan $a $b $c $d $e $f $g $h $i))
(= (add (plan $a $b $c $d $e $f $g $h $i) $j) (plan $a $b $c $d $e $f $g $h $i $j))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Entry Point
;
; (solve goal) attempts to find a plan to achieve goal
; Returns (plan action1 action2 ...) or empty if no solution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (solve $goal) (gps $goal (plan)))
