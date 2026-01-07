;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ELIZA: Pattern Matching Dialogue
;
; A MeTTa implementation of the classic ELIZA chatbot.
; Uses pattern matching with segment capture to simulate
; a Rogerian psychotherapist.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PATTERN MATCHERS
;
; Each keyword has pattern matchers for different sentence
; structures. Patterns capture:
; - The subject (word before keyword)
; - The segment after the keyword
;
; Format: (Match keyword subject after-segment)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; WANT patterns: "I want X", "you want X", etc.
(= (match-kw want ($s want)) (Match want $s ()))
(= (match-kw want ($s want $a)) (Match want $s ($a)))
(= (match-kw want ($s want $a $b)) (Match want $s ($a $b)))
(= (match-kw want ($s want $a $b $c)) (Match want $s ($a $b $c)))
(= (match-kw want ($s want $a $b $c $d)) (Match want $s ($a $b $c $d)))
(= (match-kw want ($x $s want)) (Match want $s ()))
(= (match-kw want ($x $s want $a)) (Match want $s ($a)))
(= (match-kw want ($x $s want $a $b)) (Match want $s ($a $b)))
(= (match-kw want ($x $s want $a $b $c)) (Match want $s ($a $b $c)))

; NEED patterns
(= (match-kw need ($s need)) (Match need $s ()))
(= (match-kw need ($s need $a)) (Match need $s ($a)))
(= (match-kw need ($s need $a $b)) (Match need $s ($a $b)))
(= (match-kw need ($s need $a $b $c)) (Match need $s ($a $b $c)))
(= (match-kw need ($x $s need $a)) (Match need $s ($a)))
(= (match-kw need ($x $s need $a $b)) (Match need $s ($a $b)))

; FEEL patterns
(= (match-kw feel ($s feel)) (Match feel $s ()))
(= (match-kw feel ($s feel $a)) (Match feel $s ($a)))
(= (match-kw feel ($s feel $a $b)) (Match feel $s ($a $b)))
(= (match-kw feel ($s feel $a $b $c)) (Match feel $s ($a $b $c)))
(= (match-kw feel ($x $s feel)) (Match feel $s ()))
(= (match-kw feel ($x $s feel $a)) (Match feel $s ($a)))
(= (match-kw feel ($x $s feel $a $b)) (Match feel $s ($a $b)))

; THINK patterns
(= (match-kw think ($s think)) (Match think $s ()))
(= (match-kw think ($s think $a)) (Match think $s ($a)))
(= (match-kw think ($s think $a $b)) (Match think $s ($a $b)))
(= (match-kw think ($s think $a $b $c)) (Match think $s ($a $b $c)))
(= (match-kw think ($x $s think $a)) (Match think $s ($a)))
(= (match-kw think ($x $s think $a $b)) (Match think $s ($a $b)))

; REMEMBER patterns
(= (match-kw remember ($s remember)) (Match remember $s ()))
(= (match-kw remember ($s remember $a)) (Match remember $s ($a)))
(= (match-kw remember ($s remember $a $b)) (Match remember $s ($a $b)))
(= (match-kw remember ($s remember $a $b $c)) (Match remember $s ($a $b $c)))
(= (match-kw remember ($x $s remember $a)) (Match remember $s ($a)))

; DREAM patterns
(= (match-kw dream ($s dream)) (Match dream $s ()))
(= (match-kw dream ($s dream $a)) (Match dream $s ($a)))
(= (match-kw dream ($s dream $a $b)) (Match dream $s ($a $b)))
(= (match-kw dream ($s dreamed $a)) (Match dream $s ($a)))
(= (match-kw dream ($s dreamed $a $b)) (Match dream $s ($a $b)))
(= (match-kw dream ($x $s dream $a)) (Match dream $s ($a)))

; MOTHER patterns
(= (match-kw mother ($s mother)) (Match mother $s ()))
(= (match-kw mother ($s mother $a)) (Match mother $s ($a)))
(= (match-kw mother ($s mother $a $b)) (Match mother $s ($a $b)))
(= (match-kw mother ($s mother $a $b $c)) (Match mother $s ($a $b $c)))
(= (match-kw mother ($x $s mother)) (Match mother $s ()))
(= (match-kw mother ($x $s mother $a)) (Match mother $s ($a)))
(= (match-kw mother ($x $s mother $a $b)) (Match mother $s ($a $b)))

; FATHER patterns
(= (match-kw father ($s father)) (Match father $s ()))
(= (match-kw father ($s father $a)) (Match father $s ($a)))
(= (match-kw father ($s father $a $b)) (Match father $s ($a $b)))
(= (match-kw father ($x $s father)) (Match father $s ()))
(= (match-kw father ($x $s father $a)) (Match father $s ($a)))

