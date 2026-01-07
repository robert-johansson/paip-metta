;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PAIP-MeTTa Chapter 1: Introduction to MeTTa
; Runnable examples from the chapter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Basic Arithmetic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!(assertEqual (+ 2 2) 4)
!(assertEqual (+ 1 (+ 2 (+ 3 4))) 10)
!(assertEqual (- (+ 9000 900) (+ 5000 500)) 4400)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Symbolic Computation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(Sam is a frog)
(Tom is a cat)
(Sophia is a robot)

!(assertEqualToResult
  (match &self ($who is a $what) ($who the $what))
  ((Sam the frog) (Tom the cat) (Sophia the robot)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables and let bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!(assertEqual (let $x (+ 1 2) (* $x $x)) 9)

!(assertEqual
  (let* (($a 1) ($b 2) ($c (+ $a $b))) (* $c $c))
  9)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; List Type and Operations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(: Nil (List $t))
(: Cons (-> $t (List $t) (List $t)))

(= (first (Cons $h $t)) $h)
(= (rest (Cons $h $t)) $t)

; last: explicit patterns to avoid overlap
(= (last (Cons $x Nil)) $x)
(= (last (Cons $h (Cons $x $xs))) (last (Cons $x $xs)))

!(assertEqual (first (Cons John (Cons Q (Cons Public Nil)))) John)
!(assertEqual (last (Cons John (Cons Q (Cons Public Nil)))) Public)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Length function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (length Nil) 0)
(= (length (Cons $x $xs)) (+ 1 (length $xs)))

!(assertEqual (length (Cons a (Cons b (Cons c Nil)))) 3)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Map function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (map $f Nil) Nil)
(= (map $f (Cons $x $xs)) (Cons ($f $x) (map $f $xs)))

(= (inc $x) (+ $x 1))

!(assertEqual
  (map inc (Cons 1 (Cons 2 (Cons 3 Nil))))
  (Cons 2 (Cons 3 (Cons 4 Nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Member function (using if to avoid pattern overlap)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (member $x Nil) False)
(= (member $x (Cons $h $rest))
   (if (== $x $h)
       True
       (member $x $rest)))

!(assertEqual (member Q (Cons John (Cons Q (Cons Public Nil)))) True)
!(assertEqual (member Bob (Cons John (Cons Q (Cons Public Nil)))) False)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Nondeterminism
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= (color) red)
(= (color) green)
(= (color) blue)

!(assertEqualToResult (color) (red green blue))
!(assertEqual (collapse (color)) (red green blue))

; Combining nondeterministic values
(= (coin) heads)
(= (coin) tails)

!(assertEqualToResult
  ((coin) (coin))
  ((heads heads) (heads tails) (tails heads) (tails tails)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Higher-Order Functions: lambda
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(= ((lambda $var $body) $arg) (let $var $arg $body))

!(assertEqual ((lambda $x (+ $x 1)) 5) 6)
!(assertEqual ((lambda $x (* $x $x)) 4) 16)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(: Z Nat)
(: S (-> Nat Nat))
(: add (-> Nat Nat Nat))

(= (add $x Z) $x)
(= (add $x (S $y)) (S (add $x $y)))

!(assertEqual (add (S Z) (S (S Z))) (S (S (S Z))))
!(assertEqual (get-type (S Z)) Nat)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Exercise Answers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Exercise 1.1: append
(= (append Nil $ys) $ys)
(= (append (Cons $x $xs) $ys) (Cons $x (append $xs $ys)))

!(assertEqual
  (append (Cons a (Cons b Nil)) (Cons c (Cons d Nil)))
  (Cons a (Cons b (Cons c (Cons d Nil)))))

; Exercise 1.2: reverse
(= (reverse Nil) Nil)
(= (reverse (Cons $x $xs)) (append (reverse $xs) (Cons $x Nil)))

!(assertEqual
  (reverse (Cons a (Cons b (Cons c Nil))))
  (Cons c (Cons b (Cons a Nil))))

; Exercise 1.4: pairs with nondeterminism
(= (xs) (superpose (1 2 3)))
(= (ys) (superpose (a b)))
(= (pairs) ((xs) (ys)))

!(assertEqualToResult (pairs) ((1 a) (1 b) (2 a) (2 b) (3 a) (3 b)))

; Exercise 1.5: sum-list
(= (sum-list Nil) 0)
(= (sum-list (Cons $x $xs)) (+ $x (sum-list $xs)))

!(assertEqual (sum-list (Cons 1 (Cons 2 (Cons 3 Nil)))) 6)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; All tests passed!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
