# Contributing to elm-community/elm-webgl

This repository is kept for maintenance and does not accept most feature requests. In particular, [#6](https://github.com/elm-community/elm-webgl/issues/6) requires that all
changes be PATCH-level, meaning that the API cannot be modified.

Any contribution should:
* Compile using `elm make`
* Be recognized as a PATCH change using `elm package diff`
* Not introduce mutable variables
* Justify why the change is needed and why it won't break anything already here
* JavaScript code should be validated using `eslint src`

Documentation improvements are welcome.
