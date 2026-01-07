# PAIP-MeTTa: Detailed Outline

> Paradigms of Artificial Intelligence Programming in MeTTa

This outline describes the planned adaptation of Peter Norvig's classic PAIP for the MeTTa language.

---

## Part I: Introduction to MeTTa

### Chapter 1: Introduction to MeTTa ✓ COMPLETE
*Adapted from PAIP Chapter 1*

- Symbolic computation and atoms
- The Atomspace as knowledge base
- Pattern matching with `match`
- Variables (`$x`) and bindings
- Function definition with equality (`=`)
- Nondeterminism: `superpose` and `collapse`
- Higher-order functions
- The MeTTa type system
- What makes MeTTa different (7 factors)

**MeTTa files:** `metta/chapter1/intro.metta`

---

### Chapter 2: A Simple MeTTa Program
*Adapted from PAIP Chapter 2*

**Theme:** Building a random sentence generator using pattern matching

- Grammar rules as facts in the Atomspace
- Nondeterministic choice for random selection
- Recursive sentence generation
- Rule-based programming introduction
- Changing grammar without changing code

**Key MeTTa concepts:**
- Using nondeterminism for randomness
- Grammar rules as declarative knowledge
- Pattern matching for rule selection

**Example domain:** Generate sentences like "the big cat sat on a mat"

```metta
(rule sentence (noun-phrase verb-phrase))
(rule noun-phrase (article noun))
(rule verb-phrase (verb noun-phrase))
(rule article (superpose (the a)))
(rule noun (superpose (cat dog ball)))
(rule verb (superpose (sat hit took)))
```

**MeTTa files:** `metta/chapter2/generate.metta`

---

## Part II: Early AI Programs

*The heart of the book - classic AI algorithms that showcase MeTTa's strengths*

### Chapter 4: GPS: The General Problem Solver ✓ COMPLETE
*Adapted from PAIP Chapter 4*

- Means-ends analysis
- Operators as declarative knowledge
- Backward chaining via pattern matching
- The school problem
- Monkey and bananas
- Maze navigation (showcasing nondeterminism)
- Blocks world and limitations
- What GPS teaches us about search

**MeTTa files:** `metta/chapter4/gps.metta`, `school.metta`, `monkey.metta`, `maze.metta`, `blocks.metta`

---

### Chapter 5: ELIZA: Pattern Matching Dialogue
*Adapted from PAIP Chapter 5*

**Theme:** Build a chatbot using pattern matching

- Pattern matching for natural language
- Segment patterns (matching multiple words)
- Rule-based response generation
- Context and conversation state
- The illusion of understanding

**Key MeTTa concepts:**
- Pattern matching is ELIZA's core - perfect fit
- Rules as `(pattern response)` pairs in Atomspace
- Variable binding in patterns
- Nondeterminism for response variety

**Example interaction:**
```
User: I am feeling sad today
ELIZA: Why do you say you are feeling sad today?

User: My mother criticizes me
ELIZA: Tell me more about your family
```

**Structure:**
1. Simple keyword matching
2. Pattern variables (`$x` matches one word)
3. Segment variables (`$*x` matches multiple words)
4. Response templates with substitution
5. Rule priorities and fallbacks
6. Memory and context

**MeTTa files:** `metta/chapter5/eliza.metta`, `rules.metta`

---

### Chapter 6: Building Software Tools
*Adapted from PAIP Chapter 6*

**Theme:** Reusable tools for AI programming

- The pattern matching tool (generalized from ELIZA)
- Tree search algorithms
- Graph search (avoiding repeated states)
- Best-first search
- Beam search
- Search as a general paradigm

**Key MeTTa concepts:**
- Higher-order functions for search strategies
- The Atomspace as search space
- Nondeterminism for exploring alternatives
- Backtracking via MeTTa's evaluation

**Structure:**
1. Generic pattern matcher
2. Depth-first tree search
3. Breadth-first search
4. Best-first with evaluation functions
5. A* search
6. Comparison of strategies

**MeTTa files:** `metta/chapter6/patmatch.metta`, `search.metta`

---

### Chapter 7: STUDENT: Solving Algebra Word Problems
*Adapted from PAIP Chapter 7*

**Theme:** Translate English to equations and solve

- Pattern-based English parsing
- Building equation representations
- Algebraic manipulation
- Solving for unknowns

**Example:**
```
Input: "If the number of customers Tom gets is twice the
        square of 20% of the number of advertisements he runs,
        and the number of advertisements is 45, what is the
        number of customers Tom gets?"

Output: 162
```

**Key MeTTa concepts:**
- Pattern matching for parsing
- Symbolic representation of equations
- Rewrite rules for algebraic simplification
- The Atomspace for equation knowledge

