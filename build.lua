-- Build script for scontents
pkgversion   = "1.8"
pkgdate      = "2019-11-18"

module       = "scontents"
ctanpkg      = "scontents"
ctanzip      = ctanpkg.."-"..pkgversion

tagfiles     = {"sources/README.md","sources/scontents.ins","sources/scontents.dtx"}

function update_tag (file,content,tagname,tagdate)
 tagdate = string.gsub (pkgdate,"-", "-")
 if string.match (file, "scontents.ins" ) then
  content = string.gsub (content,
                         "date=%d%d%d%d%-%d%d%-%d%d",
                         "date="..tagdate.."")
  content = string.gsub (content,
                         "version=%d%.%d",
                         "version=".. pkgversion ..""  )
  return content
 elseif string.match (file, "scontents.dtx") then
  content = string.gsub (content,
                         "\\ScontentsFileDate{(.-)}",
                         "\\ScontentsFileDate{"..tagdate.."}")
  content = string.gsub (content,
                         "\\ScontentsCoreFileDate{(.-)}",
                         "\\ScontentsCoreFileDate{"..tagdate.."}")
  content = string.gsub (content,
                         "\\ScontentsFileVersion{(.-)}",
                         "\\ScontentsFileVersion{"..pkgversion.."}")
  return content
 elseif string.match (file, "README.md") then
   content = string.gsub (content,
                         "Version: %d%.%d",
                         "Version: "..pkgversion.."" )
   content = string.gsub (content,
                         "Date: %d%d%d%d%-%d%d%-%d%d",
                         "Date: ".. tagdate.."" )
 return content
  end
 return content
 end

-- ctan setup
docfiles = {"sources/scontents.pdf","sources/scontents.dtx","sources/scontents.ins"}
textfiles= {"sources/README.md"}

-- Compile documentation with xelatex to reduce pdf size
typesetexe = "lualatex"
-- typesetopts= "-8bit"
packtdszip   = false

excludefiles = { "scontents/scontents.sty","scontents/scontents-code.tex" }
sourcefiles  = { "sources/scontents.dtx","sources/scontents.sty","sources/scontents-code.tex" }
typesetfiles = { "scontents.dtx" }

typesetruns = 3
