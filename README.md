# tkz-doc — Documentation macros for the TKZ series of packages

Release 1.4c 2020/03/20

## Note

This package is highly experimental and subject to change without notice.

## Licence

The `tkz-doc` package may be modified and distributed under the terms and
conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl/), version 1.3c or greater.

## Installation

The package `tkz-doc` is present in `TeXLive` and `MiKTeX`, use the
package manager to install.

For manual installation all files must be moved into the different directories in your
installation `TDS` tree or in your `TEXMFHOME`:

```
  doc/README.md -> TDS:doc/latex/tkz-doc/README.md
  latex/*.*     -> TDS:tex/latex/tkz-doc/*.*
```

## How to use it

1. If you want to compile the documentation of a `tkz-*` package, yuo need to use
the lualatex engine.

2. I added in the version 1.4, an option called `cadre`. If you want to draw the
frame of the cover, you need to use this option. In this case, you need to
install the font `orna4`. By default, no frame.

## Author

Alain Matthes, 5 rue de Valence, Paris 75005, al (dot) ma (at) mac (dot) com
