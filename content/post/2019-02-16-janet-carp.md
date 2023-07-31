+++
author = "Mari Donkers"
title = "Janet and Carp"
date = "2019-02-16"
description = "Janet is a functional and imperative programming language. It runs on Windows, Linux, macOS, and should run on other systems with some porting. The entire language (core library, interpreter, compiler, assembler) is about 200-300 kB and should run on many constrained systems."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Lisp",
    "Embedded",
]
categories = [
    "lisp",
]
series = ["Lisp"]
aliases = ["2019-02-16-janet-carp"]
thumbnail = "/images/lisp.svg"
+++

Two Lisps. [Janet](https://janet-lang.org/) and [Carp](https://github.com/carp-lang/Carp).
<!--more-->

# Janet

[Janet](https://janet-lang.org/) is a functional and imperative programming language. It runs on Windows, Linux, macOS, and should run on other systems with some porting. The entire language (core library, interpreter, compiler, assembler) is about 200-300 kB and should run on many constrained systems. (by **[janet-lang](https://github.com/janet-lang)**)

Features:

- Minimal setup - one binary and you are good to go!
- First class closures
- Garbage collection
- First class green threads (continuations)
- Python style generators (implemented as a plain macro)
- Mutable and immutable arrays (array/tuple)
- Mutable and immutable hashtables (table/struct)
- Mutable and immutable strings (buffer/string)
- Lisp Macros
- Byte code interpreter with an assembly interface, as well as bytecode verification
- Tailcall Optimization
- Direct interop with C via abstract types and C functions
- Dynamically load C libraries
- Functional and imperative standard library
- Lexical scoping
- Imperative programming as well as functional
- REPL
- Parsing Expression Grammars built in to the core library
- 300+ functions and macros in the core library
- Interactive environment with detailed stack traces

# Carp

[Carp](https://github.com/carp-lang/Carp) is a small programming language designed to work well for interactive and performance sensitive use cases like games, sound synthesis and visualizations. (by [carp-lang](https://github.com/carp-lang))

The key features of Carp are the following:

Automatic and deterministic memory management (no garbage collector or VM) Inferred static types for great speed and reliability Ownership tracking enables a functional programming style while still using mutation of cache-friendly data structures under the hood No hidden performance penalties – allocation and copying are explicit Straightforward integration with existing C code

is a functional and imperative programming language. It runs on Windows, Linux, macOS, and should run on other systems with some porting. The entire language (core library, interpreter, compiler, assembler) is about 200-300 kB and should run on many constrained systems.