; SORRY patterns
(= (match-kw sorry ($a sorry)) (Match sorry () ()))
(= (match-kw sorry ($a sorry $b)) (Match sorry () ($b)))
(= (match-kw sorry (sorry $a)) (Match sorry () ($a)))
(= (match-kw sorry (sorry)) (Match sorry () ()))

; HELLO patterns
(= (match-kw hello (hello)) (Match hello () ()))
(= (match-kw hello (hello $a)) (Match hello () ($a)))
(= (match-kw hello (hello $a $b)) (Match hello () ($a $b)))
(= (match-kw hello (hi)) (Match hello () ()))
(= (match-kw hello (hi $a)) (Match hello () ($a)))

; COMPUTER patterns
(= (match-kw computer ($a computer)) (Match computer () ()))
(= (match-kw computer ($a computer $b)) (Match computer () ($b)))
(= (match-kw computer ($a computers $b)) (Match computer () ($b)))
(= (match-kw computer ($a $b computer)) (Match computer () ()))
(= (match-kw computer ($a $b computers)) (Match computer () ()))

; AM/ARE patterns for "I am X" / "you are X"
(= (match-kw am (I am)) (Match am I ()))
(= (match-kw am (I am $a)) (Match am I ($a)))
(= (match-kw am (I am $a $b)) (Match am I ($a $b)))
(= (match-kw am (I am $a $b $c)) (Match am I ($a $b $c)))
(= (match-kw am (am I $a)) (Match am-question I ($a)))
(= (match-kw am (am I $a $b)) (Match am-question I ($a $b)))

; YES/NO patterns
(= (match-kw yes (yes)) (Match yes () ()))
(= (match-kw yes (yes $a)) (Match yes () ($a)))
(= (match-kw yes (yes $a $b)) (Match yes () ($a $b)))
(= (match-kw no (no)) (Match no () ()))
(= (match-kw no (no $a)) (Match no () ($a)))
(= (match-kw no (no $a $b)) (Match no () ($a $b)))

; WHY patterns
(= (match-kw why (why)) (Match why () ()))
(= (match-kw why (why $a)) (Match why () ($a)))
(= (match-kw why (why $a $b)) (Match why () ($a $b)))
(= (match-kw why (why $a $b $c)) (Match why () ($a $b $c)))
(= (match-kw why ($x why $a)) (Match why () ($a)))

; BECAUSE patterns
(= (match-kw because ($a because)) (Match because () ()))
(= (match-kw because ($a because $b)) (Match because () ($b)))
(= (match-kw because ($a because $b $c)) (Match because () ($b $c)))
(= (match-kw because (because $a)) (Match because () ($a)))

; ALWAYS patterns
(= (match-kw always ($a always)) (Match always () ()))
(= (match-kw always ($a always $b)) (Match always () ($b)))
(= (match-kw always (always $a)) (Match always () ($a)))

; EVERYONE patterns
(= (match-kw everyone ($a everyone $b)) (Match everyone () ($b)))
(= (match-kw everyone (everyone $a)) (Match everyone () ($a)))

; ALIKE/SAME patterns
(= (match-kw alike ($a alike)) (Match alike () ()))
(= (match-kw alike ($a alike $b)) (Match alike () ($b)))
(= (match-kw alike ($a same)) (Match alike () ()))
(= (match-kw alike ($a same $b)) (Match alike () ($b)))

