## scontents — Stores LaTeX contents in memory or files
- Version: 1.9
- Date: 2020-01-21
- Author: Pablo González

## Description
This package allows to store `LaTeX` code, including _"verbatim"_, in <code>&lt;sequences&gt;</code>
using the `l3seq` module of `expl3`. The <code>&lt;stored content&gt;</code> can be used
as many times as desired in the document, additionally you can write to <code>&lt;external files&gt;</code>
or show it in <code>&lt;verbatim style&gt;</code>.

## Requirements
The package loads and depends on updated versions of:
- [expl3](https://ctan.org/pkg/expl3)
- [l3keys2e](https://ctan.org/pkg/l3keys2e)
- [xparse](https://ctan.org/pkg/xparse)

## Installation

The package `scontents` is present in `TeXLive` and `MiKTeX`, use the 
package manager to install.

For manual installation, download `scontents.zip` and unzip it, 
then run:
```
$ pdftex scontents.ins
```
and move all files to appropriate locations:
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

The file <code>&lt;scontents.pdf&gt;</code> contains attached examples, which can be extracted
from the PDF viewer or from the command line by running:

```
$ pdfdetach -saveall scontents.pdf
```
and then you can use the excellent `arara` tool to compile them.

## License
The scontents package may be modified and distributed under the terms and
conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl/), version 1.3c or greater.

## Contents
- README.md (this file)
- scontents.pdf  (documentation)
- scontents.dtx  (master file that produced all files)
- scontents.ins  (installer to extract all files)
