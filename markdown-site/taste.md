
A Hundred Lines of OCaml
========================

*Table of contents*

-   [Elementary functions](#elementary)
-   [Automatic memory management](#memory)
-   [Polymorphism: sorting lists](#polymorphism)
-   [Imperative features](#imperative)
-   [Higher-order functions](#functionality)
-   [The power of functions](#power)
-   [Symbolic computation](#symbolic)
-   [Elementary debugging](#debugging)

OCaml possesses an [interactive system](description.html#interactive),
called “toploop”, that lets you type OCaml code and have it evaluated
immediately. It is a great way to learn the language and to quickly
experiment with ideas. Below, we demonstrate the use of the toploop to
illustrate basic capabilities of the language.

Some indications for the code below. The prompt at which you type is
“`#`”. The code must end with “`;;`” (this is only an indication to the
interactive system that the input has to be evaluated and is not really
part of the OCaml code). The output of the system is displayed in
`this color`.

Elementary functions
--------------------

Let us define the square function and the recursive factorial function.
Then, let us apply these functions to sample values. Unlike the majority
of languages, OCaml uses parentheses for grouping but not for the
arguments of a function.

~~~~ {.listing}
# let square x = x * x;;val square : int -> int = <fun>
# square 3;;- : int = 9
# let rec fact x =
    if x <= 1 then 1 else x * fact (x - 1);;val fact : int -> int = <fun>
# fact 5;;- : int = 120
# square 120;;- : int = 14400
~~~~

Automatic memory management
---------------------------

All allocation and deallocation operations are fully automatic. For
example, let us consider simply linked lists.

Lists are predefined in OCaml. The empty list is written `[]`. The
constructor that allows prepending an element to a list is written `::`
(in infix form).

~~~~ {.listing}
# let l = 1 :: 2 :: 3 :: [];;val l : int list = [1; 2; 3]
# [1; 2; 3];;- : int list = [1; 2; 3]
# 5 :: l;;- : int list = [5; 1; 2; 3]
~~~~

Polymorphism: sorting lists
---------------------------

Insertion sort is defined using two recursive functions.

~~~~ {.listing}
# let rec sort = function
  | [] -> []
  | x :: l -> insert x (sort l)
and insert elem = function
  | [] -> [elem]
  | x :: l -> if elem < x then elem :: x :: l
              else x :: insert elem l;;val sort : 'a list -> 'a list = <fun>
val insert : 'a -> 'a list -> 'a list = <fun>
~~~~

Note that the type of the list elements remains unspecified: it is
represented by a *type variable* `'a`. Thus, `sort` can be applied both
to a list of integers and to a list of strings.

~~~~ {.listing}
# sort [2; 1; 0];;- : int list = [0; 1; 2]
# sort ["yes"; "ok"; "sure"; "ya"; "yep"];;- : string list = ["ok"; "sure"; "ya"; "yep"; "yes"]
~~~~

Imperative features
-------------------

Let us encode polynomials as arrays of integer coefficients. Then, to
add two polynomials, we first allocate the result array, then fill its
slots using two successive `for` loops.

~~~~ {.listing}
# let add_polynom p1 p2 =
  let n1 = Array.length p1
  and n2 = Array.length p2 in
  let result = Array.create (max n1 n2) 0 in
  for i = 0 to n1 - 1 do result.(i) <- p1.(i) done;
  for i = 0 to n2 - 1 do result.(i) <- result.(i) + p2.(i) done;
  result;;# add_polynom [| 1; 2 |] [| 1; 2; 3 |];;File "", line 1, characters 0-11:
Error: Unbound value add_polynom
~~~~

OCaml offers updatable memory cells, called *references*: `ref init`
returns a new cell with initial contents `init`, `!cell` returns the
current contents of `cell`, and `cell := v` writes the value `v` into
`cell`.

We may redefine `fact` using a reference cell and a `for` loop:

~~~~ {.listing}
# let fact n =
    let result = ref 1 in
    for i = 2 to n do
      result := i * !result
    done;
    !result;;# fact 5;;- : int = 120
~~~~

Higher-order functions
----------------------

There is no restriction on functions, which may thus be passed as
arguments to other functions. Let us define a function `sigma` that
returns the sum of the results of applying a given function `f` to each
element of a list:

~~~~ {.listing}
# let rec sigma f = function
    | [] -> 0
    | x :: l -> f x + sigma f l;;val sigma : ('a -> int) -> 'a list -> int = <fun>
~~~~

Anonymous functions may be defined using the `fun` or `function`
construct:

~~~~ {.listing}
# sigma (fun x -> x * x) [1; 2; 3];;- : int = 14
~~~~

Polymorphism and higher-order functions allow defining function
composition in its most general form:

~~~~ {.listing}
# let compose f g = fun x -> f (g x);;val compose : ('a -> 'b) -> ('c -> 'a) -> 'c -> 'b = <fun>
# let square_o_fact = compose square fact;;val square_o_fact : int -> int = <fun>
# square_o_fact 5;;- : int = 14400
~~~~

The power of functions
----------------------

The power of functions cannot be better illustrated than by the `power`
function:

~~~~ {.listing}
# let rec power f n = 
    if n = 0 then fun x -> x 
    else compose f (power f (n - 1));;val power : ('a -> 'a) -> int -> 'a -> 'a = <fun>
~~~~

The `n`^th^ derivative of a function can be computed as in mathematics
by raising the derivative function to the `n`^th^ power:

~~~~ {.listing}
# let derivative dx f = fun x -> (f (x +. dx) -. f x) /. dx;;val derivative : float -> (float -> float) -> float -> float = <fun>
# let sin''' = power (derivative 1e-5) 3 sin;;val sin''' : float -> float = <fun>
# let pi = 4.0 *. atan 1.0 in sin''' pi;;- : float = 0.999998972517346263
~~~~

Symbolic computation
--------------------

Let us consider simple symbolic expressions made up of integers,
variables, `let` bindings, and binary operators. Such expressions can be
defined as a new data type, as follows:

~~~~ {.listing}
# type expression =
    | Num of int
    | Var of string
    | Let of string * expression * expression
    | Binop of string * expression * expression;;
~~~~

Evaluation of these expressions involves an environment that maps
identifiers to values, represented as a list of pairs.

~~~~ {.listing}
# let rec eval env = function
    | Num i -> i
    | Var x -> List.assoc x env
    | Let (x, e1, in_e2) ->
       let val_x = eval env e1 in
       eval ((x, val_x) :: env) in_e2
    | Binop (op, e1, e2) ->
       let v1 = eval env e1 in
       let v2 = eval env e2 in
       eval_op op v1 v2
  and eval_op op v1 v2 =
    match op with
    | "+" -> v1 + v2
    | "-" -> v1 - v2
    | "*" -> v1 * v2
    | "/" -> v1 / v2
    | _ -> failwith ("Unknown operator: " ^ op);;val eval : (string * int) list -> expression -> int = <fun>
val eval_op : string -> int -> int -> int = <fun>
~~~~

As an example, we evaluate the phrase `let   x = 1 in x   +       x`:

~~~~ {.listing}
# eval [] (Let ("x", Num 1, Binop ("+", Var "x", Var "x")));;- : int = 2
~~~~

Pattern matching eases the definition of functions operating on symbolic
data, by giving function definitions and type declarations similar
shapes. Indeed, note the close resemblance between the definition of the
`eval` function and that of the `expression` type.

Elementary debugging
--------------------

To conclude, here is the simplest way of spying over functions:

~~~~ {.listing}
# let rec fib x = if x <= 1 then 1 else fib (x - 1) + fib (x - 2);;val fib : int -> int = <fun>
# #trace fib;;
fib is now traced.
# fib 3;;
fib <-- 3
fib <-- 1
fib --> 1
fib <-- 2
fib <-- 0
fib --> 1
fib <-- 1
fib --> 1
fib --> 2
fib --> 3
- : int = 3
~~~~

Go and [try it in your browser](http://try.ocamlpro.com/) or
[install](install.html) it and read some [tutorials](tutorials/).
