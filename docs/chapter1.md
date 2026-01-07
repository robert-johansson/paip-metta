# Chapter 1
## Introduction to MeTTa

> You think you know when you learn, are more sure when you can write, even more when you can teach, but certain when you can program.
>
> -Alan Perlis \
> Yale University computer scientist

This chapter is for people with little or no experience in MeTTa. Readers who feel confident in their MeTTa programming ability can quickly skim the chapter or skip it entirely. This chapter necessarily moves quickly, so those with little programming experience should also consult the [official MeTTa tutorials](https://metta-lang.dev/docs/learn/tutorials/).

Computers allow one to carry out computations. A word processing program deals with words while a calculator deals with numbers, but the principles are the same. In both cases, you provide the input (words or numbers) and specify the operations (such as deleting a word or adding two numbers) to yield a result.

We will refer to anything that can be represented in the memory of a computer as a *computational object*, or just an *object*. In MeTTa, these objects are called **Atoms**. Atoms can represent anything: words, numbers, concepts, relationships, or even operations themselves.

MeTTa (Meta Type Talk) is a symbolic AI programming language from the OpenCog Hyperon project. It's designed specifically for artificial intelligence applications, with built-in support for knowledge representation, pattern matching, and nondeterministic computation.

Let's consider a simple example: finding the sum of two numbers.

In MeTTa, we write:

```metta
!(+ 2 2)
```

The result is:

```
[4]
```

The `!` operator tells MeTTa to *evaluate* the expression. Without it, `(+ 2 2)` is just data - a symbolic expression. This is a key insight: **in MeTTa, everything is data by default**, and you explicitly request evaluation.

MeTTa uses *prefix notation*, where the operation comes first, followed by its arguments:

```metta
!(+ 2 2)     ; => 4
!(* 3 4)     ; => 12
!(- 10 3)    ; => 7
```

**Important**: MeTTa's arithmetic operators take exactly two arguments, unlike some languages where `+` can take many:

```metta
; This works:
!(+ 2 2)     ; => 4

; This does NOT work:
; !(+ 1 2 3 4)  ; Error: IncorrectNumberOfArguments

; Instead, chain the operations:
!(+ 1 (+ 2 (+ 3 4)))  ; => 10
```

## 1.1 Symbolic Computation

All we've done so far is manipulate numbers in the same way a simple calculator would. MeTTa is more useful than a calculator for two main reasons. First, it allows us to manipulate *symbols* and *expressions* as easily as numbers. Second, it allows us to store knowledge and query it using pattern matching.

Here's an example of symbolic computation:

```metta
; Add facts to the Atomspace (MeTTa's knowledge base)
(Sam is a frog)
(Tom is a cat)
(Sophia is a robot)

; Query with pattern matching
!(match &self ($who is a $what) ($who the $what))
```

The result is:

```
[(Sam the frog), (Tom the cat), (Sophia the robot)]
```

Let's break this down:

- `(Sam is a frog)` - This is an **expression** (or **atom**) that we add to the Atomspace. No quotes needed; symbols are symbolic by default!
- `&self` - This refers to the current Atomspace (knowledge base)
- `$who` and `$what` - These are **variables**, indicated by the `$` prefix
- `match` - This function searches the Atomspace for patterns

Notice how different this is from traditional programming. We didn't write a loop or an if-statement. We simply described *what* we wanted (all things matching the pattern), and MeTTa found all the matches.

There are important points about symbols in MeTTa:

1. **No quotes needed**: Unlike Lisp, MeTTa symbols are data by default. `Sam` is a symbol, not a variable to be evaluated.

2. **Variables need `$`**: To indicate a pattern variable, prefix it with `$`. The symbol `who` is just data, but `$who` is a variable that can bind to values.

3. **Expressions are data**: `(Sam is a frog)` is an expression (a list of symbols). It's stored as-is in the Atomspace.

4. **Symbols can contain many characters**: `my-function`, `is-greater?`, and `+` are all valid symbols.

## 1.2 Variables

Variables in MeTTa are indicated by the `$` prefix. They're used in patterns for matching and binding values.

To bind a variable temporarily, use `let`:

```metta
!(let $x (+ 1 2) (* $x $x))
```

Result: `[9]`

This binds `$x` to `3` (the result of `(+ 1 2)`), then evaluates `(* $x $x)` which is `(* 3 3)` = `9`.

For multiple sequential bindings, use `let*`:

```metta
!(let* (($a 1)
        ($b 2)
        ($c (+ $a $b)))
   (* $c $c))
```

Result: `[9]`

This binds `$a` to `1`, `$b` to `2`, `$c` to `3`, then computes `(* 3 3)` = `9`.

## 1.3 The Evaluation Model

Unlike Lisp, MeTTa doesn't have "special forms." Instead, it has a unified model:

1. **Expressions are data**: `(+ 2 2)` is just an expression containing three atoms
2. **`!` requests evaluation**: `!(+ 2 2)` asks MeTTa to reduce the expression
3. **`=` defines rewrite rules**: Functions are defined as patterns that can be rewritten

The `=` symbol defines *equality* or *rewrite rules*:

```metta
(= (double $x) (+ $x $x))

!(double 5)  ; => 10
```

When MeTTa sees `(double 5)`, it looks for a matching `=` rule. It finds `(= (double $x) (+ $x $x))`, binds `$x` to `5`, and rewrites to `(+ 5 5)`, which evaluates to `10`.

This is fundamentally different from imperative programming. There's no "assignment" - just pattern matching and rewriting.

## 1.4 Expressions and Lists

In MeTTa, everything is built from **atoms** and **expressions**:

- **Symbols**: `foo`, `my-name`, `+`, `Sam`
- **Variables**: `$x`, `$who`, `$_` (underscore for "don't care")
- **Numbers**: `42`, `3.14`, `-17`
- **Expressions**: `(a b c)`, `(+ 2 2)`, `(Sam is a frog)`

We can define list operations using pattern matching:

```metta
; Define type constructors for lists
(: Nil (List $t))
(: Cons (-> $t (List $t) (List $t)))

; first: get the head of a list
(= (first (Cons $h $t)) $h)

; rest: get the tail of a list
(= (rest (Cons $h $t)) $t)

; Examples
!(first (Cons a (Cons b (Cons c Nil))))  ; => a
!(rest (Cons a (Cons b (Cons c Nil))))   ; => (Cons b (Cons c Nil))
```

We can also define `length`:

```metta
(= (length Nil) 0)
(= (length (Cons $x $xs)) (+ 1 (length $xs)))

!(length (Cons a (Cons b (Cons c Nil))))  ; => 3
```

Notice how we use *pattern matching* to destructure the list. The pattern `(Cons $x $xs)` matches any non-empty list, binding `$x` to the first element and `$xs` to the rest.

## 1.5 Defining New Functions

Functions in MeTTa are defined using `=` (equality):

```metta
(= (square $x) (* $x $x))

!(square 5)   ; => 25
!(square 12)  ; => 144
```

We can define functions with multiple cases using pattern matching:

```metta
(= (greet hello) "Hello to you too!")
(= (greet goodbye) "Farewell!")
(= (greet $x) "I don't understand")

!(greet hello)    ; => "Hello to you too!"
!(greet goodbye)  ; => "Farewell!"
!(greet blah)     ; => "I don't understand"
```

**Warning about pattern specificity**: Unlike Lisp's `cond` which returns the first match, MeTTa returns *all* matches (nondeterminism). To avoid this, make patterns mutually exclusive or use `if`:

```metta
!(if (> 5 3) yes no)  ; => yes
!(if (< 5 3) yes no)  ; => no
```

Here's a more practical example - a function to extract the last name from a list of names:

```metta
; Helper: get the last element of a list
(= (last (Cons $x Nil)) $x)
(= (last (Cons $x $xs)) (last $xs))

; Test it
!(last (Cons John (Cons Q (Cons Public Nil))))  ; => Public
```

## 1.6 Nondeterminism

One of MeTTa's most distinctive features is **nondeterminism**. When multiple patterns match, *all* results are returned:

```metta
(= (color) red)
(= (color) green)
(= (color) blue)

!(color)  ; => [red, green, blue]
```

This is incredibly powerful for AI applications. Instead of writing loops to explore possibilities, you declare them and MeTTa explores all paths.

### superpose and collapse

Two important functions work with nondeterminism:

**`superpose`** - converts a tuple into nondeterministic results:

```metta
!(superpose (a b c))  ; => [a, b, c] (three separate results)
```

**`collapse`** - converts nondeterministic results into a tuple:

```metta
(= (color) red)
(= (color) green)
(= (color) blue)

!(collapse (color))  ; => [(red green blue)] (one tuple)
```

This allows you to switch between "exploring all possibilities" and "collecting all results."

### Combining Nondeterministic Values

When you compose nondeterministic expressions, MeTTa explores all combinations:

```metta
(= (coin) heads)
(= (coin) tails)

(= (pair $x $y) ($x $y))

!(pair (coin) (coin))
; => [(heads heads), (heads tails), (tails heads), (tails tails)]
```

## 1.7 Higher-Order Functions

Functions are first-class values in MeTTa. You can pass them as arguments:

```metta
; Define map for our list type
(= (map $f Nil) Nil)
(= (map $f (Cons $x $xs)) (Cons ($f $x) (map $f $xs)))

; A function to increment
(= (inc $x) (+ $x 1))

; Map it over a list
!(map inc (Cons 1 (Cons 2 (Cons 3 Nil))))
; => (Cons 2 (Cons 3 (Cons 4 Nil)))
```

Notice that we pass `inc` (the function name) directly - no special syntax needed.

We can also define anonymous functions using a lambda pattern:

```metta
; Define lambda using let
(= ((lambda $var $body) $arg) (let $var $arg $body))

; Use it
!((lambda $x (+ $x 1)) 5)  ; => 6
!((lambda $x (* $x $x)) 4) ; => 16
```

## 1.8 Types

MeTTa has an optional but powerful type system. Types are declared with `:`:

```metta
; Declare that Z is a Nat (natural number)
(: Z Nat)

; Declare that S is a function from Nat to Nat
(: S (-> Nat Nat))

; Declare the type of add
(: add (-> Nat Nat Nat))

; Define add using pattern matching
(= (add $x Z) $x)
(= (add $x (S $y)) (S (add $x $y)))

; Test: 1 + 2 = 3
!(add (S Z) (S (S Z)))  ; => (S (S (S Z)))
```

You can query the type of an expression:

```metta
!(get-type (S Z))        ; => Nat
!(get-type (add (S Z) Z)) ; => Nat
```

Types help catch errors and document your code, but they're optional - MeTTa uses *gradual typing*, so you can add types incrementally.

## 1.9 Summary: The MeTTa Evaluation Model

Here's how MeTTa evaluation works:

1. **Atoms** are either:
   - **Symbols**: `foo`, `+`, `Sam` - evaluate to themselves unless there's a rewrite rule
   - **Variables**: `$x`, `$who` - bind to values during pattern matching
   - **Numbers/Strings**: `42`, `"hello"` - evaluate to themselves
   - **Expressions**: `(a b c)` - may be rewritten if a matching `=` rule exists

2. **Evaluation** is triggered by `!`:
   - `!(+ 2 2)` - evaluate this expression
   - `(+ 2 2)` without `!` is just data

3. **Rewriting** uses `=`:
   - `(= (double $x) (+ $x $x))` - when you see `(double something)`, rewrite it
   - All matching rules are applied (nondeterminism)

4. **Pattern matching** uses variables with `$`:
   - `$x` matches anything and binds it
   - `$_` matches anything (don't care)
   - Literal symbols match only themselves

5. **The Atomspace** (`&self`) stores knowledge:
   - Add facts by writing them: `(Sam is a frog)`
   - Query with `match`: `!(match &self (pattern) result)`

## 1.10 What Makes MeTTa Different?

What sets MeTTa apart from other languages? Why is it suited for AI applications?

- **Knowledge-native**: The Atomspace provides built-in knowledge representation
- **Pattern matching**: The core computation model, not an add-on
- **Nondeterminism**: Explore all possibilities naturally
- **Symbolic by default**: No need to quote data
- **Gradual types**: Add types when you want them
- **Self-modifying**: Programs can inspect and modify themselves
- **Designed for AI**: Built specifically for knowledge representation and reasoning

Compared to Lisp (the original PAIP language):

| Lisp | MeTTa |
|------|-------|
| `'(a b c)` - must quote data | `(a b c)` - data by default |
| `(+ 1 2 3 4)` - variadic | `(+ 1 (+ 2 (+ 3 4)))` - binary |
| `cond` returns first match | All matches return (nondeterminism) |
| Functions in a namespace | Knowledge in the Atomspace |
| Sequential execution | Nondeterministic by nature |

## 1.11 Exercises

**Exercise 1.1 [m]** Define a function `(sum-list lst)` that computes the sum of all numbers in a list. Use the `Cons`/`Nil` list type.

**Exercise 1.2 [m]** Write a function `(power $x $n)` to compute x^n for non-negative integer n.

**Exercise 1.3 [m]** Define a function `(append $list1 $list2)` that concatenates two lists.

**Exercise 1.4 [m]** Define a function `(reverse $list)` that reverses a list.

**Exercise 1.5 [m]** Using nondeterminism, write a function that generates all pairs `($x $y)` where `$x` is from `(1 2 3)` and `$y` is from `(a b)`.

## 1.12 Answers

### Answer 1.1

```metta
(= (sum-list Nil) 0)
(= (sum-list (Cons $x $xs)) (+ $x (sum-list $xs)))

!(sum-list (Cons 1 (Cons 2 (Cons 3 Nil))))  ; => 6
```

### Answer 1.2

```metta
(= (power $x 0) 1)
(= (power $x $n)
   (if (> $n 0)
       (* $x (power $x (- $n 1)))
       1))

!(power 2 10)  ; => 1024
!(power 3 4)   ; => 81
```

### Answer 1.3

```metta
(= (append Nil $ys) $ys)
(= (append (Cons $x $xs) $ys) (Cons $x (append $xs $ys)))

!(append (Cons 1 (Cons 2 Nil)) (Cons 3 (Cons 4 Nil)))
; => (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))
```

### Answer 1.4

```metta
(= (reverse Nil) Nil)
(= (reverse (Cons $x $xs)) (append (reverse $xs) (Cons $x Nil)))

!(reverse (Cons 1 (Cons 2 (Cons 3 Nil))))
; => (Cons 3 (Cons 2 (Cons 1 Nil)))
```

### Answer 1.5

```metta
(= (xs) (superpose (1 2 3)))
(= (ys) (superpose (a b)))
(= (pairs) ((xs) (ys)))

!(pairs)
; => [(1 a), (1 b), (2 a), (2 b), (3 a), (3 b)]
```
