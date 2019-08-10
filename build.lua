-- Build script for scontents
pkgversion   = "1.1"
pkgdate      = "2019/08/11"

module       = "scontents"
ctanpkg      = "scontents"

tagfiles     = {"sources/scontents.md","sources/scontents.sty","sources/scontents.dtx"}

-- ctan setup
docfiles = {"sources/scontents.pdf","source/scontents.dtx"}
textfiles= {"sources/README.md"}

-- Compile documentation with xelatex to reduce pdf size
typesetexe = "xelatex"
packtdszip   = false

installfiles = { "sources/scontents.sty" }
               
sourcefiles  = { "sources/scontents.dtx" }
                            
typesetfiles = { "scontents.dtx" }

typesetruns = 3
