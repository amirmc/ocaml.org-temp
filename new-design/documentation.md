---
layout: layout
title: Documentation
section: Documentation
---

<div class="container">

    <h1>Documentation</h1>

    <div class="row">
        <section class="span6 condensed">
            <h1 class="ruled">Summary</h1>
            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.</p>
            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit sed. Lorem ipsum dolor sit amet.</p>
        </section>
        <section class="span6 condensed">
            <h1 class="ruled">Reference</h1>
            <div class="row">
                <a href="#" class="span3 documentation-highlight">
                    <img src="static/img/manual.png" alt="">
                    OCaml Manual
                </a>
                <a href="#" class="span3 documentation-highlight">
                    <img src="static/img/license.png" alt="">
                    OCaml License
                </a>
            </div>
            <div class="row">
                <a href="#" class="span3 documentation-highlight">
                    <img src="static/img/documents.png" alt="">
                    Package Documents
                </a>
                <a href="#" class="span3 documentation-highlight">
                    <img src="static/img/cheat.png" alt="">
                    Cheat Sheets
                </a>
            </div>
        </section>
    </div>

    <div class="row">
        <section class="span6 condensed">
            <h1 class="ruled">OPAM Docs</h1>
            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>
            <p>Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.</p>
        </section>
        <section class="span6 condensed">
            <h1 class="ruled">OCaml Book</h1>
            <div class="row">
                <div class="span2 documentation-book">
                    <a href="#">
                        <img src="static/img/real-world-ocaml.png" alt="Real Worl OCaml book">
                    </a>
                </div>
                <div class="span4">
                    <p>This hands-on book shows you how to take advantage of OCaml’s functional, imperative and object-oriented programming styles with recipes for many real-world tasks.</p>
                    <p>Starting with OCaml basics, including interactive examples, you’ll move toward more advanced topics such as the module system, foreign-function interface and build system.</p>
                    <p><a href="#">Read Free Online</a></p>
                </div>
            </div>
        </section>
    </div>

    <div class="row">
        <section class="span12 condensed">
            <h1 class="ruled">Videos</h1>
            <div class="row">
                {% for i in (1..3) %}
                    <div class="span4">
                        <p class="documentation-video">
                            <a href="#">
                                <img src="static/img/video.png" alt="Video">
                            </a>
                        </p>
                        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna. Duis aute irure dolor in reprehenderit in voluptate.</p>
                    </div>
                {% endfor %}
            </div>
        </section>
    </div>

</div>