**Structure:**
1. Pattern-based parsing of word problems
2. Translating phrases to equations
3. Collecting equations from text
4. Solving systems of equations
5. Handling different problem types

**MeTTa files:** `metta/chapter7/student.metta`, `equations.metta`

---

### Chapter 8: Symbolic Mathematics: Simplification
*Adapted from PAIP Chapter 8*

**Theme:** Rule-based mathematical simplification

- Simplification as rewriting
- Canonical forms
- Associativity and commutativity
- Differentiation
- Integration (limits of rule-based approach)

**Key MeTTa concepts:**
- Rewrite rules with `=`
- Pattern matching for mathematical forms
- Recursive simplification
- When rule-based approaches fail

**Example:**
```metta
!(simplify (+ (* 2 x) (* 3 x)))  ; => (* 5 x)
!(simplify (diff (* x x) x))     ; => (* 2 x)
```

**Structure:**
1. Basic simplification rules
2. Canonical ordering
3. Combining like terms
4. Differentiation rules
5. Pattern-based integration
6. Limits and failures

**MeTTa files:** `metta/chapter8/simplify.metta`, `calculus.metta`

---

## Part III: Logic and Knowledge

*Where MeTTa's design really shines*

### Chapter 11: Logic Programming
*Adapted from PAIP Chapter 11*

**Theme:** MeTTa as a logic programming language

- Declarative vs procedural programming
- Facts and rules in the Atomspace
- Unification and pattern matching
- Backward chaining (automatic in MeTTa!)
- The Zebra puzzle
- Comparison with Prolog

**Key MeTTa insight:** MeTTa is inherently a logic programming language. This chapter shows how naturally logic programming maps to MeTTa's core features.

**Example - The Zebra Puzzle:**
```metta
; Five houses, five nationalities, five colors...
; Who owns the zebra? Who drinks water?

(house $n $color $nationality $drink $smoke $pet)
; ... constraints as patterns ...
!(match &self (house $n $c $nat water $s $p) $nat)
```

**Structure:**
1. Facts as atoms
2. Rules as equalities
3. Queries as pattern matching
4. Unification in MeTTa
5. The Zebra puzzle complete solution
6. MeTTa vs Prolog comparison

**MeTTa files:** `metta/chapter11/logic.metta`, `zebra.metta`

---

### Chapter 14: Knowledge Representation
*Adapted from PAIP Chapter 14*

**Theme:** The Atomspace as a knowledge representation system

- Taxonomies and hierarchies
- Inheritance and defaults
- Frames and slots
- Semantic networks
- The Atomspace as a hypergraph
- Querying structured knowledge

**Key MeTTa insight:** The Atomspace IS a knowledge representation system. This chapter explores its full potential.

**Structure:**
1. Simple facts and taxonomies
2. Inheritance patterns
3. Default reasoning
4. Frame-like structures
5. Semantic networks in the Atomspace
6. Complex queries with `match`
7. Multiple spaces for modularity

**Example:**
```metta
; Taxonomy
(isa dog mammal)
(isa mammal animal)
(isa cat mammal)

; Properties with inheritance
(has mammal legs 4)
(has bird legs 2)

; Query: what has 4 legs?
!(match &self (has $x legs 4) $x)
```

**MeTTa files:** `metta/chapter14/knowledge.metta`, `frames.metta`, `semantic-net.metta`

---

## Part IV: Advanced AI Programs

### Chapter 16: Expert Systems
*Adapted from PAIP Chapter 16*

**Theme:** Building rule-based expert systems

- Rules with certainty factors
- Forward and backward chaining
- Explanation facilities
- The MYCIN medical diagnosis system
- Dealing with uncertainty

**Key MeTTa concepts:**
- Rules as patterns with confidence
- Chaining via pattern matching
- Explanation as proof trace
- Uncertainty in the Atomspace

**Example - Medical Diagnosis:**
```metta
(rule (has-symptom $p fever)
      (may-have $p infection)
      0.6)

(rule (and (may-have $p infection)
           (has-symptom $p cough))
      (may-have $p pneumonia)
      0.7)
```

**Structure:**
1. Rule representation
2. Certainty factors and combination
3. Backward chaining with confidence
4. User queries and explanation
5. Mini-MYCIN implementation

**MeTTa files:** `metta/chapter16/expert.metta`, `mycin.metta`

---

### Chapter 17: Constraint Satisfaction
*Adapted from PAIP Chapter 17*

**Theme:** Solving problems with constraints

- The line-labeling problem
- Constraint propagation
- Combining search and constraints
- Arc consistency
- Applications to puzzles

