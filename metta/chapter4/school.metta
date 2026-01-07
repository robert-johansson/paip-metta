;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GPS School Problem
; The classic "driving son to school" example
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Import GPS core (when running standalone, include gps.metta first)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Operators
;
; Each operator specifies:
; - The action name
; - The goal it achieves
; - The preconditions required
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(op look-up-number know-phone-number (have-phone-book))

(op telephone-shop in-communication-with-shop (know-phone-number))

(op tell-shop-problem shop-knows-problem (in-communication-with-shop))

(op give-shop-money shop-has-money (have-money))

(op shop-installs-battery car-works
    (car-needs-battery shop-knows-problem shop-has-money))

(op drive-son-to-school son-at-school
    (son-at-home car-works))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test 1: Full Problem
; Initial state: son at home, car needs battery, have money and phone book
; Goal: son at school
; Expected: 6-step plan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(state son-at-home)
(state car-needs-battery)
(state have-money)
(state have-phone-book)

!(assertEqual
  (solve son-at-school)
  (plan look-up-number telephone-shop tell-shop-problem
        give-shop-money shop-installs-battery drive-son-to-school))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test 2: Trivial Case
; To test: comment out states above, uncomment below
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; When car already works, should just need to drive
; (state son-at-home)
; (state car-works)
; Expected: (plan drive-son-to-school)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test 3: Failure Case
; To test: comment out have-phone-book
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Without phone book, can't look up number -> no solution
; Expected: [] (empty result)
