;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generic Pattern Matcher
;
; A MeTTa implementation of pattern matching with explicit
; bindings, generalizing techniques from ELIZA (Chapter 5).
;
; While MeTTa has native pattern matching via `=` rules,
; an explicit pattern matcher is useful when:
; - You need to inspect or manipulate bindings
; - Patterns come from data (not code)
; - You want custom matching behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BINDINGS REPRESENTATION
;
; Bindings are stored as: (bindings (var1 val1) (var2 val2) ...)
; Special value `fail` indicates match failure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Look up a variable in bindings
(= (lookup $var (bindings)) not-found)
(= (lookup $var (bindings ($v $val)))
   (if (== $var $v) $val not-found))
(= (lookup $var (bindings ($v1 $b1) ($v2 $b2)))
   (if (== $var $v1) $b1
       (if (== $var $v2) $b2 not-found)))
(= (lookup $var (bindings ($v1 $b1) ($v2 $b2) ($v3 $b3)))
   (if (== $var $v1) $b1
       (if (== $var $v2) $b2
           (if (== $var $v3) $b3 not-found))))
(= (lookup $var (bindings ($v1 $b1) ($v2 $b2) ($v3 $b3) ($v4 $b4)))
   (if (== $var $v1) $b1
       (if (== $var $v2) $b2
           (if (== $var $v3) $b3
               (if (== $var $v4) $b4 not-found)))))

; Add a binding
(= (extend $var $val (bindings)) (bindings ($var $val)))
(= (extend $var $val (bindings ($v1 $b1)))
   (bindings ($var $val) ($v1 $b1)))
(= (extend $var $val (bindings ($v1 $b1) ($v2 $b2)))
   (bindings ($var $val) ($v1 $b1) ($v2 $b2)))
(= (extend $var $val (bindings ($v1 $b1) ($v2 $b2) ($v3 $b3)))
   (bindings ($var $val) ($v1 $b1) ($v2 $b2) ($v3 $b3)))
(= (extend $var $val (bindings ($v1 $b1) ($v2 $b2) ($v3 $b3) ($v4 $b4)))
   (bindings ($var $val) ($v1 $b1) ($v2 $b2) ($v3 $b3) ($v4 $b4)))

; Check if result is successful bindings
(= (is-success (bindings)) True)
(= (is-success (bindings $rest)) True)
(= (is-success fail) False)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CORE PATTERN MATCHER
;
; (pm pattern input bindings) -> bindings or fail
;
; Matches pattern against input, extending bindings.
; Returns fail if match is impossible.
;
; Pattern types:
; - (var $name): match anything, bind to $name
; - (lit $val): match literal exactly
; - ($p1 $p2 ...): match tuple element-by-element
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Variable matching with consistency check
(= (pm-var $name $input $bindings)
   (let $existing (lookup $name $bindings)
     (if (== $existing not-found)
         (extend $name $input $bindings)
         (if (== $existing $input) $bindings fail))))

; Variable pattern: (var name) matches anything
(= (pm (var $name) $input $bindings)
   (pm-var $name $input $bindings))

; Literal pattern: (lit value) matches exactly that value
(= (pm (lit $val) $input $bindings)
   (if (== $val $input) $bindings fail))

; 2-tuple pattern
(= (pm ($p1 $p2) ($i1 $i2) $bindings)
   (let $b1 (pm $p1 $i1 $bindings)
     (if (== $b1 fail) fail (pm $p2 $i2 $b1))))

; 3-tuple pattern
(= (pm ($p1 $p2 $p3) ($i1 $i2 $i3) $bindings)
   (let $b1 (pm $p1 $i1 $bindings)
     (if (== $b1 fail) fail
         (let $b2 (pm $p2 $i2 $b1)
           (if (== $b2 fail) fail (pm $p3 $i3 $b2))))))

; 4-tuple pattern
(= (pm ($p1 $p2 $p3 $p4) ($i1 $i2 $i3 $i4) $bindings)
   (let $b1 (pm $p1 $i1 $bindings)
     (if (== $b1 fail) fail
         (let $b2 (pm $p2 $i2 $b1)
           (if (== $b2 fail) fail
               (let $b3 (pm $p3 $i3 $b2)
                 (if (== $b3 fail) fail (pm $p4 $i4 $b3))))))))

