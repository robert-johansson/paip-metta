;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Blocks World
;
; Classic AI planning domain: stacking blocks on a table.
; Demonstrates GPS capabilities and limitations.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Include gps.metta for (solve goal)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simple Scenario: Three blocks on table
;
; Initial:  [A] [B] [C]
;           -----------
;              TABLE
;
; Goal: Stack A on B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(state a-on-table)
(state b-on-table)
(state c-on-table)
(state a-clear)
(state b-clear)
(state c-clear)

; Operators
(op put-a-on-b a-on-b (a-clear b-clear))
(op put-a-on-c a-on-c (a-clear c-clear))
(op put-b-on-a b-on-a (b-clear a-clear))
(op put-b-on-c b-on-c (b-clear c-clear))
(op put-c-on-a c-on-a (c-clear a-clear))
(op put-c-on-b c-on-b (c-clear b-clear))

; Test: put A on B
; !(solve a-on-b)
; Expected: (plan put-a-on-b)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Limitation: The Sussman Anomaly
;
; Our simple GPS doesn't track state changes from
; operator effects. In the full blocks world:
;
; Initial:  [C]
;           [A]  [B]
;           -----------
;
; Goal: A on B AND B on C
;
; This requires careful ordering:
; 1. Move C off A (clearing A)
; 2. Put B on C
; 3. Put A on B
;
; Simple GPS may fail because:
; - Achieving "A on B" first might interfere with "B on C"
; - Need to consider operator side-effects on other goals
;
; This is a known limitation that led to more sophisticated
; planners like STRIPS, Warplan, and modern PDDL planners.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; For MeTTa, a more complete solution would:
; 1. Track actual state changes in a space
; 2. Use nondeterminism to explore action orderings
; 3. Verify all goals satisfied at the end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
