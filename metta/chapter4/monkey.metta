;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Monkey and Bananas Problem
;
; Classic AI planning puzzle: A monkey in a room wants to
; eat bananas hanging from the ceiling. The monkey must
; push a chair under the bananas, climb on it, and grasp
; them.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Import GPS core (when running standalone, include gps.metta first)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initial State
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(state at-door)         ; Monkey starts at the door
(state on-floor)        ; Monkey is on the floor
(state empty-handed)    ; Monkey is not holding anything

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Operators
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Walk from door to middle of room (where chair is)
(op walk-to-chair at-middle-of-room (at-door on-floor))

; Push chair from middle to under bananas
(op push-chair chair-at-bananas (at-middle-of-room on-floor))

; Climb onto chair (requires chair to be under bananas)
(op climb-on-chair on-chair (chair-at-bananas on-floor))

; Grasp the bananas (requires being on chair and empty handed)
(op grasp-bananas have-bananas (on-chair empty-handed))

; Eat the bananas
(op eat-bananas satisfied (have-bananas))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!(assertEqual
  (solve satisfied)
  (plan walk-to-chair push-chair climb-on-chair grasp-bananas eat-bananas))
