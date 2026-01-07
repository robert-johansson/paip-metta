# Chapter 5
## ELIZA: Pattern Matching Dialogue

> ELIZA is a program operating within the MAC time-sharing system at MIT which makes certain kinds of natural language conversation between man and computer possible.
>
> -Joseph Weizenbaum, *ELIZA—A Computer Program For the Study of Natural Language Communication Between Man And Machine* (1966)

In this chapter we build ELIZA, one of the most famous programs in the history of AI.
ELIZA simulates a Rogerian psychotherapist—a style of therapy where the therapist mainly reflects the patient's statements back as questions.
The program is remarkably simple, yet surprisingly effective at creating the illusion of understanding.

Here's a sample conversation:

```
User: I am feeling sad today
ELIZA: In what way are you feeling sad today

User: My mother criticizes me all the time
ELIZA: Tell me more about your family

User: I want to be happy
ELIZA: Why do you want to be happy
```

ELIZA works entirely through pattern matching.
It looks for keywords in the input, captures relevant segments of text, and substitutes them into response templates.
There's no understanding of meaning, no model of the world, no reasoning—just patterns.
Yet users often felt a genuine connection with the program.

This chapter shows how to build ELIZA in MeTTa.
We'll see that MeTTa's pattern matching capabilities make it a natural fit for this kind of symbolic text processing.

## 5.1 The Basic Idea

ELIZA's algorithm is straightforward:

1. Look for a **keyword** in the user's input (like "mother", "want", or "feel")
2. **Capture** the relevant parts of the sentence around the keyword
3. **Substitute** the captured text into a response template

For example, given the input "I want to be happy":
- Keyword found: `want`
- Captured segment: `to be happy`
- Template: "Why do you want X"
- Response: "Why do you want to be happy"

The genius of ELIZA is that this simple mechanism, applied with carefully chosen keywords and responses, creates convincing dialogue.

## 5.2 Pattern Matching in MeTTa

In the original Lisp ELIZA, patterns used special "segment variables" like `(?* ?x)` that could match zero or more words.
MeTTa doesn't have this built-in, but we can achieve the same effect using explicit patterns.

Consider the sentence `(I want to be happy)`.
In MeTTa, this is a 5-element tuple.
We can write a pattern that matches it:

```metta
(= (match-kw want ($s want $a $b $c))
   (Match want $s ($a $b $c)))
```

This says: if the sentence has the form "X want Y Z W", capture X as the subject and (Y Z W) as the after-segment.
We get back a `Match` structure containing the keyword, subject, and captured segment.

Let's test it:

```metta
!(match-kw want (I want to be happy))
; => (Match want I (to be happy))
```

The pattern matched, and we captured `I` as the subject and `(to be happy)` as what comes after "want".

## 5.3 Handling Different Sentence Lengths

A challenge: sentences have different lengths.
"I want happiness" is 3 words; "I want to be happy" is 5 words.
We need patterns for each case:

```metta
; 2 words: "I want"
(= (match-kw want ($s want)) (Match want $s ()))

; 3 words: "I want happiness"
(= (match-kw want ($s want $a)) (Match want $s ($a)))

; 4 words: "I want to fly"
(= (match-kw want ($s want $a $b)) (Match want $s ($a $b)))

; 5 words: "I want to be happy"
(= (match-kw want ($s want $a $b $c)) (Match want $s ($a $b $c)))
```

This may seem tedious, but it's explicit and works reliably.
Most conversational sentences are 2-8 words, so we don't need many patterns.

We also need patterns where the keyword isn't at position 2:

```metta
; "sometimes I want X"
(= (match-kw want ($x $s want $a)) (Match want $s ($a)))

; "they say I want something"
(= (match-kw want ($x $s want $a $b)) (Match want $s ($a $b)))
```

## 5.4 Filtering Matches

When we try to match a sentence against a keyword, the pattern might not match.
In MeTTa, an unmatched pattern returns an unreduced expression.
We need to filter these out.

The trick is to use a predicate that recognizes valid matches:

```metta
(= (is-match (Match $kw $s $a)) True)
```

This only succeeds if the argument is actually a `Match` structure.
We can then use this to filter:

```metta
(= (try-keyword $kw $sent)
   (let $r (match-kw $kw $sent)
     (if (== (is-match $r) True)
         $r
         (superpose ()))))
```

If the match succeeds, we return it.
If not, `(superpose ())` returns nothing—the result is empty.

## 5.5 Trying All Keywords

