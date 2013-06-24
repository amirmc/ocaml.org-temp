
Modules
=======

Basic usage
-----------

In OCaml, every piece of code is wrapped into a module. Optionally, a
module itself can be a submodule of another module, pretty much like
directories in a file system-but we don't do this very often.

When you write a program let's say using two files `amodule.ml` and
`bmodule.ml`, each of these files automatically defines a module named
`Amodule` and a module named `Bmodule` that provide whatever you put
into the files.

Here is the code that we have in our file `amodule.ml`:

    let hello () = print_endline "Hello"

And here is what we have in `bmodule.ml`:

    Amodule.hello ()

Usually files are compiled one by one, let's do it:

    ocamlopt -c amodule.ml
    ocamlopt -c bmodule.ml
    ocamlopt -o hello amodule.cmx bmodule.cmx

Now we have a wonderful executable that prints "Hello". As you can see,
if you want to access anything from a given module, use the name of the
module (always starting with a capital) followed by a dot and the thing
that you want to use. It may be a value, a type constructor, or anything
else that a given module can provide.

Libraries, starting with the standard library, provide collections of
modules. for example, `List.iter` designates the `iter` function from
the `List` module.

OK, if you are using a given module heavily, you may want to make its
contents directly accessible. For this, we use the `open` directive. In
our example, `bmodule.ml` could have been written:

    open Amodule;;
    hello ();;

As a side note, people tend to avoid the ugly ";;", so it more common to
write it like:

    open Amodule
    let () =
      hello ()

Anyway, using `open` or not is a matter of personal taste. Some modules
provide names that are used in many other modules. This is the case of
the `List` module for instance. Usually we don't do `open List`. Other
modules like `Printf` provide names that are normally not subject to
conflicts, such as `printf`. In order to avoid writing `Printf.printf`
all over the place, it often makes sense to place one `open Printf` at
the beginning of the file.

There is a short example illustrating what we just mentioned:

    open Printf
    let my_data = [ "a"; "beautiful"; "day" ]
    let () = List.iter (fun s -> printf "%s\n" s) my_data

Interfaces and signatures
-------------------------

A module can provide a certain number of things (functions, types,
submodules, ...) to the rest of the program that is using it. If nothing
special is done, everything which is defined in a module will be
accessible from outside. That's often fine in small personal programs,
but there are many situations where it is better that a module only
provides what it is meant to provide, not any of the auxilliary
functions and types that are used internally.

For this we have to define a module interface, which will act as a mask
over the module's implementation. Just like a module derives from a .ml
file, the corresponding module interface or signature derives from a
.mli file. It contains a list of values with their type, and more. Let's
rewrite our `amodule.ml` file:

    let message = "Hello"
    let hello () = print_endline message

As it is, `Amodule` has the following interface:

    val message : string
    val hello : unit -> unit

Let's assume that accessing the `message` value directly is none of the
others modules' business. We want to hide it by defining a restricted
interface. This is our `amodule.mli` file:

    val hello : unit -> unit
    (** displays a greeting message *)

