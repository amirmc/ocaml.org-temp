---
layout: page
title: 100 lines of OCaml
short_title: 100 lines
section: Learn
---

OCaml possesses an [interactive systems](#) called “toploop”, that lets you type OCaml code and have it evaluated immediately. It is a great way to learn the language and to quickly experiment with ideas. Below, we demonstrate the use of the top loop to illustrate basic capabilities of the language.


## Elementary functions

<dl class="row">
    <dt class="span4">
        {% highlight ocaml %}# let square x = x * x;;
val square : int -> int = <fun>
# square 3;;
- : int = 9
# let rec fact x =
    if x <= 1 then 1 else x * fact (x - 1);;
val fact : int -> int = <fun>
# fact 5;;
- : int = 120
# square 120;;
- : int = 14400{% endhighlight %}
    </dt>
    <dd class="span4">
        Let us define the square function and the recursive factorial function. Then, let us apply these functions to sample values. Note that, contrarily to popular languages, OCaml uses parentheses for grouping but not for the arguments of a function.   
    </dd>
</dl>


## Automatic memory management

<dl class="row">
    <dt class="span4">
        {% highlight ocaml %}# let l = 1 :: 2 :: 3 :: [];;
val l : int list = [1; 2; 3]
# [1; 2; 3];;
- : int list = [1; 2; 3]
# 5 :: l;;
- : int list = [5; 1; 2; 3]{% endhighlight %}
    </dt>
    <dd class="span4">
        All allocation and deallocation operations are fully automatic. For example, let us consider simply linked lists. Lists are predefined in OCaml. The empty list is written <code>[]</code>. The constructor that allows prepending an element to a list is written <code>::</code> (in infix form).
    </dd>
</dl>


## Polymorphism: sorting lists

<dl class="row">
    <dt class="span4">
        {% highlight ocaml %}# let rec sort = function
  | [] -> []
  | x :: l -> insert x (sort l)
and insert elem = function
  | [] -> [elem]
  | x :: l -> if elem < x then                elem :: x :: l
              else x :: insert                elem l;;
val sort : 'a list -> 'a list = <fun>
val insert : 'a -> 'a list -> 'a list = <fun>{% endhighlight %}
    </dt>
    <dd class="span4">
        Insertion sort is defined using two recursive functions.
    </dd>
</dl>

<dl class="row">
    <dt class="span4">
        {% highlight ocaml %}# sort [2; 1; 0];;
- : int list = [0; 1; 2]
# sort ["yes"; "ok"; "sure"; "ya"; "yep"];;
- : string list = ["ok"; "sure"; "ya"; "yep"; "yes"]{% endhighlight %}
    </dt>
    <dd class="span4">
        Note that the type of the list elements remains unspecified: it is represented by a type <em>variable</em> <code>'a</code>. Thus <code>sort</code> can be applied both to a list of integers and to a list of strings.
    </dd>
</dl>