## scontents — Stores LaTeX contents in memory or files
![GitHub release (latest by date)](https://img.shields.io/github/v/release/pablgonz/scontents?label=version)
![GitHub Release Date](https://img.shields.io/github/release-date/pablgonz/scontents)
![GitHub last commit](https://img.shields.io/github/last-commit/pablgonz/scontents)
![GitHub commits since latest release](https://img.shields.io/github/commits-since/pablgonz/scontents/v1.4)

## Description
The `scontents` package stores valid `LaTeX` code in <code>&lt;sequences&gt;</code> using the
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
package manager to install. For a manual installation, put `scontents.dtx` 
in your working directory and run `tex scontents.dtx`.

## Examples

The file `scontents.pdf` contains attached examples, which can be extracted
from the PDF viewer or using:

```bash
pdfdetach -saveall scontents.pdf
```
 
from command line.

## License
The scontents package may be modified and distributed under the terms and
conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl/), version 1.3c or greater.

## Contents
- README.md
- scontents.sty
- scontents.dtx

## Copyright

Copyright 2019 by Pablo González L.