(note that it is a good habit to document .mli files, using the format
supported by
[ocamldoc](http://caml.inria.fr/pub/docs/manual-ocaml/manual029.html "http://caml.inria.fr/pub/docs/manual-ocaml/manual029.html"))

.mli files must be compiled just before the matching .ml files. They are
compiled using `ocamlc`, even if .ml files are compiled to native code
using `ocamlopt`:

    ocamlc -c amodule.mli
    ocamlopt -c amodule.ml
    ...

Abstract types
--------------

What about type definitions? We saw that values such as functions can be
exported by placing their name and their type in a .mli file, e.g.

    val hello : unit -> unit

But modules often define new types. Let's define a simple record type
that would represent a date:

    type date = { day : int;
                  month : int;
                  year : int }

There are not two, but four options when it comes to writing the .mli
file:

1.  The type is completely omitted from the signature.
2.  The type definition is copy-pasted into the signature.
3.  The type is made abstract: only its name is given.
4.  The record fields are made read-only: `type date = private { ... }`

In case 3, it would be the following code:

    type date

Now, users of the module can manipulate objects of type `date`, but they
can't access the record fields directly. They must use the functions
that the module provides. Let's assume the module provides three
functions, one for creating a date, one for computing the difference
between two dates, and one that returns the date in years:

    type date
    val create : ?days:int -> ?months:int -> ?years:int -> unit -> date
    val sub : date -> date -> date
    val years : date -> float

The point is that only `create` and `sub` can be used to create `date`
records. Therefore, it is not possible for the user of the module to
create ill-formed records. Actually, our implementation uses a record,
but we could change it and be sure that it will not break any code that
relies on this module! This takes all its sense in a library since
subsequent versions of the same library can continue to expose the same
interface, while internally changing the implementation, including data
structures.

Submodules
----------

### Submodule implementation

We saw that one `example.ml` file results automatically in one module
implementation named `Example`. Its module signature is automatically
derived and is the broadest possible, or can be restricted by writing an
`example.mli` file.

That said, a given module can also be defined explicitely from within a
file. That makes it a submodule of the current module. Let's consider
this `example.ml` file:

    module Hello = struct
      let message = "Hello"
      let hello () = print_endline message
    end
    let goodbye () = print_endline "Goodbye"
    let hello_goodbye () =
      Hello.hello ();
      goodbye ()

From another file, it is clear that we now have two levels of modules.
We can write:

    let () =
      Example.Hello.hello ();
      Example.goodbye ()

### Submodule interface

We can also restrict the interface of a given submodule. It is called a
module type. Let's do it in our `example.ml` file:

    module Hello : sig
     val hello : unit -> unit
    end = 
    struct
      let message = "Hello"
      let hello () = print_endline message
    end

    (* At this point, Hello.message is not accessible anymore. *)
    let goodbye () = print_endline "Goodbye"
    let hello_goodbye () =
      Hello.hello ();
      goodbye ()

The definition of the `Hello` module above is the equivalent of a
`hello.mli`/`hello.ml` pair of files. Writing all of that in one block
of code is not elegant, so in general we prefer to define the module
signature separately:

    module type Hello_type = sig
     val hello : unit -> unit
    end

    module Hello : Hello_type = struct
      ...
    end

`Hello_type` is a named module type, and can be reused to define other
module interfaces.

Although having submodules may be useful in some cases, their real
utility becomes apparent with functors. This is the next section.

Functors
--------

Functors are probably one of the most complex features of OCaml, but you
don't have to use them extensively to be a successful OCaml programmer.
Actually, you may never have to define a functor yourself, but you will
surely encounter them in the standard library. They are the only way of
using the Set and Map modules, but using them is not so difficult.

### What is a functor and why do we need them?

A functor is a module that is parametrized by another module, just like
a function is a value which is parametrized by other values, the
arguments.

Basically, it allows to parametrize a type by a value, which is not
possible directly in OCaml. For example, we can define a functor that
takes an int n and returns a collection of array operations that work
exclusively on arrays of length n. If by mistake the programmer passes a
regular array to one of those functions, it will result in a compilation
error. If we were not using this functor but the standard array type,
the compiler would not be able to detect the error, and we would get a
runtime error at some undetermined date in the future, which is much
worse.

### How to use an existing functor?

The standard library defines a `Set` module, which provides a `Make`
functor. This functor takes one argument, which is a module that
provides (at least) two things: the type of elements, given as `t` and
the comparison function given as `compare`. The point of the functor is
to ensure that the same comparison function will always be used, even if
the programmer makes a mistake.

For example, if we want to use sets of ints, we would use do this:

    module Int_set = Set.Make (struct
                                 type t = int
                                 let compare = compare
                               end)

For sets of strings, it is even easier because the standard library
provides a `String` module with a type `t` and a function `compare`. If
you were following carefully, by now you must have guessed how to create
a module for the manipulation of sets of strings:

    module String_set = Set.Make (String)

(the parentheses are necessary)

### How to define a functor?

A functor with one argument can be defined like this:

    module F (X : X_type) = struct
     ...
    end

where `X` is the module that will be passed as argument, and `X_type` is
its signature, which is mandatory.

The signature of the returned module itself can be constrained, using
this syntax:

    module F (X : X_type) : Y_type =
    struct
      ...
    end

or by specifying this in the .mli file:

    module F (X : X_type) : Y_type

Overall, the syntax of functors is hard to grasp. The best may be to
look at the source files `set.ml` or `map.ml` of the standard library.

Final remark: functors are made to help programmers write correct
programs, not to improve performance. There is even a runtime penalty,
unless you use a defunctorizer such as ocamldefun, which requires access
to the source code of the functor.

Practical manipulation of modules
---------------------------------

### Displaying the interface of a module

In the `ocaml` toplevel, the following trick allows to visualize the
contents of an existing module, such as `List`:

    # module M = List;;module M :
      sig
        val length : 'a list -> int
        val hd : 'a list -> 'a
        val tl : 'a list -> 'a list
        val nth : 'a list -> int -> 'a
        val rev : 'a list -> 'a list
        val append : 'a list -> 'a list -> 'a list
        val rev_append : 'a list -> 'a list -> 'a list
        val concat : 'a list list -> 'a list
        val flatten : 'a list list -> 'a list
        val iter : ('a -> unit) -> 'a list -> unit
        val iteri : (int -> 'a -> unit) -> 'a list -> unit
        val map : ('a -> 'b) -> 'a list -> 'b list
        val mapi : (int -> 'a -> 'b) -> 'a list -> 'b list
        val rev_map : ('a -> 'b) -> 'a list -> 'b list
        val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a
        val fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
        val iter2 : ('a -> 'b -> unit) -> 'a list -> 'b list -> unit
        val map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
        val rev_map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
        val fold_left2 : ('a -> 'b -> 'c -> 'a) -> 'a -> 'b list -> 'c list -> 'a
        val fold_right2 :
          ('a -> 'b -> 'c -> 'c) -> 'a list -> 'b list -> 'c -> 'c
        val for_all : ('a -> bool) -> 'a list -> bool
        val exists : ('a -> bool) -> 'a list -> bool
        val for_all2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
        val exists2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
        val mem : 'a -> 'a list -> bool
        val memq : 'a -> 'a list -> bool
        val find : ('a -> bool) -> 'a list -> 'a
        val filter : ('a -> bool) -> 'a list -> 'a list
        val find_all : ('a -> bool) -> 'a list -> 'a list
        val partition : ('a -> bool) -> 'a list -> 'a list * 'a list
        val assoc : 'a -> ('a * 'b) list -> 'b
        val assq : 'a -> ('a * 'b) list -> 'b
        val mem_assoc : 'a -> ('a * 'b) list -> bool
        val mem_assq : 'a -> ('a * 'b) list -> bool
        val remove_assoc : 'a -> ('a * 'b) list -> ('a * 'b) list
        val remove_assq : 'a -> ('a * 'b) list -> ('a * 'b) list
        val split : ('a * 'b) list -> 'a list * 'b list
        val combine : 'a list -> 'b list -> ('a * 'b) list
        val sort : ('a -> 'a -> int) -> 'a list -> 'a list
        val stable_sort : ('a -> 'a -> int) -> 'a list -> 'a list
        val fast_sort : ('a -> 'a -> int) -> 'a list -> 'a list
        val merge : ('a -> 'a -> int) -> 'a list -> 'a list -> 'a list
      end

Otherwise, there is online documentation for most libraries or you can
use `ocamlbrowser` which comes with labltk (Tk graphical user interface
for OCaml).

### Module inclusion

Let's say we feel that a function is missing from the standard `List`
module, but we really want it as if it were part of it. In an
`extensions.ml` file, we can achieve this effect by using the `include`
directive:

    module List = struct
      include List
      let rec optmap f = function
        | [] -> []
        | hd :: tl ->
           match f hd with
           | None -> optmap f tl
           | Some x -> x :: optmap f tl
    end

It creates a module `Extensions.List` that has everything the standard
`List` module has, plus a new `optmap` function. From another file, all
we have to do to override the default `List` module is `open Extensions`
at the beginning of the .ml file:

    open Extensions
    ...
    List.optmap ...