; 5-tuple pattern
(= (pm ($p1 $p2 $p3 $p4 $p5) ($i1 $i2 $i3 $i4 $i5) $bindings)
   (let $b1 (pm $p1 $i1 $bindings)
     (if (== $b1 fail) fail
         (let $b2 (pm $p2 $i2 $b1)
           (if (== $b2 fail) fail
               (let $b3 (pm $p3 $i3 $b2)
                 (if (== $b3 fail) fail
                     (let $b4 (pm $p4 $i4 $b3)
                       (if (== $b4 fail) fail (pm $p5 $i5 $b4))))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ENTRY POINTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Basic pattern match
(= (match-pattern $pattern $input)
   (pm $pattern $input (bindings)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUBSTITUTION
;
; Replace variable patterns in a template with bound values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Substitute a single element
(= (subst-one (var $name) $bindings)
   (let $val (lookup $name $bindings)
     (if (== $val not-found) (var $name) $val)))
(= (subst-one (lit $val) $bindings) $val)
(= (subst-one $other $bindings) $other)

; Substitute in tuples (2 elements)
(= (substitute ($t1 $t2) $bindings)
   ((subst-one $t1 $bindings) (subst-one $t2 $bindings)))

; Substitute in tuples (3 elements)
(= (substitute ($t1 $t2 $t3) $bindings)
   ((subst-one $t1 $bindings) (subst-one $t2 $bindings)
    (subst-one $t3 $bindings)))

; Substitute in tuples (4 elements)
(= (substitute ($t1 $t2 $t3 $t4) $bindings)
   ((subst-one $t1 $bindings) (subst-one $t2 $bindings)
    (subst-one $t3 $bindings) (subst-one $t4 $bindings)))

; Substitute in tuples (5 elements)
(= (substitute ($t1 $t2 $t3 $t4 $t5) $bindings)
   ((subst-one $t1 $bindings) (subst-one $t2 $bindings)
    (subst-one $t3 $bindings) (subst-one $t4 $bindings)
    (subst-one $t5 $bindings)))

; Single element
(= (substitute $single $bindings)
   (subst-one $single $bindings))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RULE-BASED TRANSLATOR
;
; A rule is: (rule pattern response)
; The translator finds the first matching rule and
; substitutes bindings into the response.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Try to apply a single rule
(= (try-rule (rule $pattern $response) $input)
   (let $bindings (match-pattern $pattern $input)
     (if (== (is-success $bindings) True)
         (substitute $response $bindings)
         no-match)))

; Apply first matching rule from a list
(= (apply-rules $input ()) default-response)
(= (apply-rules $input ((rule $pat $resp) $rest))
   (let $result (try-rule (rule $pat $resp) $input)
     (if (== $result no-match)
         (apply-rules $input $rest)
         $result)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EXAMPLE: Simple Response Rules
;
; Note: Use (lit x) for literals, (var x) for variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Define rules as data
(= (response-rules)
   ((rule ((lit hello) (var x)) ((lit hi) (lit there) (var x)))
    (rule ((lit I) (lit am) (var mood)) ((lit why) (lit are) (lit you) (var mood)))
    (rule ((lit I) (lit want) (var thing)) ((lit what) (lit would) (lit it) (lit mean) (lit to) (lit get) (var thing)))
    (rule ((lit bye)) ((lit goodbye)))
    ()))

; Translate using the rules
(= (translate $input)
   (apply-rules $input (response-rules)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TESTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Basic variable matching
; !(match-pattern (var x) hello)
; ; => (bindings (x hello))

; !(match-pattern ((var a) (var b)) (x y))
; ; => (bindings (b y) (a x))

; ; Variable consistency - same var must match same value
; !(match-pattern ((var x) (var x)) (a a))
; ; => (bindings (x a))

; !(match-pattern ((var x) (var x)) (a b))
; ; => fail

; ; Literal matching
; !(match-pattern ((lit hello) (var who)) (hello world))
; ; => (bindings (who world))

; !(match-pattern ((lit hello) (var who)) (bye world))
; ; => fail

; ; Translation
; !(translate (hello friend))
; ; => (hi there friend)

; !(translate (I am happy))
; ; => (why are you happy)