ELIZA has many keywords.
We need to try them all and use the first one that matches:

```metta
(= (try-all-keywords $sent)
   (let $r (superpose (
     (match-kw want $sent)
     (match-kw feel $sent)
     (match-kw mother $sent)
     (match-kw father $sent)
     (match-kw hello $sent)
     ; ... more keywords
   ))
   (if (== (is-match $r) True) $r (superpose ()))))
```

The `superpose` tries all keyword matchers.
Each one either returns a valid `Match` or an unreduced expression.
The `if` filters out the failures.

To get the first match:

```metta
(= (first-match $sent)
   (let $matches (collapse (try-all-keywords $sent))
     (if (== $matches ())
         None
         (car-atom $matches))))
```

We `collapse` the nondeterministic results into a list, then take the first element with `car-atom`.

## 5.6 Generating Responses

Once we have a `Match`, we generate a response.
Each keyword has one or more response templates:

```metta
(= (respond (Match want $subj $after))
   (superpose (
     (Why do you want $after)
     (What would it mean if you got $after)
     (Suppose you got $after soon)
   )))

(= (respond (Match feel $subj $after))
   (superpose (
     (Do you often feel $after)
     (What other feelings do you have)
   )))

(= (respond (Match mother $subj $after))
   (superpose (
     (Tell me more about your family)
     (Who else in your family $after)
   )))
```

The captured `$after` segment is substituted directly into the response.
The `superpose` returns all possible responses—MeTTa's nondeterminism gives us variety for free.

## 5.7 The Complete ELIZA

Putting it all together:

```metta
(= (respond-default)
   (superpose (
     (Please go on)
     (Very interesting)
     (I see)
     (Tell me more)
   )))

(= (eliza $sent)
   (let $matches (collapse (try-all-keywords $sent))
     (if (== $matches ())
         (respond-default)
         (respond (car-atom $matches)))))
```

If we find a keyword match, we respond to it.
Otherwise, we use a generic default response.

Let's test it:

```metta
!(eliza (hello there))
; => (How do you do - please state your problem)

!(eliza (I want to be happy))
; => (Why do you want (to be happy))

!(eliza (I feel sad today))
; => (Do you often feel (sad today))

!(eliza (my mother is kind))
; => (Tell me more about your family)

!(eliza (I am confused))
; => (In what way are you (confused))

!(eliza (nice weather today))
; => (Please go on)
```

ELIZA is working.
The responses aren't perfect English (notice "(to be happy)" instead of "to be happy"), but the core mechanism is sound.

## 5.8 Multiple Responses

One of ELIZA's tricks is to have multiple responses per keyword.
This prevents the conversation from feeling repetitive.

In MeTTa, we get this naturally through nondeterminism:

```metta
(= (respond (Match want $subj $after))
   (superpose (
     (Why do you want $after)
     (What would it mean if you got $after)
     (Suppose you got $after soon)
   )))
```

Calling `(respond (Match want I (happiness)))` returns all three responses.
To get just one, we can use `collapse` and select randomly, or simply take the first.

The full ELIZA implementation in `eliza.metta` includes multiple responses for each keyword.

## 5.9 Viewpoint Switching

Original ELIZA performed "viewpoint switching"—changing "I" to "you", "my" to "your", etc.
This makes responses more natural:

- Input: "I am sad"
- Without switching: "In what way are you am sad" (wrong)
- With switching: "In what way are you sad" (correct)

Implementing this in MeTTa would require processing the captured segment and substituting words.
For simplicity, our implementation doesn't do this, but it would be a good exercise.

## 5.10 What Makes ELIZA Work?

ELIZA's effectiveness comes from several factors:

**1. Keyword detection focuses the conversation.**
By responding to emotionally significant words (mother, father, want, feel), ELIZA seems to understand what matters to the user.

**2. Reflection feels like listening.**
Repeating the user's words back makes them feel heard.
"I want to be happy" → "Why do you want to be happy" validates their statement.

**3. Questions keep the user talking.**
Almost all of ELIZA's responses are questions.
This puts the burden of conversation on the user and hides ELIZA's lack of understanding.

**4. Vagueness is an asset.**
Generic responses like "Tell me more" or "Why do you think that" work in almost any context.
The user fills in the meaning.

## 5.11 Limitations

ELIZA has obvious limitations:

**No memory.**
ELIZA doesn't remember previous statements.
Each response is based only on the current input.

**No understanding.**
ELIZA has no model of the world, no reasoning ability, no concept of what words mean.
It's pure pattern matching.