; LIKE patterns (for "is like" comparisons)
(= (match-kw like ($a like $b)) (Match like ($a) ($b)))
(= (match-kw like ($a like $b $c)) (Match like ($a) ($b $c)))
(= (match-kw like ($a $b like $c)) (Match like ($a $b) ($c)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MATCH DETECTION AND FILTERING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Predicate to check if result is a valid Match
(= (is-match (Match $kw $s $a)) True)

; Try all keyword patterns against a sentence
(= (try-all-keywords $sent)
   (let $r (superpose (
     (match-kw want $sent)
     (match-kw need $sent)
     (match-kw feel $sent)
     (match-kw think $sent)
     (match-kw remember $sent)
     (match-kw dream $sent)
     (match-kw mother $sent)
     (match-kw father $sent)
     (match-kw sorry $sent)
     (match-kw hello $sent)
     (match-kw computer $sent)
     (match-kw am $sent)
     (match-kw yes $sent)
     (match-kw no $sent)
     (match-kw why $sent)
     (match-kw because $sent)
     (match-kw always $sent)
     (match-kw everyone $sent)
     (match-kw alike $sent)
     (match-kw like $sent)
   ))
   (if (== (is-match $r) True) $r (superpose ()))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RESPONSE GENERATION
;
; Each keyword has one or more response templates.
; The captured $after segment is substituted into responses.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; WANT responses
(= (respond (Match want $subj $after))
   (superpose (
     (Why do you want $after)
     (What would it mean if you got $after)
     (Suppose you got $after soon)
   )))

; NEED responses
(= (respond (Match need $subj $after))
   (superpose (
     (Why do you need $after)
     (Would it really help you to get $after)
     (Are you sure you need $after)
   )))

; FEEL responses
(= (respond (Match feel $subj $after))
   (superpose (
     (Do you often feel $after)
     (What other feelings do you have)
     (Tell me more about feeling $after)
   )))

; THINK responses
(= (respond (Match think $subj $after))
   (superpose (
     (Do you really think so)
     (But you are not sure $after)
     (Why do you think $after)
   )))

; REMEMBER responses
(= (respond (Match remember $subj $after))
   (superpose (
     (Do you often think of $after)
     (Does thinking of $after bring anything else to mind)
     (Why do you remember $after right now)
   )))

; DREAM responses
(= (respond (Match dream $subj $after))
   (superpose (
     (What does that dream suggest to you)
     (Do you dream often)
     (What persons appear in your dreams)
   )))

; MOTHER responses
(= (respond (Match mother $subj $after))
   (superpose (
     (Tell me more about your family)
     (Who else in your family $after)
     (Your mother)
   )))

; FATHER responses
(= (respond (Match father $subj $after))
   (superpose (
     (Your father)
     (Does he influence you strongly)
     (Tell me more about your father)
   )))

; SORRY responses
(= (respond (Match sorry $subj $after))
   (superpose (
     (Please do not apologize)
     (Apologies are not necessary)
     (What feelings do you have when you apologize)
   )))

; HELLO responses
(= (respond (Match hello $subj $after))
   (superpose (
     (How do you do - please state your problem)
     (Hello - what brings you here today)
   )))

; COMPUTER responses
(= (respond (Match computer $subj $after))
   (superpose (
     (Do computers worry you)
     (Why do you mention computers)
     (What do you think machines have to do with your problem)
   )))

; AM responses (I am X)
(= (respond (Match am $subj $after))
   (superpose (
     (In what way are you $after)
     (Do you want to be $after)
     (How long have you been $after)
   )))

; AM-QUESTION responses (am I X?)
(= (respond (Match am-question $subj $after))
   (superpose (
     (Do you believe you are $after)
     (Would you want to be $after)
     (What would it mean if you were $after)
   )))

; YES responses
(= (respond (Match yes $subj $after))
   (superpose (
     (You seem quite positive)
     (You are sure)
     (I see)
   )))

; NO responses
(= (respond (Match no $subj $after))
   (superpose (
     (Why not)
     (You are being a bit negative)
     (Are you saying no just to be negative)
   )))

; WHY responses
(= (respond (Match why $subj $after))
   (superpose (
     (Why do you ask)
     (Does that question interest you)
     (What do you think)
   )))

; BECAUSE responses
(= (respond (Match because $subj $after))
   (superpose (
     (Is that the real reason)
     (What other reasons might there be)
     (Does that reason seem to explain anything else)
   )))

; ALWAYS responses
(= (respond (Match always $subj $after))
   (superpose (
     (Can you think of a specific example)
     (When)
     (Really - always)
   )))

; EVERYONE responses
(= (respond (Match everyone $subj $after))
   (superpose (
     (Surely not everyone)
     (Can you think of anyone in particular)
     (Who for example)
   )))

; ALIKE/SAME responses
(= (respond (Match alike $subj $after))
   (superpose (
     (In what way)
     (What similarities are there)
     (What other connections do you see)
   )))

; LIKE responses (comparisons)
(= (respond (Match like $before $after))
   (superpose (
     (In what way is $before like $after)
     (What resemblance do you see)
     (Could there really be some connection)
   )))

; DEFAULT responses (when no keyword matches)
(= (respond-default)
   (superpose (
     (Please go on)
     (Very interesting)
     (I see)
     (Tell me more)
     (Can you elaborate on that)
   )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN ELIZA FUNCTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Get the first matching keyword's response, or default
(= (eliza $sent)
   (let $matches (collapse (try-all-keywords $sent))
     (if (== $matches ())
         (respond-default)
         (respond (car-atom $matches)))))

; Alternative: get ALL responses (nondeterministic)
(= (eliza-all $sent)
   (let $matches (collapse (try-all-keywords $sent))
     (if (== $matches ())
         (respond-default)
         (let $m (superpose $matches)
           (respond $m)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TESTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Uncomment to run tests:
; !(eliza (hello there))
; !(eliza (I want to be happy))
; !(eliza (I feel sad today))
; !(eliza (my mother is very kind))
; !(eliza (I remember my childhood))
; !(eliza (I dream about flying))
; !(eliza (I am confused))
; !(eliza (do computers worry you))
; !(eliza (nice weather today))
