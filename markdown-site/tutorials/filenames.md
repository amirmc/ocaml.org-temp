
Filenames
=========

This is a reference to the standard **filenames** and extensions used by
various parts of the OCaml build system.

Note: There is an [extended mailing list posting about filenames used by
OCaml
here](http://caml.inria.fr/pub/ml-archives/caml-list/2008/09/2bc9b38171177af5dc0d832a365d290d.en.html "http://caml.inria.fr/pub/ml-archives/caml-list/2008/09/2bc9b38171177af5dc0d832a365d290d.en.html").

Source and object files
-----------------------

The basic source, object and binary files, with comparisons to C
programming:

  Purpose           C      Bytecode   Native code
  ----------------- ------ ---------- -------------
  Source code       \*.c   \*.ml      \*.ml
  Header files^1^   \*.h   \*.mli     \*.mli
  Object files      \*.o   \*.cmo     \*.cmx^2^
  Library files     \*.a   \*.cma     \*.cmxa^3^
  Binary programs   prog   prog       prog.opt^4^

### Notes

1.  In C the header files describe the functions, etc., but only by
    convention. In OCaml, the \*.mli file is the exported signature of
    the [module](modules.html "modules"), and the compiler strictly
    enforces it. \
     In most cases for a module called `Foo` you will find two files:
    `foo.ml` and `foo.mli`. `foo.ml` is the implementation and `foo.mli`
    is the interface or signature. \
     Notice also that the first letter of the file is turned to
    uppercase to get the module name. For example, Extlib contains a
    file called `uTF8.mli` which is the signature of a module called
    `UTF8`.
2.  There is also a corresponding \*.o file which contains the actual
    machine code, but you can usually ignore this file.
3.  There is also a corresponding \*.a file which contains the actual
    machine code, but you can usually ignore this file.
4.  This is the convention often used by OCaml programs, but in fact you
    can name binary programs however you want.

\*.cmi files
------------

`*.cmi` files are intermediate files which are compiled forms of the
`.mli` (interface or "header file").

To produce them, just compile the `.mli` file:

    ocamlc -c foo.mli
