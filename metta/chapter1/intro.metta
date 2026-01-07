;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PAIP-MeTTa Chapter 1: Introduction to MeTTa
; Runnable examples from the chapter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1.0 Basic Arithmetic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!(assertEqual (+ 2 2) 4)
!(assertEqual (* 3 4) 12)
!(assertEqual (- 10 3) 7)

; Chaining binary operations
!(assertEqual (+ 1 (+ 2 (+ 3 4))) 10)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1.1 Symbolic Computation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Facts in the Atomspace
(Sam is a frog)
(Tom is a cat)
(Sophia is a robot)

; Pattern matching query
!(assertEqualToResult
  (match &self ($who is a $what) ($who the $what))
  ((Sam the frog) (Tom the cat) (Sophia the robot)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1.2 Variables and let bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!(assertEqual
  (let $x (+ 1 2) (* $x $x))
  9)

!(assertEqual
  (let* (($a 1) ($b 2) ($c (+ $a $b)))
    (* $c $c))
  9)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1.3 Function Definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (square $x) (* $x $x))
(= (double $x) (+ $x $x))

!(assertEqual (square 5) 25)
!(assertEqual (double 7) 14)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1.4 Lists with Cons/Nil
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(: Nil (List $t))
(: Cons (-> $t (List $t) (List $t)))

(= (first (Cons $h $t)) $h)
(= (rest (Cons $h $t)) $t)

!(assertEqual
  (first (Cons a (Cons b (Cons c Nil))))
  a)

!(assertEqual
  (rest (Cons a (Cons b (Cons c Nil))))
  (Cons b (Cons c Nil)))

; Length function
(= (length Nil) 0)
(= (length (Cons $x $xs)) (+ 1 (length $xs)))

!(assertEqual
  (length (Cons a (Cons b (Cons c Nil))))
  3)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1.5 Last element
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (last (Cons $x Nil)) $x)
(= (last (Cons $x $xs)) (last $xs))

!(assertEqual
  (last (Cons John (Cons Q (Cons Public Nil))))
  Public)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1.6 Nondeterminism
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (color) red)
(= (color) green)
(= (color) blue)

; All colors are returned
!(assertEqualToResult
  (color)
  (red green blue))

; Collapse collects into a tuple
!(assertEqual
  (collapse (color))
  (red green blue))

; Superpose expands a tuple
!(assertEqualToResult
  (superpose (a b c))
  (a b c))

; Combining nondeterministic values
(= (coin) heads)
(= (coin) tails)

!(assertEqualToResult
  ((coin) (coin))
  ((heads heads) (heads tails) (tails heads) (tails tails)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1.7 Higher-Order Functions: map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (map $f Nil) Nil)
(= (map $f (Cons $x $xs)) (Cons ($f $x) (map $f $xs)))

(= (inc $x) (+ $x 1))

!(assertEqual
  (map inc (Cons 1 (Cons 2 (Cons 3 Nil))))
  (Cons 2 (Cons 3 (Cons 4 Nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1.8 Types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(: Z Nat)
(: S (-> Nat Nat))
(: add (-> Nat Nat Nat))

(= (add $x Z) $x)
(= (add $x (S $y)) (S (add $x $y)))

; 1 + 2 = 3 in Peano arithmetic
!(assertEqual
  (add (S Z) (S (S Z)))
  (S (S (S Z))))

!(assertEqual (get-type (S Z)) Nat)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Exercise Solutions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Exercise 1.1: sum-list
(= (sum-list Nil) 0)
(= (sum-list (Cons $x $xs)) (+ $x (sum-list $xs)))

!(assertEqual
  (sum-list (Cons 1 (Cons 2 (Cons 3 Nil))))
  6)

; Exercise 1.3: append
(= (append Nil $ys) $ys)
(= (append (Cons $x $xs) $ys) (Cons $x (append $xs $ys)))

!(assertEqual
  (append (Cons 1 (Cons 2 Nil)) (Cons 3 (Cons 4 Nil)))
  (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))

; Exercise 1.4: reverse
(= (reverse Nil) Nil)
(= (reverse (Cons $x $xs)) (append (reverse $xs) (Cons $x Nil)))

!(assertEqual
  (reverse (Cons 1 (Cons 2 (Cons 3 Nil))))
  (Cons 3 (Cons 2 (Cons 1 Nil))))

; Exercise 1.5: pairs with nondeterminism
(= (xs) (superpose (1 2 3)))
(= (ys) (superpose (a b)))
(= (pairs) ((xs) (ys)))

!(assertEqualToResult
  (pairs)
  ((1 a) (1 b) (2 a) (2 b) (3 a) (3 b)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; All tests passed!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
