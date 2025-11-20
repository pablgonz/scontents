## scontents — Stores LaTeX contents in memory or files

Release v2.6 \[2025-11-20\]

## Description

This package allows to store LaTeX code, including _verbatim_, in <code>&langle;sequences&rangle;</code>
using the `l3seq` module of `expl3`. The <code>&langle;stored content&rangle;</code> can be used
as many times as desired in the document, additionally you can write to <code>&langle;external files&rangle;</code>
or show it in <code>&langle;verbatim style&rangle;</code>. This package is fully compatible with _tagged_ PDF.

## Requirements

The minimum required is LaTeX release 2024-11-01.

## Installation

The package <code>&langle;scontents&rangle;</code> is present in `TeX Live` and `MiKTeX`, use the
package manager to install.

For manual installation, download [scontents.zip](http://mirrors.ctan.org/macros/latex/contrib/scontents.zip) and unzip it,
then run:

```
$ luatex scontents.ins
```

Now the different files must be moved into the different directories in your
installation `TDS` tree or in your `TEXMFHOME`:

```
  scontents.tex      -> TDS:tex/generic/scontents/scontents.tex
  scontents-code.tex -> TDS:tex/generic/scontents/scontents-code.tex
  scontents.sty      -> TDS:tex/latex/scontents/scontents.sty
  t-scontents.mkiv   -> TDS:tex/context/third/scontents/t-scontents.mkiv
  scontents.pdf      -> TDS:doc/latex/scontents/scontents.pdf
  scontents.dtx      -> TDS:source/latex/scontents/scontents.dtx
  scontents.ins      -> TDS:source/latex/scontents/scontents.ins
```

then run `mktexlsr`. To produce the documentation with source code run `luatex scontents.ins` and
`lualatex scontents.dtx` three times.

## Examples

The file <code>&langle;scontents.pdf&rangle;</code> contains attached examples, which can be extracted
from the PDF viewer or from the command line by running:

```
$ pdfdetach -saveall scontents.pdf
```

and then you can use the excellent `arara` tool to compile them.

## License

The package <code>&langle;scontents&rangle;</code> may be modified and distributed under the terms and
conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl/), version 1.3c or greater.

## Contents

- README.md (this file)
- scontents.pdf  (documentation)
- scontents.dtx  (master file that produced all files)
- scontents.ins  (installer to extract all files)

## Author and copyright

Copyright 2019 — 2025 by Pablo González L.
