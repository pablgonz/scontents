-- Build script for scontents
pkgversion   = "1.0"
pkgdate      = "2019/07/30"

module       = "scontents"
ctanpkg      = "scontents"

tagfiles     = {"sources/*.md","sources/*.sty","sources/*.dtx"}

-- ctan setup
docfiles = {"sources/scontents.pdf","source/scontents.dtx"}
textfiles= {"sources/README.md"}

-- Compile documentation with xelatex to reduce pdf size
typesetexe = "xelatex"
packtdszip   = false

installfiles = {
                "**/*.sty"
               }  
               
sourcefiles  = {
                "**/*.sty",
                "**/*.dtx"
               }
                            
typesetfiles = {"scontents.dtx"}

typesetruns = 3
