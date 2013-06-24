FAQ
===

See also [Stack Overflow](http://stackoverflow.com/tags/ocaml/info),
which is widely used by the OCaml community.

-   [General Questions](#general)
-   [Core Language](#ocaml)
-   [Module Language](#module)
-   [Development Tools](#tools)

Core Language
-------------

* * * * *

### Basic types

Is it possible to do computations with arbritrary precision arithmetics?

OCaml and Caml Light both provide a library that handles exact
arithmetic computation for rational numbers. The library is called `Num`
in OCaml and `camlnum` in Caml Light.\
 Operations on big numbers gets the suffix `/`: addition is thus `+/`.
You build big numbers using conversion from (small) integers or
character strings. For printing in the toplevel, a custom printer can be
used. An example under OCaml is given below.

    # #load "nums.cma";;# open Num
      open Format;;# let print_num ff n = fprintf ff "%s" (string_of_num n);;val print_num : Format.formatter -> Num.num -> unit = <fun>
    # #install_printer print_num;;# num_of_string "2/3";;- : Num.num = 2/3
    # let n = num_of_string "1/3" +/ num_of_string "2/3";;val n : Num.num = 1
    # let rec fact n =
        if n <= 0 then (num_of_int 1) else num_of_int n */ (fact (n - 1));;val fact : int -> Num.num = <fun>
    # fact 100;;- : Num.num =
    93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000

### Data structures

My array is modified, and I don't know why

This is due to the physical sharing of two arrays that you missed. In
Caml there are no implicit array copying. If you give two names to the
same array, every modification on one array will be visible to the
other:

    # let v = Array.make 3 0;;val v : int array = [|0; 0; 0|]
    # let w = v;;val w : int array = [|0; 0; 0|]
    # w.(0) <- 4;;- : unit = ()
    # v;;- : int array = [|4; 0; 0|]

The physical sharing effect also applies to elements stored in vectors:
if these elements are also vectors, the sharing of these vectors implies
that modifying one of these elements modifies the others (see also the
entry below).

How to define multidimensional arrays?

The only way is to define an array whose elements are arrays themselves
(Caml arrays are unidimensional, they modelize mathematical vectors).
The naive way to define multidimensional arrays is bogus: the result is
not right because there is some unexpected physical sharing between the
lines of the new array (see also previous entry):

    # let m = Array.make 2 (Array.make 3 0);;val m : int array array = [|[|0; 0; 0|]; [|0; 0; 0|]|]
    # m.(0).(0) <- 1;;- : unit = ()
    # m;;- : int array array = [|[|1; 0; 0|]; [|1; 0; 0|]|]

The allocation of a new array has two phases. First, the initial value
is computed; then this value is written in each element of the new
array. That's why the line which is allocated by `Array.make 3 0` is
unique and physically shared by all the lines of the array `m`.\
 The solution is to use the `make_matrix` primitive that builds the
matrix with all elements equal to the initial value provided.
Alternatively, write the program that allocates a new line for each line
of your matrix. For instance:

    # let matrix n m init =
        let result = Array.make n (Array.make m init) in
        for i = 1 to n - 1 do
          result.(i) <- Array.make m init
        done;
        result;;

In the same vein, the `copy_vect` primitive gives strange results, when
applied to matrices: you need to write a function that explicitly copies
each line of the matrix at hand:

    # let copy_matrix m =
        let l = Array.length m in
        if l = 0 then m else
          let result = Array.make l m.(0) in
          for i = 0 to l - 1 do
            result.(i) <- Array.copy m.(i)
          done;
          result;;

### Types definitions

How to define an enumerated type?

An enumerated type is a sum type with only constants. For instance, a
type with 3 constants:

    # type color = Blue | White | Red;;type color = Blue | White | Red
    # Blue;;- : color = Blue

The names `Blue`, `White` and `Red` are the constructors of the `color`
type. One can define functions on this type by pattern matching:

    # let string_of_color = function
        | Blue -> "blue"
        | White -> "white"
        | Red -> "red";;val string_of_color : color -> string = <fun>

How to share a label between two different record types?

When you define two types sharing a label name, the last defined type
hides the labels of the first type. For instance:

    # type point_3d = {x : float; y : float; z : float};;type point_3d = { x : float; y : float; z : float; }
    # type point_2d = {x : float; y : float};;type point_2d = { x : float; y : float; }
    # {x = 10.; y = 20.; z = 30.};;File "", line 1, characters 19-20:
    Error: The record field label z belongs to the type point_3d
           but is mixed here with labels of type point_2d

The simplest way to overcome this problem is simply ... to use different
names! For instance

    # type point3d = {x3d : float; y3d : float; z3d : float};;type point3d = { x3d : float; y3d : float; z3d : float; }
    # type point2d = {x2d : float; y2d : float};;type point2d = { x2d : float; y2d : float; }

With OCaml, one can propose two others solutions. First, it is possible
to use modules to define the two types in different name spaces:

    # module D3 = struct
        type point = {x : float; y : float; z : float}
      end;;module D3 : sig type point = { x : float; y : float; z : float; } end
    # module D2 = struct
        type point = {x : float; y : float}
      end;;module D2 : sig type point = { x : float; y : float; } end

This way labels can be fully qualified as `D3.x` `D2.x`:

    # {D3.x = 10.; D3.y = 20.; D3.z = 30.};;- : D3.point = {D3.x = 10.; D3.y = 20.; D3.z = 30.}
    # {D2.x = 10.; D2.y = 20.};;- : D2.point = {D2.x = 10.; D2.y = 20.}

You can also use objects that provide overloading on method names:

    # class point_3d ~x ~y ~z = object
        method x : float = x
        method y : float = y
        method z : float = z
      end;;class point_3d :
      x:float ->
      y:float ->
      z:float -> object method x : float method y : float method z : float end
    # class point_2d ~x ~y = object
        method x : float = x
        method y : float = y
      end;;class point_2d :
      x:float -> y:float -> object method x : float method y : float end

Note that objects provide you more than overloading: you can define
truly polymorphic functions, working on both `point_3d` and `point_2d`,
and you can even coerce a `point_3d` to a `point_2d`.

How to define two sum types that share constructor names?

Generally speaking you cannot. As for all other names, you must use
distinct name constructors. However, you can define the two types in two
different name spaces, i.e. into two different modules. As for labels
discussed above, you obtain constructors that can be qualified by their
module names. With OCaml you can alternatively use polymorphic variants,
i.e. constructors that are, in some sense, *predefined*, since they are
not defined by a type definition. For instance:

    # type ids = [ `Name | `Val ];;type ids = [ `Name | `Val ]
    # type person = [ `Name of string ];;type person = [ `Name of string ]
    # let f : person -> string = function `Name s -> s;;val f : person -> string = <fun>
    # let is_name : ids -> bool = function `Name -> true | _ -> false;;val is_name : ids -> bool = <fun>

### Functions and procedures

How to define a function?

In Caml, the syntax to define functions is close to the mathematical
usage: the definition is introduced by the keyword `let`, followed by
the name of the function and its arguments; then the formula that
computes the image of the argument is written after an `=` sign.

    # let successor (n) = n + 1;;val successor : int -> int = <fun>

In fact, parens surrounding the argument may be omitted, so we generally
write:

    # let successor n = n + 1;;val successor : int -> int = <fun>

How to define a recursive function?

You need to explicitly tell that you want to define a recursive
function: use “let rec” instead of “let”. For instance:

    # let rec fact n =
        if n = 0 then 1 else n * fact (n - 1);;val fact : int -> int = <fun>
    # let rec fib n =
        if n <= 1 then n else fib (n - 1) + fib (n - 2);;val fib : int -> int = <fun>

Functions may be mutually recursive:

    # let rec odd n =
        if n = 0 then true
        else if n = 1 then false else even (n - 1)
      and even n =
        if n = 0 then false
        else if n = 1 then true else odd (n - 1);;val odd : int -> bool = <fun>
    val even : int -> bool = <fun>

How to apply a function?

Functions are applied as in mathematics: write the function's name,
followed by its argument enclosed in parens: f (x). In practice, parens
are omitted in case of constants or identifiers: we write `fib 2`
instead of `fib (2)`, and `fact x` instead of `fact (x)`.\
 When the argument of a function is more complex than just an
identifier, you must enclose this argument between parentheses. In
particular you need parens when the argument is a negative constant
number: to apply `f` to `-1` you must write `f (-1)` and **not** `f -1`
that is syntactically similar to `f - 1` (hence it is a subtraction, not
an application).

How to define a procedure?

Recall that *procedures* are commands that produce an *effect* (for
instance printing something on the terminal or writing some memory
location), but have no mathematically meaningful result.\
 In Caml, there is no special treatment of procedures: they are just
considered as special cases of functions that return the special
“meaningless” value [`()`](donnees_de_base-eng.html#units). For
instance, the `print_string` primitive that prints a character string on
the terminal, just returns `()` as a way of indicating that its job has
been properly completed.\
 Procedures that do not need any meaningful argument, get `()` as dummy
argument. For instance, the `print_newline` procedure, that outputs a
newline on the terminal, gets no meaningful argument: it has type
`unit       -> unit`.\
 Procedures with argument are defined exactly as ordinary functions. For
instance:

    # let message s = print_string s; print_newline();;val message : string -> unit = <fun>
    # message "Hello world!";;Hello world!
    - : unit = ()

How to define a procedure/function that takes no argument?

Note that it is impossible to define a procedure without any argument at
all: its definition would imply to execute it, and there would be no way
to call it afterwards. In the following fragment `double_newline` is
bound to `()`, and its further evaluation never produces carriage
returns as may be erroneously expected by the user.

    # let double_newline = print_newline(); print_newline();;

    val double_newline : unit = ()
    # double_newline;;- : unit = ()

The correct definition and usage of this procedure is:

    # let double_newline () = print_newline(); print_newline();;val double_newline : unit -> unit = <fun>
    # double_newline;;- : unit -> unit = <fun>
    # double_newline ();;

    - : unit = ()

How to define a function with more than one argument?

Just write the list of successive arguments when defining the function.
For instance:

    # let sum x y = x + y;;val sum : int -> int -> int = <fun>

then gives the actual arguments in the same order when applying the
function:

    # sum 1 2;;- : int = 3

These functions are named “curried” functions, as opposed to functions
with tuples as argument:

    # let sum' (x, y) = x + y;;val sum' : int * int -> int = <fun>
    # sum' (1, 2);;- : int = 3

How to define a function that has several results?

You can define a function that return a pair or a tuple:

    # let div_mod x y = (x / y, x mod y);;val div_mod : int -> int -> int * int = <fun>
    # div_mod 15 7;;- : int * int = (2, 1)

What is an “anonymous function”?

You may use functions that have no names: we call them functional values
or anonymous functions. A functional value is introduced by the keyword
`fun`, followed by its argument, then an arrow `->` and the function
body. For instance:

    # fun x -> x + 1;;- : int -> int = <fun>
    # (fun x -> x + 1) 2;;- : int = 3

What is the difference between `fun` and `function`?

Functions are usually introduced by the keyword `fun`. Each parameter is
introduced by its own `fun` construct. For instance, the construct:

    fun x -> fun y -> ...

defines a function with two parameters `x` and `y`. An equivalent but
shorter form is:

    fun x y -> ...

Functions that use pattern-matching are introduced by the keyword
`function`. For example:

    function None -> false | Some _ -> true

My function is never applied

This is probably due to a missing argument: since Caml is a functional
programming language, there is no error when you evaluate a function
with missing arguments: in this case, a functional value is returned,
but the function is evidently not applied. Example: if you evaluate
`print_newline` without argument, there is no error, but nothing
happens. The compiler issues a warning in case of a blatant misuse.

    # print_newline;;- : unit -> unit = <fun>
    # print_newline ();;
    - : unit = ()

### Pattern matching

How to do nested pattern matching?

You imperatively need to enclose between parens a pattern matching which
is written inside another pattern matching. In effect, the internal
pattern matching “catches” all the pattern matching clauses that are
written after it. For instance:

    let f = function
      | 0 -> match ... with | a -> ... | b -> ...
      | 1 -> ...
      | 2 -> ...

is parsed as

    let f = function
      | 0 ->
         match ... with
         | a -> ...
         | b -> ...
         | 1 -> ...
         | 2 -> ...

This error may occur for every syntactic construct that involves pattern
matching: `function`, `match       .. with` and `try ... with`. The
usual trick is to enclose inner pattern matchings with `begin` and
`end`. One write:

    let f = function
      | 0 ->
         begin match ... with
         | a -> ...
         | b -> ...
         end
      | 1 -> ...
      | 2 -> ...

### Exceptions

### Typing

Error message: a type is not compatible with itself

You may obtain the message: This expression has type “some type” but is
used with type “the same some type”. This may occur very often when
using the interactive system.\
 The reason is that two types with the same name have been defined the
compiler does not confuse the two types, but the types are evidently
written the same. Consider for instance:

    # type t = T of int;;type t = T of int
    # let x = T 1;;val x : t = T 1
    # type t = T of int;;type t = T of int
    # let incr = function T x -> T (x+1);;val incr : t -> t = <fun>
    # incr x;;File "", line 1, characters 5-6:
    Error: This expression has type t/3264 but an expression was expected of type
             t/3267

This phenomenon appears when you load many times the same file into the
interactive system, since each reloading redefines the types. The
solution is to quit your interactive system and reload your files in a
new session.

A function obtained through partial application is not polymorphic
enough

The more common case to get a \`\`not polymorphic enough'' definition is
when defining a function via partial application of a general
polymorphic function. In Caml polymorphism is introduced only through
the “let” construct, and results from application are weakly polymorph;
hence the function resulting from the application is not polymorph. In
this case, you recover a fully polymorphic definition by clearly
exhibiting the functionality to the type-checker : define the function
with an explicit functional abstraction, that is, add a `function`
construct or an extra parameter (this rewriting is known as
eta-expansion):

    # let map_id = List.map (function x -> x) (* Result is weakly polymorphic *);;val map_id : '_a list -> '_a list = <fun>
    # map_id [1;2];;- : int list = [1; 2]
    # map_id (* No longer polymorphic *);;- : int list -> int list = <fun>
    # let map_id' l = List.map (function x -> x) l;;val map_id' : 'a list -> 'a list = <fun>
    # map_id' [1;2];;- : int list = [1; 2]
    # map_id' (* Still fully polymorphic *);;- : 'a list -> 'a list = <fun>

The two definitions are semantically equivalent, and the new one can be
assigned a polymorphic type scheme, since it is no more a function
application.

The type of this expression contains type variables that cannot be
generalized

This message appears when the Caml compiler tries to compile a function
or a value which is monorphic, but for which some types have not been
completely inferred. Some types variables are left in the type, which
are are called “weak” (and are displayed by an underscore: `'_a`); they
will disappear thanks to type inference as soon as enough informations
will be given.

    # let r = ref [];;val r : '_a list ref = {contents = []}
    # let f = List.map (fun x -> x);;val f : '_a list -> '_a list = <fun>

Since the expression mentionned in the error message cannot be compiled
as is, two cases must be envisioned:

-   The expression can really not be turned into a polymorphic
    expression, as in `r` above. You must use an explicit type
    annotation, in order to turn it into something completely
    monomorphic.
-   The expression can be transformed into something polymorphic through
    rewriting some part of the code (for example using
    [eta-expansion](#eta-expansion)) as in the case of `f`.

How to write a function with polymorphic arguments?

In ML, an argument of a function cannot be polymorphic inside the body
of the function; hence the following typing:

    # let f (g : 'a -> 'a) x y = g x, g y;;val f : ('a -> 'a) -> 'a -> 'a -> 'a * 'a = <fun>

The function is not as polymorphic as we could have hoped.\
 Nevertheless, in OCaml it is possible to use first-order polymorphism.
For this, you can use either records or objects; in the case of records,
you need to declare the type before using it in the function.

    # let f (o : < g : 'a. 'a -> 'a >) x y = o#g x, o#g y;;val f : < g : 'a. 'a -> 'a > -> 'b -> 'c -> 'b * 'c = <fun>
    # type id = { g : 'a. 'a -> 'a };;type id = { g : 'a. 'a -> 'a; }
    # let f r x y = r.g x, r.g y;;val f : id -> 'a -> 'b -> 'a * 'b = <fun>

FIXME: A direct way now exists.

### Intput/output

Why some printing material is mixed up and does not appear in the right
order?

If you use printing functions of the `format` module, you might not mix
printing commands from `format` with printing commands from the basic
I/O system. In effect, the material printed by functions from the
`format` module is delayed (stored into the pretty-printing queue) in
order to find out the proper line breaking to perform with the material
at hand. By contrast low level output is performed with no more
buffering than usual I/O buffering.

    # print_endline "before";
      Format.print_string "MIDDLE";
      print_endline "after";;before
    after
    MIDDLE- : unit = ()

To avoid this kind of problems you should not mix printing orders from
`format` and basic printing commands; that's the reason why when using
functions from the `format` module, it is considered good programming
habit to open `format` globally in order to completely mask low level
printing functions by the high level printing functions provided by
`format`.

General Questions
-----------------

What is OCaml?

OCaml is a programming language. It is a functional language, since the
basic units of programs are functions. It is a strongly-typed language;
it means that the objects that you use belong to a set that has a name,
called its type. In OCaml, types are managed by the computer, the user
has nothing to do about types (types are synthesized). The language is
available on almost every Unix platform (including Linux and MacOS X)
and on PCs under Windows. A brief tour on main
[features](description.html) of OCaml.

Under what licensing terms is the OCaml software available?

The OCaml system is open source software: the compiler is distributed
under the terms of the Q Public License, and its library is under LGPL;
please read the [license](license.html) document for more details. A
BSD-style license is also available for a fee through the [OCaml
Consortium](support.html#consortium).

What is the meaning of the name “OCaml”

“Caml” is an acronym: it stands for “Categorical Abstract Machine
Language”. The “Categorical Abstract Machine” is an abstract machine to
define and execute functions. It is issued from theoretical
considerations on the relationship between category theory and
lambda-calculus. The first Caml compiler produced code for this abstract
machine (in 1984). The “O” stands for “Objective” and was added after
object oriented features were available in the language.\
 In addition, OCaml is issued from the ML programming language, designed
by Robin Milner in 1978, and used as the programming language to write
the “proof tactics” in the LCF proof system.

Do you write “Caml” or “CAML”, “OCaml”, “Ocaml” or “OCAML”?

We write OCaml.\
 According to usual rules for acronyms, we should write CAML, as we
write USA. On the other hand, this upper case name seems to yell all
over the place, and writing OCaml is far more pretty and elegant — with
“O” and “C” capitalized.

Is OCaml a compiled or interpreted language?

OCaml is compiled. However each OCaml compiler offers a top-level
interactive loop, that is similar to an interpreter. In fact, in the
interactive system, the user may type in program chunks (we call these
pieces OCaml “phrases”) that the system handles at once, compiling them,
executing them, and writing their results.

What are the differences between Caml V3.1, Caml Light, and OCaml?

These are different Caml implementations that have been developed
successively at Inria. These systems share many features since they all
implement the core of the OCaml language; so the basic syntax is nearly
the same. However, all these systems have their own extensions to the
Caml core language.\
 Caml V3.1 is no longer maintained nor distributed. [Caml
Light](caml-light/) is no longer developed, but still maintained.
Because of its stable status, it is actively used in education. Most
other users have switched to OCaml, the latest variant of the language.
This is the version we suggest using in new software developments. See
our brief [history](history.html) of the OCaml language.

How to report a bug in the compilers?

Use the [bug tracking system](http://caml.inria.fr/mantis/) to browse
bug reports and features request, and submit new ones.

Module Language
---------------

Can I have two mutually recursive compilation units / structures /
signatures / functors?

Currently not in the stable langage. However there exists an [OCaml
extension](http://caml.inria.fr/pub/docs/manual-ocaml/manual021.html#toc75)
(which is subject to change or removal at any time) which adresses some
of these problems.

How do I express sharing constraints between modules?

Use manifest type specifications in the arguments of the functor. For
instance, assume defined the following signatures:

    module type S1 = sig ... type t ... end
    module type S2 = sig ... type u ... end

To define a functor `F` that takes two arguments `X:S1` and `Y:S2` such
that `X.t` and `Y.u` are the same, write:

    module F (X: S1) (Y: S2 with type u = X.t) =
      struct ... end

Indeed, internally this expands to

    module F (X: S1) (Y: sig ... type u = X.t ... end) =
      struct ... end

Compilation units are forced to be modules. What if I want to make a
unit with a functor or a signature instead?

In OCaml, functors and signatures (module types) can be components of
modules. So, just make the functor or signature be a component of a
compilation unit. A good example is the module `Set` from the standard
library.

Development Tools
-----------------

### Interactive loop (toplevel)

How to stop the evaluation (execution) of an expression?

It is often possible to interrupt a program or the Caml system by typing
some combination of keys that is operating system dependent: under Unix
send an interrupt signal (generally `Control-C`), under Macintosh OS
type `Command-.`, under Windows use the “Caml” menu.

How to quit the interactive loop?

With Caml Light, type `quit();;`. With OCaml, type `#quit;;`. In both,
you can also send an end-of-file (CTRL-D for Unix, CTRL-Z for DOS,
etc.).

### Batch Compilers

### Yacc

### Lex
