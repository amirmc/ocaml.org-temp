**OCaml** is a general purpose industrial-strength programming language
with an emphasis on expressiveness and safety. Developed for more than
20 years at Inria it benefits from one of the most advanced type systems
and supports functional, imperative and object-oriented styles of
programming. [Read more...](description.html)

Discover
--------

-   [What is OCaml?](description.html)
-   [Try it Online](http://try.ocamlpro.com/)
-   [100 Lines of OCaml](taste.html)
-   [Success Stories](success.html)
-   [Who Is Using It?](companies.html)
-   [Pleac](http://pleac.sourceforge.net/pleac_ocaml/),
    [Rosetta](http://rosettacode.org/wiki/Category:OCaml),
    [langref.org](http://langref.org/ocaml)

Learn
-----

-   [Install](install.html)
-   [Tutorials](tutorials/index.html)
-   [FAQ](faq.html)
-   [Books](books.html)
-   [Videos](videos.html)
-   [Papers](papers.html)

Use
---

-   [Releases](releases/)
-   [Libraries](libraries.html)
-   [Development Tools](dev_tools.html)
-   [User Manual](books.html#manual)
-   [Cheat Sheets](cheat_sheets.html)
-   [OCaml API Search](http://search.ocaml.jp/)
-   [Forge](http://forge.ocamlcore.org/),
    [GitHub](https://github.com/languages/OCaml),
    [Bitbucket](https://bitbucket.org/repo/all?name=ocaml)

Community
---------

-   [Mailing Lists](mailing_lists.html)
-   [Blogs](planet/)
-   [Meetings](meetings/)
-   IRC ([en](irc://irc.freenode.net/ocaml),
    [fr](irc://irc.freenode.net/ocaml-fr))
-   [Stack
    Overflow](http://stackoverflow.com/questions/tagged?tagnames=ocaml),
    [Reddit](http://www.reddit.com/r/ocaml/)
-   [Commercial Support](support.html)

[![download](img/download-orange-green-arrow.svg)](install.html)

#### OCaml 2013

The OCaml Users and Developers Workshop

Boston MA, United States, Sep 24

[Submit a Talk](meetings/ocaml/2013/)\

#### Commercial Users of Functional Programming 2013

Boston MA, United States, Sep 22-24

[Submit a Talk](http://cufp.org/2013cfp)\

A taste of OCaml
----------------

~~~~ {.listing}
(* Binary tree with leaves carrying an integer. *)
type tree = Leaf of int | Node of tree * tree

let rec exists_leaf test tree =
  match tree with
  | Leaf v -> test v
  | Node (left, right) ->
      exists_leaf test left
      || exists_leaf test right

let has_even_leaf tree =
  exists_leaf (fun n -> n mod 2 = 0) tree
~~~~

OCaml is a lot more powerful than this simple example shows. Pursue with
[a stronger taste](taste.html)!

News from the community
-----------------------

-   [Full Time: Software Developer (Functional Programming) at Jane
    Street in New York, NY; London, UK; Hong
    Kong](planet#95e24529fbb0f6445d9ce28f00b17d68) — 13 Jun 2013
-   [mlorg](planet#5f7a374c28a50f4d973f0006ed694760) — 13 Jun 2013
-   [ocaml-hdfs](planet#888fbf5d83bcf26db8b5e709b18c4185) — 12 Jun 2013
-   [Caml Weekly News, 11 Jun
    2013](planet#ae7a3cd3bc839ec8f990b8cc351d8179) — 11 Jun 2013
-   [New book: OCaml from the Very
    Beginning](planet#b5f19c1f35ee3c83c56f9945ee6aad65) — 10 Jun 2013
-   [Now available on
    Amazon](planet#2dee1259ee3338e92d1b483eef40f975) — 07 Jun 2013
-   [OCaml◎Scope : a new OCaml API search by names and
    types](planet#2cf74780a8a8925e43dd7f5a450d0850) — 06 Jun 2013
-   [Flowing faster:
    foundations](planet#0d10490c0c43827e5992c247475da3bf) — 04 Jun 2013
-   [Caml Weekly News, 04 Jun
    2013](planet#b9543de8acc19d3177293e46d8ecff8c) — 04 Jun 2013
-   [Flowing faster: saving the
    cloud](planet#b1916c31531bff1154076da22bc85c50) — 02 Jun 2013
