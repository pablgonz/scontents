## scontents — Stores LaTeX contents in memory or files
- Version: 1.7
- Date: 2019-10-29
- Author: Pablo González

## Description
The `scontents` package stores valid `LaTeX` code in memory (sequences) using the
`l3seq` module of `expl3`. The stored content, including `verbatim` material, can be
used as many times as desired in the document, additionally can be written
to external files.

## Requirements
The package loads and depends on updated versions of:
- [expl3](https://ctan.org/pkg/expl3)
- [l3keys2e](https://ctan.org/pkg/l3keys2e)
- [xparse](https://ctan.org/pkg/xparse)

## Installation

The package `scontents` is present in `TeXLive` and `MiKTeX`, use the 
package manager to install.

For manual installation, download `scontents.zip` and unzip it, then move
the files to appropriate locations:
```
  scontents.tex      -> TDS:tex/generic/scontents/
  scontents-code.tex -> TDS:tex/generic/scontents/
  scontents.sty      -> TDS:tex/latex/scontents/
  t-scontents.mkiv   -> TDS:tex/context/third/scontents/
  scontents.pdf      -> TDS:doc/latex/scontents/
  README.md          -> TDS:doc/latex/scontents/
  scontents.dtx      -> TDS:source/latex/scontents/
  scontents.ins      -> TDS:source/latex/scontents/
```
then run `mktexlsr`.
## Examples

The file `scontents.pdf` contains attached examples, which can be extracted
from the PDF viewer or using `pdfdetach -saveall scontents.pdf` from command line.

## License
The scontents package may be modified and distributed under the terms and
conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl/), version 1.3c or greater.

## Contents
- README.md (this file)
- scontents.pdf  (documentation)
- scontents.dtx  (master file that produced all files)
- scontents.ins  (installer to extract all files)
