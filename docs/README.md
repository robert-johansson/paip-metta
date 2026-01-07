# PAIP in MeTTa

**Paradigms of Artificial Intelligence Programming: Case Studies in MeTTa**

This is an adaptation of Peter Norvig's classic 1992 book "Paradigms of Artificial Intelligence Programming" (PAIP) for the [MeTTa programming language](https://metta-lang.dev/).

## What is MeTTa?

MeTTa (Meta Type Talk) is a symbolic AI programming language from [OpenCog Hyperon](https://hyperon.opencog.org/). It's designed for:

- **Knowledge representation** using the Atomspace
- **Pattern matching** as a core computation model
- **Nondeterministic programming** with multiple results
- **Gradual typing** with dependent types
- **Self-modifying code** and metaprogramming

## Why PAIP in MeTTa?

The original PAIP taught AI programming through Common Lisp. MeTTa shares Lisp's symbolic computation heritage but adds modern features for AI:

| Lisp (Original) | MeTTa (This Edition) |
|----------------|---------------------|
| List processing | Pattern matching on expressions |
| Sequential execution | Nondeterministic evaluation |
| Dynamic typing | Gradual dependent types |
| Functions as data | Knowledge in the Atomspace |

## Getting Started

### Running MeTTa

Install the MeTTa interpreter:

```bash
pip install hyperon
```

Run MeTTa files:

```bash
metta script.metta
```

### Quick Example

```metta
; Define facts
(Sam is a frog)
(Tom is a cat)

; Query with pattern matching
!(match &self ($who is a $what) ($who the $what))
; Returns: (Sam the frog), (Tom the cat)
```

## Chapters

### Part I: Introduction to MeTTa

- [Chapter 1: Introduction to MeTTa](chapter1.md) - Basic syntax, pattern matching, and core concepts

*More chapters coming soon...*

## About This Project

This adaptation was created to help programmers learn MeTTa through the lens of classic AI programming techniques. The original PAIP remains one of the best programming books ever written; this project aims to bring its insights to a new language designed specifically for AI.

### Credits

- Original book: Peter Norvig, *Paradigms of Artificial Intelligence Programming* (1992)
- Original online version: [norvig.github.io/paip-lisp](https://norvig.github.io/paip-lisp/)
- MeTTa language: [OpenCog Hyperon](https://hyperon.opencog.org/)

## License

This adaptation is provided for educational purposes.
