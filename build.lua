-- Build script for scontents
pkgversion   = "1.3"
pkgdate      = "2019/09/24"

module       = "scontents"
ctanpkg      = "scontents"
ctanzip      = ctanpkg.."-"..pkgversion

tagfiles     = {"sources/README.md","sources/scontents.sty","sources/scontents.dtx"}

function update_tag (file,content,tagname,tagdate)
 tagdate = string.gsub (pkgdate,"-", "/")
 if string.match (file, "scontents.sty" ) then
  content = string.gsub (content,  
                         "\\ProvidesExplPackage{(.-)}{.-}{.-}",
                         "\\ProvidesExplPackage{%1}{".. tagdate.."}{"..pkgversion .."}")
  return content                         
 elseif string.match (file, "scontents.dtx") then
  content = string.gsub (content,  
                         "\\ProvidesExplPackage{(.-)}{.-}{.-}",
                         "\\ProvidesExplPackage{%1}{".. tagdate.."}{"..pkgversion .. "}")
  return content 
 elseif string.match (file, "README.md") then
   content = string.gsub (content,  
                         "Version: %d%.%d.%s- ",
                         "Version: " .. pkgversion  )
   content = string.gsub (content,  
                         "Date: %d%d%d%d%/%d%d%/%d%d",
                         "Date: " .. tagdate )
 return content
  end
 return content
 end

-- ctan setup
docfiles = {"sources/scontents.pdf","source/scontents.dtx"}
textfiles= {"sources/README.md"}

-- Compile documentation with xelatex to reduce pdf size
typesetexe = "xelatex"
typesetopts= "-8bit"
packtdszip   = false

installfiles = { "sources/scontents.sty" }

sourcefiles  = { "sources/scontents.dtx" }

typesetfiles = { "scontents.dtx" }

typesetruns = 3
