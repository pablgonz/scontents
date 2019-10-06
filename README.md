## scontents — Stores LaTeX contents in memory or files
![GitHub release (latest by date)](https://img.shields.io/github/v/release/pablgonz/scontents?label=version)
![GitHub Release Date](https://img.shields.io/github/release-date/pablgonz/scontents)
![GitHub last commit](https://img.shields.io/github/last-commit/pablgonz/scontents)
![GitHub commit activity](https://img.shields.io/github/commit-activity/w/pablgonz/scontents)
![GitHub](https://img.shields.io/github/license/pablgonz/scontents)

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
package manager to install. For a manual installation, put `scontents.dtx` 
in your working directory and run `tex scontents.dtx`.

## Examples

The file `scontents.pdf` contains attached examples, which can be extracted
from the PDF viewer or using 
```
pdfdetach -saveall scontents.pdf
``` 
from command line.

## License
The scontents package may be modified and distributed under the terms and
conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl/), version 1.3c or greater.

## Contents
- README.md (this file)
- scontents.pdf  (documentation)
- scontents.dtx  (master file that produced all files)

## Copyright

Copyright 2019 by Pablo González L.
