
*Table of contents*

-   [Status of pointers in OCaml](#status)
-   [Defining pointers in Caml](#def)
-   [Integer Lists](#integer-lists)
-   [Polymorphic lists](#polymorphic-lists)

Pointers in OCaml
=================

Status of pointers in OCaml
---------------------------

Pointers exist in Caml, and in fact they spread all over the place. They
are used either implicitely (in the most cases), or explicitely (in the
rare occasions where implicit pointers are not more handy). The vast
majority of pointers usages that are found in usual programming
languages simply disapear in Caml, or more exactly, those pointers are
totally automatically handled by the compiler and the Caml programmer
can safely just ignore their existence, focusing on the semantic of its
program. \
 For instance lists or trees are defined without explicit pointers using
a concrete datatype definition. The underlying implementation uses
pointers, but this is transparent to the programmer since pointer
handling is done by the compiler.

In the rare occasions where explicit pointers are needed (the most
common case is when translating in Caml an algorithm described in a
classic imperative language), Caml provides references that are
full-fledged pointers, even first class citizen pointers (references can
be passed as argument, embedded into arbitrary data structures, and
returned as function results).

### Explicit pointers are Caml values of type `ref`

You can program directly with explicit references if you want to, but
this is normally a waste of time and effort.

Let's examine the simple example of linked lists (integer lists to be
simple). This data type is defined in C (or in Pascal) using explicit
pointers, for instance:

~~~~ {.listing}
/* Cells and lists type in C */
struct cell {
  int hd;
  struct cell *tl;
};

typedef struct cell cell, *list;
~~~~

~~~~ {.listing}
{Cells and lists type in Pascal}
type
 list = ^cell;
 cell = record
  hd: integer;
  tl: cell;
 end;
~~~~

We can translate this in Caml, using a sum type definition, without
pointers:

    type list = Nil | Cons of int * list

Cell lists are thus represented as pairs, and the recursive structure of
lists is evident, with the two alternatives, empty list (the
`Nil`constructor) and non empty list (the `Cons` constructor).\
 Automatic management of pointers and automatic memory allocation shine
when allocating list values: one just writes `Cons (x, l)` to add `x` in
front of the list `l`. In C, you need to write this function, to
allocate a new cell and then fill its fields. For instance:

~~~~ {.listing}
/* The empty list */
#define nil NULL

/* The constructor of lists */
list cons (element x, list l)
{
  list result;
  result = (list) malloc (sizeof (cellule));
  result -> hd = x;
  result -> tl = l;
  return (result);
}
~~~~

Similarly, in Pascal:

~~~~ {.listing}
{Creating a list cell}
function cons (x: integer; l: list): list;
 var p: list;
 begin
  new(p);
  p^.hd := x;
  p^.tl := l;
  cons := p
 end;
~~~~

We thus see that fields of list cells in the C program have to be
mutable, otherwise initialization is impossible. By contrast in Caml,
allocation and initialization are merged into a single basic operation:
constructor application. This way, immutable data structures are
definable (those data types are often refered to as “pure” or
“functionnal” data structures). If physical modifications are necessary
for other reasons than mere initialization, Caml provides records with
mutable fields. For instance, a list type defining lists whose elements
can be in place modified could be written:

    type list = Nil | Cons of cell
    and cell = { mutable hd : int; tl : list }

If the structure of the list itself must also be modified (cells must be
physically removed from the list), the `tl` field would also be declared
as mutable:

    type list = Nil | Cons of cell
    and cell = {mutable hd : int; mutable tl : list};;

Physical assignments are still useless to allocate mutable data: you
write `Cons {hd = 1; tl = l}` to add `1` to the list `l`. Physical
assigments that remain in Caml programs should be just those assignments
that are mandatory to implement the algorithm at hand.

### Pointers and mutable fields or vectors

Very often, pointers are used to implement physical modification of data
structures. In Caml programs this means using vectors or mutable fields
in records. For this kind of use of pointers, the Pascal's instruction:
`x^.label := val` (where `x` is a value of a record having a `label`
field) corresponds to the Caml construct `x.label <- val` (where `x` is
a value of a record having a `label` mutable field). The Pascal's `^`
symbol simply disapears, since dereferencing is automatically handled by
the Caml compiler.

**In conclusion:** You can use explicit pointers in Caml, exactly as in
Pascal or C, but this is not natural, since you get back the usual
drawbacks and difficulties of explicit pointers manipulation of
classical algorithmic languages. See a more complete example below.

Defining pointers in Caml
-------------------------

The general pointer type can be defined using the definition of a
pointer: a pointer is either null, or a pointer to an assignable memory
location:

    # type 'a pointer = Null | Pointer of 'a ref;;type 'a pointer = Null | Pointer of 'a ref

Explicit dereferencing (or reading the pointer's designated value) and
pointer assignment (or writing to the pointer's designated memory
location) are easily defined. We define dereferencing as a prefix
operator named `!^`, and assigment as the infix `^:=`.

    # let ( !^ ) = function
        | Null -> invalid_arg "Attempt to dereference the null pointer"
        | Pointer r -> !r;;val ( !^ ) : 'a pointer -> 'a = <fun>
    # let ( ^:= ) p v =
        match p with
        | Null -> invalid_arg "Attempt to assign the null pointer"
        | Pointer r -> r := v;;val ( ^:= ) : 'a pointer -> 'a -> unit = <fun>

Now we define the allocation of a new pointer initialized to points to a
given value:

    # let new_pointer x = Pointer (ref x);;val new_pointer : 'a -> 'a pointer = <fun>

For instance, let's define and then assign a pointer to an integer:

    # let p = new_pointer 0;;val p : int pointer = Pointer {contents = 0}
    # p ^:= 1;;- : unit = ()
    # !^p;;- : int = 1

Integer Lists
-------------

Now we can define lists using explicit pointers as in usual imperative
languages:

    # (* The list type ``à la Pascal'' *)
      type ilist = cell pointer
      and cell = {mutable hd : int; mutable tl : ilist};;type ilist = cell pointer
    and cell = { mutable hd : int; mutable tl : ilist; }

We then define allocation of a new cell, the list constructor and its
associated destructors.

    # let new_cell () = {hd = 0; tl = Null};;val new_cell : unit -> cell = <fun>
    # let cons x l =
        let c = new_cell () in
        c.hd <- x;
        c.tl <- l;
        (new_pointer c : ilist);;val cons : int -> ilist -> ilist = <fun>
    # let hd (l : ilist) = !^l.hd;;val hd : ilist -> int = <fun>
    # let tl (l : ilist) = !^l.tl;;val tl : ilist -> ilist = <fun>

We can now write all kind of classical algorithms, based on pointers
manipulation, with their associated loops, their unwanted sharing
problems and their null pointer errors. For instance, list
concatenation, as often described in litterature, physically modifies
its first list argument, hooking the second list to the end of the
first:

    # (* Physical append *)
      let append (l1 : ilist) (l2 : ilist) =
        let temp = ref l1 in
        while tl !temp <> Null do
          temp := tl !temp
        done;
        !^ !temp.tl <- l2;;File "", line 7, characters 13-15:
    Error: The record field label tl belongs to the type cell
           but is mixed here with labels of type ilist = cell pointer
    # (* An example: *)
      let l1 = cons 1 (cons 2 Null);;val l1 : ilist =
      Pointer
       {contents = {hd = 1; tl = Pointer {contents = {hd = 2; tl = Null}}}}
    # let l2 = cons 3 Null;;val l2 : ilist = Pointer {contents = {hd = 3; tl = Null}}
    # append l1 l2;;File "", line 1, characters 0-6:
    Error: Unbound value append

The lists `l1` and `l2` are effectively catenated:

    # l1;;- : ilist =
    Pointer {contents = {hd = 1; tl = Pointer {contents = {hd = 2; tl = Null}}}}

Just a nasty side effect of physical list concatenation: `l1` now
contains the concatenation of the two lists `l1` and `l2`, thus the list
`l1` no longer exists: in some sense `append` *consumes* its first
argument. In other words, the value of a list data now depends on its
history, that is on the sequence of function calls that use the value.
This strange behaviour leads to a lot of difficulties when explicitely
manipulating pointers. Try for instance, the seemingly harmless:

    # append l1 l1;;File "", line 1, characters 0-6:
    Error: Unbound value append

Then evaluate `l1`:

    # l1;;- : ilist =
    Pointer {contents = {hd = 1; tl = Pointer {contents = {hd = 2; tl = Null}}}}

Polymorphic lists
-----------------

To go beyond Pascal type system, we define polymorphic lists using
pointers; here is a simple implementation of those polymorphic mutable
lists:

    # type 'a lists = 'a cell pointer
      and 'a cell = {mutable hd : 'a pointer; mutable tl : 'a lists};;type 'a lists = 'a cell pointer
    and 'a cell = { mutable hd : 'a pointer; mutable tl : 'a lists; }
    # let new_cell () = {hd = Null; tl = Null};;val new_cell : unit -> 'a cell = <fun>
    # let cons x l =
        let c = new_cell () in
        c.hd <- new_pointer x;
        c.tl <- l;
        (new_pointer c : 'a lists);;val cons : 'a -> 'a lists -> 'a lists = <fun>
    # let hd (l : 'a lists) = !^l.hd;;val hd : 'a lists -> 'a pointer = <fun>
    # let tl (l : 'a lists) = !^l.tl;;val tl : 'a lists -> 'a lists = <fun>
    # let append (l1 : 'a lists) (l2 : 'a lists) =
        let temp = ref l1 in
        while tl !temp <> Null do
          temp := tl !temp
        done;
        !^ !temp.tl <- l2;;File "", line 6, characters 13-15:
    Error: The record field label tl belongs to the type 'b cell
           but is mixed here with labels of type 'a lists = 'a cell pointer