**Key MeTTa concepts:**
- Constraints as patterns
- Propagation via pattern matching
- Search with pruning
- Nondeterminism for exploration

**Structure:**
1. Constraint representation
2. Simple propagation
3. The Waltz line-labeling algorithm
4. Arc consistency
5. Constraint-based puzzle solving

**MeTTa files:** `metta/chapter17/constraints.metta`, `waltz.metta`

---

### Chapter 18: Game Playing
*Adapted from PAIP Chapter 18*

**Theme:** Adversarial search and game AI

- Game representation
- Minimax algorithm
- Alpha-beta pruning
- Evaluation functions
- Othello as case study

**Key MeTTa concepts:**
- Game states in the Atomspace
- Move generation via pattern matching
- Recursive search with pruning
- Nondeterminism for move exploration

**Structure:**
1. Game state representation
2. Move generation
3. Minimax search
4. Alpha-beta optimization
5. Position evaluation
6. Complete Othello player

**MeTTa files:** `metta/chapter18/games.metta`, `minimax.metta`, `othello.metta`

---

### Chapter 19: Introduction to Natural Language
*Adapted from PAIP Chapter 19*

**Theme:** Parsing natural language with patterns

- Phrase structure grammars
- Top-down parsing
- Bottom-up parsing
- Ambiguity handling
- Semantic representation

**Key MeTTa concepts:**
- Grammar rules as patterns
- Parsing as pattern matching
- Nondeterminism for ambiguity
- Building parse trees

**Structure:**
1. Context-free grammars
2. Recursive descent parsing
3. Chart parsing
4. Handling ambiguity
5. Building meaning representations

**MeTTa files:** `metta/chapter19/nlp.metta`, `parser.metta`

---

### Chapter 20: Unification Grammars
*Adapted from PAIP Chapter 20*

**Theme:** Feature-based parsing

- Features and unification
- Definite Clause Grammars (DCG)
- Agreement handling
- Subcategorization
- Quantifier scope

**Key MeTTa concepts:**
- Unification is native to MeTTa
- Features as structured atoms
- DCG-style rules

**Structure:**
1. Feature structures
2. Unification in parsing
3. Agreement constraints
4. Complex NP handling
5. Semantic composition

**MeTTa files:** `metta/chapter20/dcg.metta`, `features.metta`

---

## Appendices

### Appendix A: MeTTa Reference
- Quick syntax reference
- Built-in functions
- Type system overview
- Common patterns

### Appendix B: Running the Examples
- Installing MeTTa
- Running the code
- Using the Atomspace

### Appendix C: From Lisp to MeTTa
- Mapping Lisp concepts to MeTTa
- Key differences
- Translation patterns

---

## Summary: Chapter Status

| Chapter | Title | Status | Priority |
|---------|-------|--------|----------|
| 1 | Introduction to MeTTa | ✅ Complete | - |
| 2 | A Simple MeTTa Program | 📝 Planned | Medium |
| 4 | GPS | ✅ Complete | - |
| 5 | ELIZA | 📝 Planned | **High** |
| 6 | Building Software Tools | 📝 Planned | Medium |
| 7 | STUDENT | 📝 Planned | Medium |
| 8 | Symbolic Mathematics | 📝 Planned | Low |
| 11 | Logic Programming | 📝 Planned | **High** |
| 14 | Knowledge Representation | 📝 Planned | **High** |
| 16 | Expert Systems | 📝 Planned | Medium |
| 17 | Constraint Satisfaction | 📝 Planned | Medium |
| 18 | Game Playing | 📝 Planned | Medium |
| 19 | Intro to NLP | 📝 Planned | Medium |
| 20 | Unification Grammars | 📝 Planned | Low |

**Recommended next chapters:** 5 (ELIZA), 11 (Logic Programming), or 14 (Knowledge Representation)

---

## Why These Chapters?

### Included (12 chapters)
These chapters showcase AI techniques that map naturally to MeTTa:
- **Pattern matching** (1, 5, 6, 7, 19, 20)
- **Search and planning** (4, 6, 17, 18)
- **Logic and reasoning** (11, 14, 16)
- **Symbolic computation** (8)

### Excluded
These chapters are too Lisp-specific:
- **Chapter 3** (Lisp reference manual)
- **Chapters 9-10** (Lisp efficiency hacks)
- **Chapter 12** (Prolog compiler in Lisp)
- **Chapter 13** (CLOS - Lisp OOP)
- **Chapter 15** (Polynomial arithmetic - specialized)
- **Chapter 21** (English grammar lexicon - too large)
- **Chapters 22-25** (Lisp implementation details)

---

*This outline is a living document and will be updated as chapters are completed.*
