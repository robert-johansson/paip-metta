# Chapter 1
## Introduction to MeTTa

> You think you know when you learn, are more sure when you can write, even more when you can teach, but certain when you can program.
>
> -Alan Perlis \
> Yale University computer scientist

This chapter is for people with little or no experience in MeTTa.
Readers who feel confident in their MeTTa programming ability can quickly skim the chapter or skip it entirely.
This chapter necessarily moves quickly, so those with little programming experience, or any reader who finds this chapter tough going, should consult the [official MeTTa tutorials](https://metta-lang.dev/docs/learn/tutorials/).

Computers allow one to carry out computations.
A word processing program deals with words while a calculator deals with numbers, but the principles are the same.
In both cases, you provide the input (words or numbers) and specify the operations (such as deleting a word or adding two numbers) to yield a result (a completed document or calculation).

We will refer to anything that can be represented in the memory of a computer as a *computational object*, or just an *object*.
So, words, paragraphs, and numbers can be objects.
And because the operations (deleting and adding) must be represented somewhere in the computer's memory, they are objects, too.
In MeTTa, all computational objects are called **atoms**—the fundamental building blocks of data and computation.

Normally, the distinction between a computer "user" and a computer "programmer" is that the user provides new input, or data (words or numbers), while the programmer defines new *operations*, or programs, as well as new *types* of data.
Every new object, be it datum or operation, must be defined in terms of previously defined objects.
The bad news is that it can be quite tedious to get these definitions right.
The good news is that each new object can in turn be used in the definition of future objects.
Thus, even complex programs can be built out of smaller, simpler objects.
This book covers a number of typical AI problems, showing how each problem can be broken down into manageable pieces, and also how each piece can be described in the programming language MeTTa.
Ideally, readers will learn enough through studying these examples to attack new AI problems with style, grace, and success.

Let's consider a simple example of a computation: finding the sum of two numbers, let's say 2 and 2.
If we had a calculator handy, we would type "2 + 2 =" and see the answer displayed.
In MeTTa, as with the calculator, the user carries out an interactive dialog with the computer by typing in an expression and seeing the computer print the value of that expression.

MeTTa uses *prefix notation*, where the operation comes first, followed by its arguments, all enclosed in parentheses:

```metta
!(+ 2 2)
```

The result is:

```
[4]
```

We see that MeTTa has printed the answer, `4`, inside brackets (indicating a list of results—more on this later).
The `!` at the beginning is the *evaluation operator*—it tells MeTTa to actually compute the result.
Without it, `(+ 2 2)` is just *data*: a symbolic expression that sits there without being evaluated.
This distinction between data and evaluation is fundamental to MeTTa, and we'll return to it often.

To save space on the page, the output will sometimes be shown on the same line as the input, separated by `=>`, which can be read as "evaluates to":

```metta
!(+ 2 2)  ; => 4
```

The semicolon begins a *comment*, which lasts until the end of the line.
Comments are ignored by MeTTa but are useful for explaining code to human readers.

One difference from some other languages: MeTTa's arithmetic operators take exactly two arguments.
If we want to add more numbers, we must nest the operations:

```metta
!(+ 2 2)                        ; => 4
!(+ 1 (+ 2 (+ 3 4)))            ; => 10
!(- (+ 9000 900) (+ 5000 500))  ; => 4400
```

This last example shows that expressions can be nested.
The arguments to the `-` function are themselves expressions.
The MeTTa notation may look unusual compared to standard mathematical notation, but there are advantages to this notation.
More important than the notation is the rule for evaluation: in MeTTa, expressions are evaluated by first evaluating all the arguments, then applying the function to the arguments, thereby computing the result.

Sometimes programmers who are familiar with other languages have preconceptions that make it difficult for them to learn MeTTa.
For them, three points are worth stressing here.

First, many other languages make a distinction between *statements* and *expressions*.
An expression, like `2 + 2`, has a value, but a statement, like `x = 2 + 2`, does not.
Statements have effects, but they do not return values.
In MeTTa, there is no such distinction: every expression can be evaluated to produce a result.

Second, unlike most languages where expressions are automatically evaluated, in MeTTa *symbols and expressions are data by default*.
The expression `(+ 2 2)` is just a list of three atoms—the symbol `+` and the numbers `2` and `2`.
You must use `!` to request evaluation.
This makes it trivial to manipulate programs as data, a powerful technique we'll use throughout this book.

Third, MeTTa programs can return *multiple results*.
We'll see this soon, and it's one of the most distinctive features of the language.

## 1.1 Symbolic Computation

All we've done so far is manipulate numbers in the same way a simple pocket calculator would.
MeTTa is more useful than a calculator for two main reasons.
First, it allows us to manipulate objects other than numbers, and second, it allows us to define new objects that might be useful in subsequent computations.
We will examine these two important properties in turn.

Besides numbers, MeTTa can represent arbitrary symbols, where we are free to interpret these symbols as referring to things outside the world of mathematics.
MeTTa can also build compound objects by combining several atoms into an *expression*.
This capability is fundamental and well supported in the language.

Here's an example of symbolic computation—adding knowledge to MeTTa's *Atomspace* (its knowledge base):

```metta
(Sam is a frog)
(Tom is a cat)
(Sophia is a robot)
```

These three lines add three facts to the Atomspace.
Notice that we didn't need any special syntax—no quotes, no special markers.
In MeTTa, *symbols are symbolic by default*.
The expression `(Sam is a frog)` is just four atoms grouped together.
MeTTa doesn't know that Sam is a name or that frog is an animal; to MeTTa, they're just symbols.

Now we can query this knowledge using *pattern matching*:

```metta
!(match &self ($who is a $what) ($who the $what))
```

The result is:

```
[(Sam the frog), (Tom the cat), (Sophia the robot)]
```

Let's break this down:

- `match` is a built-in function for querying the Atomspace
- `&self` refers to the current Atomspace
- `($who is a $what)` is a *pattern* with two *variables*
- `($who the $what)` is the output template

Variables in MeTTa are indicated by the `$` prefix.
The pattern `($who is a $what)` matches any expression of the form `(something is a something)`, binding `$who` and `$what` to the corresponding parts.

Notice what we *didn't* have to do.
We didn't write a loop to iterate through the facts.
We didn't write conditional logic to check each one.
We simply described the pattern we were looking for, and MeTTa found all matches.
This declarative style—describing *what* rather than *how*—is central to MeTTa programming.

There are four important points to make about symbols:

- First, it is important to remember that MeTTa does not attach any external significance to the objects it manipulates.
For example, we naturally think of `Sam` as a name and `frog` as an animal.
MeTTa has no such preconceptions.
To MeTTa, both `Sam` and `xyzzy` are perfectly good symbols.

- Second, to do the computations above, we had to know that `match` and `+` are defined operations in MeTTa.
Learning a language involves remembering vocabulary items (or knowing where to look them up) as well as learning the basic rules for forming expressions and determining what they mean.

- Third, a wide variety of characters are allowed in symbols: letters, numbers, and punctuation marks like `+`, `-`, `?`, or `!`.
The normal convention is to use symbols consisting mostly of lowercase letters, with words separated by a dash (`-`).

- Fourth, variables are distinguished by the `$` prefix.
The symbol `who` is just data, but `$who` is a variable that can bind to values during pattern matching.

## 1.2 Variables

We have seen some of the basics of symbolic computation.
Now we move on to perhaps the most important characteristic of a programming language: the ability to define new objects in terms of others, and to name these objects for future use.

In MeTTa, we use `let` to bind values to variables temporarily:

```metta
!(let $x (+ 1 2) (* $x $x))  ; => 9
```

This expression binds `$x` to `3` (the result of `(+ 1 2)`), then evaluates `(* $x $x)` which is `(* 3 3)` = `9`.

For multiple bindings, use `let*`:

```metta
!(let* (($a 1)
        ($b 2)
        ($c (+ $a $b)))
   (* $c $c))  ; => 9
```

This binds `$a` to `1`, `$b` to `2`, `$c` to `3` (the sum), then computes `(* 3 3)`.

But the real power comes from defining reusable patterns using `=`.

## 1.3 Defining Functions with Equality

Unlike many languages that have special syntax for function definitions, MeTTa uses *equality* (`=`) to define how expressions can be rewritten.
This is both simpler and more powerful than traditional function definitions.

Let's start with a simple example.
Suppose we have a person's name represented as a list, like `(John Q Public)`, and we want to extract the last name.
We could manually pick out the third element, but that wouldn't work for someone with no middle name.

Let's define a general solution.
First, we need to build up some tools.
In MeTTa, we define list operations using pattern matching:

```metta
; Get the first element of a list
(= (first ($h $t)) $h)

; Get the rest of a list (everything but the first)
(= (rest ($h $t)) $t)
```

The expression `(= (first ($h $t)) $h)` says: "the expression `(first something)` can be rewritten as `$h` when `something` matches the pattern `($h $t)`."
Here `$h` binds to the first element (the "head") and `$t` binds to the rest (the "tail").

Let's test these:

```metta
!(first (John Q Public))  ; => John
!(rest (John Q Public))   ; => (Q Public)
```

Now we can define `last-name`.
For a list like `(John Q Public)`, we want `Public`.
The key insight is that we need to get the *last* element.
We can define this recursively:

Let me show a clean approach using the `Cons`/`Nil` pattern common in functional programming:

```metta
; Type constructors for lists
(: Nil (List $t))
(: Cons (-> $t (List $t) (List $t)))

; List operations
(= (first (Cons $h $t)) $h)
(= (rest (Cons $h $t)) $t)

; last: base case is single element, recursive case needs explicit non-Nil tail
(= (last (Cons $x Nil)) $x)
(= (last (Cons $h (Cons $x $xs))) (last (Cons $x $xs)))

; Now define last-name
(= (last-name $name) (last $name))
```

Let's test it:

```metta
!(last-name (Cons John (Cons Q (Cons Public Nil))))  ; => Public
```

The careful reader will note that we're testing with `Cons`/`Nil` lists, not the simple `(John Q Public)` notation.
For this chapter, we'll use both styles, understanding that they represent different ways to structure list data.

We can also define `first-name`:

```metta
(= (first-name $name) (first $name))
```

Even though this is trivial (the same as `first`), it's good practice to define it explicitly.
Then we can use `first-name` when dealing with names, and `first` when dealing with arbitrary lists.
The computer performs the same operation, but we as programmers (and readers of programs) will be less confused.
Another advantage: if we later change how names are represented, we only need to change `first-name`.

Let's set up a list of names to test our functions:

```metta
(= (names)
   (Cons (Cons John (Cons Q (Cons Public Nil)))
   (Cons (Cons Malcolm (Cons X Nil))
   (Cons (Cons Admiral (Cons Grace (Cons Murray (Cons Hopper Nil))))
   (Cons (Cons Spot Nil)
   (Cons (Cons Aristotle Nil)
   (Cons (Cons Sir (Cons Larry (Cons Olivier Nil)))
   (Cons (Cons Miss (Cons Scarlet Nil))
   Nil))))))))
```

## 1.4 Using Functions

One good thing about defining a list of names is that it makes it easier to test our functions.
Let's define a `map` function that applies another function to each element of a list:

```metta
(= (map $f Nil) Nil)
(= (map $f (Cons $x $xs)) (Cons ($f $x) (map $f $xs)))
```

Now we can test `last-name` on all our names at once:

```metta
!(map last-name (names))
; => (Cons Public (Cons X (Cons Hopper (Cons Spot (Cons Aristotle (Cons Olivier (Cons Scarlet Nil)))))))
```

That gives us: Public, X, Hopper, Spot, Aristotle, Olivier, Scarlet.

Now let's test `first-name`:

```metta
!(map first-name (names))
; => John, Malcolm, Admiral, Spot, Aristotle, Sir, Miss
```

We might be disappointed with these results.
Admiral and Sir are titles, not first names!
Suppose we wanted a version of `first-name` that ignored titles and got to the "real" first name.

First, let's define a list of titles:

```metta
(= (titles) (Cons Mr (Cons Mrs (Cons Miss (Cons Ms (Cons Sir (Cons Madam (Cons Dr (Cons Admiral (Cons Major (Cons General Nil)))))))))))
```

Now we need a function to check if something is a member of a list:

```metta
(= (member $x Nil) False)
(= (member $x (Cons $h $rest))
   (if (== $x $h)
       True
       (member $x $rest)))
```

And now we can define a smarter `first-name`:

```metta
(= (first-name $name)
   (if (member (first $name) (titles))
       (first-name (rest $name))
       (first $name)))
```

This definition says: if the first word of the name is a member of the list of titles, then ignore it and return the `first-name` of the rest.
Otherwise, return the first word.

The function `first-name` is said to be *recursive* because its definition includes a call to itself.
Programmers who are new to the concept of recursion sometimes find it mysterious.
But recursive functions are really no different from nonrecursive ones.
Any function is required to return the correct value for the given input(s).

Here's the key insight—what I call the "leap of faith."
When writing a recursive function, assume that the recursive call works correctly.
Your job is only to ensure that:

1. The base case returns the correct answer
2. The recursive case makes progress toward the base case
3. The recursive call is used correctly

In `first-name`:
- Base case: when the first element is not a title, return it
- Recursive case: skip the title and call `first-name` on the rest
- Progress: each recursive call has a shorter list

This completes the demonstration that the function is correct.
Programmers who learn to think this way find recursion to be a valuable tool rather than a confusing mystery.

## 1.5 Nondeterminism

One of MeTTa's most distinctive features is *nondeterminism*: the ability to return multiple results from a single expression.
This is fundamentally different from most programming languages, where a function returns exactly one value.

Consider this example:

```metta
(= (color) red)
(= (color) green)
(= (color) blue)

!(color)  ; => [red, green, blue]
```

The function `color` has three definitions, and MeTTa returns *all* of them.
This isn't an error or ambiguity—it's a feature.
In AI applications, we often want to explore multiple possibilities, and MeTTa makes this natural.

Two built-in functions help manage nondeterminism:

**`superpose`** converts a tuple into multiple separate results:

```metta
!(superpose (a b c))  ; => [a, b, c] (three separate results)
```

**`collapse`** does the opposite—it collects all results into a single tuple:

```metta
!(collapse (color))  ; => [(red green blue)]
```

When you compose nondeterministic expressions, MeTTa explores all combinations:

```metta
(= (coin) heads)
(= (coin) tails)

!((coin) (coin))
; => [(heads heads), (heads tails), (tails heads), (tails tails)]
```

This is incredibly powerful for AI applications.
Instead of writing nested loops to explore possibilities, you declare them and MeTTa explores all paths automatically.

## 1.6 Higher-Order Functions

Functions in MeTTa can not only be "called" or applied to arguments, they can also be manipulated just like any other kind of object.
A function that takes another function as an argument is called a *higher-order function*.
`map` is an example—we already used it above.

Let's look at how `map` works more closely:

```metta
(= (map $f Nil) Nil)
(= (map $f (Cons $x $xs)) (Cons ($f $x) (map $f $xs)))
```

The first argument `$f` is a function.
In the expression `($f $x)`, we're *calling* whatever function was passed in.
This is the essence of higher-order programming: functions as values that can be passed around and applied.

We can also define anonymous functions.
In MeTTa, we can create a lambda-like construct:

```metta
(= ((lambda $var $body) $arg) (let $var $arg $body))

!((lambda $x (+ $x 1)) 5)  ; => 6
!((lambda $x (* $x $x)) 4) ; => 16
```

The `lambda` pattern creates a function that, when applied to an argument, binds that argument to the variable and evaluates the body.

Programmers who are used to other languages sometimes fail to see the point of anonymous functions.
There are two reasons why they are useful.
First, it can be messy to clutter up a program with names for small, one-off functions.
Second, and more importantly, the ability to create functions dynamically is a powerful technique for building abstractions.

## 1.7 Types

MeTTa has an optional but powerful type system.
Types are declared with `:`:

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

; Test: 1 + 2 = 3 in Peano arithmetic
!(add (S Z) (S (S Z)))  ; => (S (S (S Z)))
```

You can query the type of an expression:

```metta
!(get-type (S Z))  ; => Nat
```

Types in MeTTa are *gradual*: you can add them incrementally.
Untyped expressions use `%Undefined%` and can interact with typed code.
This lets you prototype quickly without types, then add them for safety and documentation as your code matures.

## 1.8 The Atomspace

We've mentioned the Atomspace several times.
It's worth understanding what it is, because it's central to MeTTa's design.

The Atomspace is MeTTa's knowledge base—a space where atoms live.
When you write an expression at the top level (without `!`), you're adding it to the Atomspace:

```metta
(Sam is a frog)      ; Adds this to the Atomspace
(= (double $x) (+ $x $x))  ; Adds this rule to the Atomspace
```

The special symbol `&self` refers to the current Atomspace.
The `match` function queries it:

```metta
!(match &self (Sam is a $what) $what)  ; => frog
```

This is different from most programming languages, where data and code live in separate worlds.
In MeTTa, knowledge (facts) and functions (rules) coexist in the same space and can be queried uniformly.
This makes MeTTa natural for AI applications that need to reason about both data and procedures.

## 1.9 Summary: The MeTTa Evaluation Model

We can now summarize how MeTTa evaluates expressions:

- **Atoms** are the fundamental units. There are four kinds:
  - *Symbols*: `foo`, `+`, `Sam` — just names
  - *Variables*: `$x`, `$who` — bind to values during pattern matching
  - *Numbers*: `42`, `3.14` — evaluate to themselves
  - *Expressions*: `(a b c)`, `(+ 2 2)` — compound structures

- **Expressions are data by default**. The expression `(+ 2 2)` is just a list of three atoms until you evaluate it.

- **The `!` operator requests evaluation**. `!(+ 2 2)` tells MeTTa to compute the result.

- **Equality (`=`) defines rewrite rules**. The expression `(= (double $x) (+ $x $x))` says that `(double something)` can be rewritten as `(+ something something)`.

- **Pattern matching drives computation**. When MeTTa evaluates `(double 5)`, it finds the rule `(= (double $x) (+ $x $x))`, matches `$x` to `5`, and rewrites to `(+ 5 5)`.

- **All matching rules are applied**. If multiple `=` rules match, MeTTa returns all results (nondeterminism).

- **The Atomspace stores knowledge**. Facts and rules live together, queryable with `match`.

This model is simpler than it might seem at first.
There are no special forms, no complex evaluation orders, no distinction between statements and expressions.
Just atoms, patterns, and rewriting.

## 1.10 What Makes MeTTa Different?

What is it that sets MeTTa apart from other languages?
Why is it a good language for AI applications?
There are at least seven important factors:

- **Symbolic by Default**
- **Pattern Matching as Foundation**
- **Nondeterministic Computation**
- **The Atomspace**
- **Gradual Types**
- **Homoiconicity**
- **Designed for AI**

In sum, these factors allow a programmer to express AI problems naturally.
Let's consider each factor in more depth:

**Symbolic by Default.**
In most languages, you must explicitly mark data as data (with quotes in Lisp, string delimiters, etc.).
In MeTTa, symbols are symbolic by default.
`(Sam is a frog)` is just four atoms—no special syntax needed.
This makes knowledge representation natural and reduces syntactic overhead.

**Pattern Matching as Foundation.**
Pattern matching isn't an add-on feature in MeTTa; it's the core computation model.
Function "calls" are really pattern matches against `=` rules.
Queries are pattern matches against the Atomspace.
This unification means the same mental model applies everywhere.

**Nondeterministic Computation.**
Most languages assume one input produces one output.
MeTTa embraces multiple outputs as natural.
When you define `(= (color) red)` and `(= (color) blue)`, calling `(color)` returns *both*.
This models uncertainty, alternatives, and search naturally—exactly what AI needs.

**The Atomspace.**
Traditional languages separate code from data.
MeTTa's Atomspace holds both: facts like `(Sam is a frog)` and rules like `(= (double $x) (+ $x $x))` coexist and can be queried uniformly.
This enables programs that reason about their own knowledge and behavior.

**Gradual Types.**
MeTTa's type system is optional and incremental.
You can write untyped prototypes quickly, then add types for safety and documentation.
Types can express complex constraints (dependent types), enabling rich specifications of program behavior.

**Homoiconicity.**
MeTTa programs are MeTTa data.
The expression `(= (double $x) (+ $x $x))` is itself an atom that can be stored, queried, and manipulated.
This makes metaprogramming—programs that write or modify programs—natural.

**Designed for AI.**
MeTTa wasn't adapted for AI; it was designed for it from the start.
It emerged from the OpenCog Hyperon project, which aims to build artificial general intelligence.
The Atomspace is based on decades of research into knowledge representation.
The pattern matching and nondeterminism support the kind of reasoning AI systems need.

The contrast with other languages is instructive:

| Other Languages | MeTTa |
|-----------------|-------|
| Code and data are separate | Code and data coexist in the Atomspace |
| One result per function | Multiple results (nondeterminism) |
| Evaluation is automatic | Evaluation is explicit (`!`) |
| Pattern matching is a feature | Pattern matching is the foundation |
| Types are mandatory or absent | Types are gradual |

MeTTa shares some DNA with Lisp—the parenthesized syntax, the symbolic computation, the homoiconicity.
But it's not a Lisp dialect.
It's a new language designed for a new era of AI.

## 1.11 Exercises

**Exercise 1.1 [m]** Define `append` that concatenates two `Cons`/`Nil` lists.
Example: `(append (Cons a (Cons b Nil)) (Cons c (Cons d Nil)))` should return `(Cons a (Cons b (Cons c (Cons d Nil))))`.

**Exercise 1.2 [m]** Define `reverse` that reverses a list.
Hint: Use your `append` function.

**Exercise 1.3 [m]** Define `length` that returns the number of elements in a list.

**Exercise 1.4 [m]** Using nondeterminism, write a function `pairs` that generates all pairs where the first element is from `(1 2 3)` and the second is from `(a b)`.
The result should be six pairs.

**Exercise 1.5 [m]** Write a function `sum-list` that adds up all numbers in a list.

**Exercise 1.6 [h]** Define a smarter `last-name` that handles titles at the end as well.
For example, `(Rex Morgan MD)` should return `Morgan`, not `MD`.
Hint: Define a list of suffixes like `(MD Jr Sr PhD)` and check for them.

## 1.12 Answers

### Answer 1.1

```metta
(= (append Nil $ys) $ys)
(= (append (Cons $x $xs) $ys) (Cons $x (append $xs $ys)))

!(append (Cons a (Cons b Nil)) (Cons c (Cons d Nil)))
; => (Cons a (Cons b (Cons c (Cons d Nil))))
```

### Answer 1.2

```metta
(= (reverse Nil) Nil)
(= (reverse (Cons $x $xs)) (append (reverse $xs) (Cons $x Nil)))

!(reverse (Cons a (Cons b (Cons c Nil))))
; => (Cons c (Cons b (Cons a Nil)))
```

### Answer 1.3

```metta
(= (length Nil) 0)
(= (length (Cons $x $xs)) (+ 1 (length $xs)))

!(length (Cons a (Cons b (Cons c Nil))))  ; => 3
```

### Answer 1.4

```metta
(= (xs) (superpose (1 2 3)))
(= (ys) (superpose (a b)))
(= (pairs) ((xs) (ys)))

!(pairs)
; => [(1 a), (1 b), (2 a), (2 b), (3 a), (3 b)]
```

### Answer 1.5

```metta
(= (sum-list Nil) 0)
(= (sum-list (Cons $x $xs)) (+ $x (sum-list $xs)))

!(sum-list (Cons 1 (Cons 2 (Cons 3 Nil))))  ; => 6
```

### Answer 1.6

```metta
(= (suffixes) (Cons MD (Cons Jr (Cons Sr (Cons PhD Nil)))))

(= (last-name-helper (Cons $x Nil))
   (if (member $x (suffixes))
       Nil  ; name was all suffixes, return empty
       (Cons $x Nil)))

(= (last-name-helper (Cons $x $xs))
   (let $rest (last-name-helper $xs)
     (if (== $rest Nil)
         (Cons $x Nil)  ; rest was suffix, so $x is the last name
         (Cons $x $rest))))

(= (last-name $name) (last (last-name-helper $name)))

; Note: This is a simplified solution. A complete solution
; would need more careful handling of edge cases.
```

---

*This chapter has introduced the fundamental concepts of MeTTa: atoms and expressions, pattern matching, function definition with equality, nondeterminism, and the Atomspace.
In the following chapters, we'll use these tools to build increasingly sophisticated AI programs, starting with the General Problem Solver in Chapter 4.*
