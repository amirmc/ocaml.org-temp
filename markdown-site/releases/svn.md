
Subversion Repository
=====================

OCaml is developed using the Subversion (SVN) version control system.
Public read-only access to our Subversion repository is available. It
enables advanced users to track changes and bug-fixes in real-time,
without having to wait for the next release.

Bugs can be reported and followed on
[Mantis](http://caml.inria.fr/mantis).

There is also a [read-only mirror on
GitHub](https://github.com/ocaml/ocaml), which is automatically
synchronized with the official SVN repository on a regular basis.

Accessing the repository
------------------------

The address of the repository is `http://caml.inria.fr/svn`. To check
out a local, working copy of the sources:

    svn checkout http://caml.inria.fr/svn/dir

where *dir* is the subdirectory of interest (see table below).

To update a local working copy with our latest changes:

    svn update

If you are not familiar with Subversion commands, see the
[documentation.](http://svnbook.red-bean.com/)

If you do not need a local copy of the sources but just wish to see
changes and their history, you can also [browse the repository via a Web
interface.](http://caml.inria.fr/cgi-bin/viewvc.cgi)

Repository structure
--------------------

  Directory (*dir*)            Contents
  ---------------------------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  `ocaml/trunk`                The development version of OCaml. It will become the next major release. Not very stable; use at your own risk.
  `ocaml/version/`*X*`.`*YY*   The bug-fix branch for the major release number *X*`.`*YY* (e.g. `3.11`). Minor releases are culled from this branch. Only bug-fixes and minor extensions are performed in this branch, but not incompatible changes. Recommended for advanced users who wish to track bug fixes.
  `ocaml/branches/`            Various branches containing experiments or extensions to OCaml, e.g. `ocaml/branches/jocamltrunk` for JoCaml. Many of the experimental branches have been folded in the development sources. To explore the contents, use `svn list` or [browse the repository](http://caml.inria.fr/cgi-bin/viewvc.cgi/ocaml/branches/)
