---
layout: page
title: What is Ocaml?
short_title: About
section: Learn
---

**OCaml** is a general purpose industrial-strength programming language with an emphasis on expressiveness and safety. Developed for more than 20 years at Inria by a group of leading researchers, it benefits from one of the most advanced type systems and supports functional, imperative and object-oriented styles of programming which ease the development of flexible and reliable software. Used in environments where [a single mistake](#) can cost millions and speed matters, it is supported by an active community that developed [a rich set of libraries](#) and will help you to make the most of OCaml possibilities...

OCaml is a modern, high-level programming language with many useful features. See “[A History of OCaml](#)” for an account of the origins of the language.


## Strengths

The OCaml language offers:

* **A powerful type system**, equipped with parametric polymorphism and type inference. For instance, the type of a collection can be parameterized by the type of its elements. This allows defining some operations over a collection independently of the type of its elements: sorting an array is one example. Furthermore, type inference allows defining such operations without having to explicitly provide the type of their parameters and result.
* **User-definable algebraic data types and pattern-matching**. New algebraic data types can be defined as combinations of records and sums. Functions that operate over such data structures can then be defined by pattern matching, a generalized form of the well-known switch statement, which offers a clean and elegant way of simultaneously examining and naming data.
* **Automatic memory management**, thanks to a fast, unobtrusive, incremental garbage collector.
* **Separate compilation of standalone applications**. Portable bytecode compilers allow creating stand-alone applications out of Caml Light or OCaml programs. A foreign function interface allows OCaml code to interoperate with C code when necessary. Interactive use of OCaml is also supported via a “read-evaluate-print” loop.

The OCaml language offers:

* **A sophisticated module system**, which allows organizing modules hierarchically and parameterizing a module over a number of other modules.
* **An expressive object-oriented layer**, featuring multiple inheritance, parametric and virtual classes.