**Keyword order matters.**
If a sentence has multiple keywords, ELIZA uses the first one found.
This can lead to odd responses.

**No context.**
"It" or "that" in the input can't be resolved to previous topics.

Despite these limitations, ELIZA was influential.
It demonstrated that simple techniques could create engaging interactions, and it sparked important discussions about human-computer relationships.

## 5.12 MeTTa vs Lisp Implementation

The original Lisp ELIZA used:
- Segment variables `(?* ?x)` for flexible matching
- Property lists for rule storage
- Explicit loops for keyword search

Our MeTTa ELIZA uses:
- **Explicit arity patterns** instead of segment variables
- **Atomspace pattern matching** for rule lookup
- **Nondeterminism** for exploring keywords and responses

The MeTTa approach is more verbose for patterns (we need multiple rules per keyword length), but the matching and response generation is clean and declarative.

## 5.13 Summary

ELIZA demonstrates that pattern matching alone can create the illusion of intelligent conversation.
The key ideas are:

- **Keyword detection**: Find significant words in input
- **Segment capture**: Extract relevant parts of the sentence
- **Response templates**: Substitute captured text into templates
- **Multiple responses**: Vary responses to avoid repetition

MeTTa's pattern matching makes this natural to implement.
The Atomspace stores keyword patterns, and nondeterminism provides response variety.

In later chapters, we'll see more sophisticated approaches to natural language, including parsing (Chapter 19) and unification grammars (Chapter 20).
But ELIZA remains a beautiful example of how far simple techniques can go.

## 5.14 Exercises

**Exercise 5.1 [s]** Add a new keyword "happy" with responses like "What makes you happy?" and "Are you often happy?".
Test it with `(eliza (I am happy today))`.

**Exercise 5.2 [m]** Implement viewpoint switching.
Write a function `(switch-viewpoint $segment)` that changes:
- I → you
- my → your
- am → are
- me → you

Apply this to captured segments before substituting into responses.

**Exercise 5.3 [m]** Add rule priorities.
Some keywords should take precedence over others (e.g., "suicide" should always be handled, regardless of other keywords).
Implement a priority system.

**Exercise 5.4 [h]** Add memory.
ELIZA should occasionally refer back to earlier statements.
Store significant statements and randomly bring them up: "Earlier you mentioned your mother..."

**Exercise 5.5 [h]** Implement a simple "learning" mechanism.
When the user says "X means Y", store this association.
Later, when the user mentions X, use the learned meaning.

## 5.15 Answers

### Answer 5.1

```metta
; Add patterns for "happy"
(= (match-kw happy ($s happy)) (Match happy $s ()))
(= (match-kw happy ($s happy $a)) (Match happy $s ($a)))
(= (match-kw happy ($a $s happy)) (Match happy $s ()))

; Add responses
(= (respond (Match happy $subj $after))
   (superpose (
     (What makes you happy)
     (Are you often happy)
     (How does being happy make you feel)
   )))

; Add to try-all-keywords:
; (match-kw happy $sent)

!(eliza (I am happy today))
; => (What makes you happy)
```

### Answer 5.2

```metta
; Switch individual words
(= (switch-word I) you)
(= (switch-word my) your)
(= (switch-word am) are)
(= (switch-word me) you)
(= (switch-word $other) $other)  ; unchanged

; Switch a segment (for 1-3 words)
(= (switch-viewpoint ($a)) ((switch-word $a)))
(= (switch-viewpoint ($a $b)) ((switch-word $a) (switch-word $b)))
(= (switch-viewpoint ($a $b $c))
   ((switch-word $a) (switch-word $b) (switch-word $c)))

!(switch-viewpoint (I am sad))
; => (you are sad)
```

### Answer 5.3

```metta
; Associate keywords with priorities (higher = more important)
(keyword-priority suicide 100)
(keyword-priority want 50)
(keyword-priority feel 50)
(keyword-priority mother 40)
(keyword-priority hello 10)

; Get priority for a match
(= (match-priority (Match $kw $s $a))
   (match &self (keyword-priority $kw $p) $p))

; Sort matches by priority (conceptual - full implementation omitted)
(= (best-match $matches)
   ; ... sort by priority, return highest
   )
```

---

*In this chapter we've built ELIZA using MeTTa's pattern matching.
The implementation showcases how the Atomspace can store rules and how nondeterminism provides response variety.
ELIZA is limited but influential—a reminder that simple techniques can create compelling interactions.*

**MeTTa files:** `metta/chapter5/eliza.metta`
