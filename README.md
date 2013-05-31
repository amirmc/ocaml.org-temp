OCAML SITE
==========

Greetings fellow coder! This is the source code used the build the OCaml site templates. You can
find a copy of the built code under the `_site` directory.

However, if you intend to modify the HTML or CSS code, it's highly recommended that you DON'T EDIT THE
FILES IN THE `_site` DIRECTORY. This is because they are generated files, and once edited, make the entire
source code used to generate them useless.


Editing CSS
-----------

Twitter Bootstrap uses LESS to build it's CSS files, and the most effective way of modifying the theme
of Bootstrap is by modifiying the original LESS files, rather than the generated CSS. Thus, to edit the
CSS of this site, please edit the contents of the `static/css` folder, and then compile it to CSS in
the generated site folder.


Editing HTML
------------

To avoid code duplication, this site was built using Jekyll (of GitHub fame). Editing the HTML of the various
templates and layouts, then compiling the site using Jekyll, is really the way to go.

Even better, this Jekyll site will compile the LESS stylesheets for you too, so save yourself a headache, and
`gem install jekyll` to get started.


HAPPY CODING!